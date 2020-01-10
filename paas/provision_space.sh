#!/usr/bin/env bash
# provision_space.sh - Provisions a PaaS space suitable for production.

# -- Functions
function usage {
cat <<EOF
  Usage: $0 [--help]
  Set the following environment variables:
    CF_ORG        The PaaS organisation
    CF_SPACE      The PaaS space
    SEPARATE_CDE  If 'true', create a separate CDE space
    DEPLOYER_USER Username that will get SpaceDeveloper
    DOMAIN        If set, attaches a domain to the org
    DOCKER_APPS   If 'true', create docker image placeholder apps
    CREATE_DBS    If 'true', provision database service instances
EOF
}

function create_buildpack_app {
  local app="$1"

  mkdir -p /tmp/placeholder
  touch /tmp/placeholder/empty
  if cf app "$app" | grep -qv 'buildpacks:'; then
    cf delete -f "$app"
    cf push --no-route --no-manifest --no-start -p /tmp/placeholder "$app"
  fi
}

function create_docker_app {
  local app="$1"

  if cf app "$app" | grep -qv 'docker image:'; then
    cf delete -f "$app"
    cf push --no-route --no-manifest --no-start --docker-image alpine "$app"
  fi
}

function write_space_permissions {
  local org="$1"
  local space="$2"
  local me=$(cf target | awk '/^user:/ {print $2}')

  cf set-space-role "$me" "$org" "$space" SpaceDeveloper
  cf set-space-role "$me" "$org" "$space" SpaceManager
}

function default_space_permissions {
  local org="$1"
  local space="$2"
  local deployer="$3"
  local me=$(cf target | awk '/^user:/ {print $2}')

  cf unset-space-role "$me" "$org" "$space" SpaceDeveloper
  cf unset-space-role "$me" "$org" "$space" SpaceManager
  cf set-space-role "$me" "$org" "$space" SpaceAuditor
  cf set-space-role "$deployer" "$org" "$space" SpaceDeveloper
}

function create_db {
  local name="$1"

  cf service "$name" || cf create-service postgres tiny-unencrypted-11 "$name" -c '{"enable_extensions": ["pg_trgm"]}'
}

function bind_db {
  local app="$1"
  local service="$2"

  echo -n "Waiting for $service to be created "
  until cf service "$service" | grep -q "status is 'available'"; do
    echo -n .
    sleep 5
  done
  echo " done"

  cf bind-service "$app" "$service"

  eval $(cf curl /v2/apps/$(cf app --guid "$app")/env | jq -r '.system_env_json.VCAP_SERVICES.postgres[0].credentials | {DB_HOST: .host, DB_USER: .username, DB_PASSWORD: .password, DB_NAME: .name} | to_entries | map("\(.key)=\(.value)")[]')

  cf set-env "$app" DB_HOST "$DB_HOST"
  cf set-env "$app" DB_NAME "$DB_NAME"
  cf set-env "$app" DB_USER "$DB_USER"
  cf set-env "$app" DB_PASSWORD "$DB_PASSWORD"
  cf restage "$app"
}

# -- Main
if test "$0" == "$BASH_SOURCE"; then # script is being run
  set -o errexit \
      -o nounset \
      -o pipefail

  case "${1:-}" in
    -h|--help)
      usage
      exit 1
      ;;
  esac

  # -- Environment variables
  # PaaS organisation and space name
  : ${CF_ORG:?Need to set CF_ORG (--help for more info)}
  : ${CF_SPACE:?Need to set CF_SPACE (--help for more info)}
  export CF_SPACE_CDE="$CF_SPACE"

  # If set to 'true', create a separate CDE space, otherwise default blank
  : ${SEPARATE_CDE:=}

  # Name of user which will get SpaceDeveloper powers in this space
  : ${DEPLOYER_USER:?Need to set DEPLOYER_USER (--help for more info)}

  # Public domain name to attach to this space
  : ${DOMAIN:=}

  # If set to 'true', create docker image based apps
  : ${DOCKER_APPS:=}

  # If set to 'true', create database service instances
  : ${CREATE_DBS:=}

  # -- Set cleanup
  function cleanup {
    default_space_permissions "$CF_ORG" "$CF_SPACE" "$DEPLOYER_USER"
    if test "$SEPARATE_CDE" = true; then
      default_space_permissions "$CF_ORG" "$CF_SPACE_CDE" "$DEPLOYER_USER"
    fi
  }
  trap cleanup EXIT

  # -- Create spaces
  cf target -o "$CF_ORG" -s sandbox
  cf space "$CF_SPACE" >/dev/null || cf create-space "$CF_SPACE"

  if test "$SEPARATE_CDE" = true; then
    export CF_SPACE_CDE="${CF_SPACE}-cde"
    cf space "$CF_SPACE_CDE" >/dev/null || cf create-space "$CF_SPACE_CDE"
  fi

  # -- Temporarily grant write permissions
  write_space_permissions "$CF_ORG" "$CF_SPACE"
  write_space_permissions "$CF_ORG" "$CF_SPACE_CDE"

  # -- Create placeholder apps
  apps=(
  adminusers
  directdebit-connector
  directdebit-frontend
  egress
  ledger
  products
  products-ui
  publicapi
  publicauth
  selfservice
  toolbox
  notifications
  postgres # remove
  sqs      # remove
  )

  cde_apps=(
  cardid
  card-connector
  card-frontend
  )

  cf target -s "$CF_SPACE"
  for app in ${apps[@]}; do
    test "$DOCKER_APPS" = true && create_docker_app "$app" || create_buildpack_app "$app"
  done

  cf target -s "$CF_SPACE_CDE"
  for app in ${cde_apps[@]}; do
    test "$DOCKER_APPS" = true && create_docker_app "$app" || create_buildpack_app "$app"
  done

  # -- Apply network policies
  cf target -s "$CF_SPACE"
  cf  add-network-policy  adminusers             --destination-app  egress                 -s "$CF_SPACE"     --protocol  tcp  --port  8080
  cf  add-network-policy  adminusers             --destination-app  postgres               -s "$CF_SPACE"     --protocol  tcp  --port  5432
  cf  add-network-policy  directdebit-connector  --destination-app  egress                 -s "$CF_SPACE"     --protocol  tcp  --port  8080
  cf  add-network-policy  directdebit-connector  --destination-app  postgres               -s "$CF_SPACE"     --protocol  tcp  --port  5432
  cf  add-network-policy  directdebit-frontend   --destination-app  adminusers             -s "$CF_SPACE"     --protocol  tcp  --port  8080
  cf  add-network-policy  directdebit-frontend   --destination-app  directdebit-connector  -s "$CF_SPACE"     --protocol  tcp  --port  8080
  cf  add-network-policy  ledger                 --destination-app  postgres               -s "$CF_SPACE"     --protocol  tcp  --port  5432
  cf  add-network-policy  ledger                 --destination-app  sqs                    -s "$CF_SPACE"     --protocol  tcp  --port  9324
  cf  add-network-policy  notifications          --destination-app  card-connector         -s "$CF_SPACE_CDE" --protocol  tcp  --port  8080
  cf  add-network-policy  notifications          --destination-app  directdebit-connector  -s "$CF_SPACE"     --protocol  tcp  --port  8080
  cf  add-network-policy  products               --destination-app  postgres               -s "$CF_SPACE"     --protocol  tcp  --port  5432
  cf  add-network-policy  products-ui            --destination-app  products               -s "$CF_SPACE"     --protocol  tcp  --port  8080
  cf  add-network-policy  publicapi              --destination-app  card-connector         -s "$CF_SPACE_CDE" --protocol  tcp  --port  8080
  cf  add-network-policy  publicapi              --destination-app  directdebit-connector  -s "$CF_SPACE"     --protocol  tcp  --port  8080
  cf  add-network-policy  publicauth             --destination-app  postgres               -s "$CF_SPACE"     --protocol  tcp  --port  5432
  cf  add-network-policy  selfservice            --destination-app  adminusers             -s "$CF_SPACE"     --protocol  tcp  --port  8080
  cf  add-network-policy  selfservice            --destination-app  card-connector         -s "$CF_SPACE_CDE" --protocol  tcp  --port  8080
  cf  add-network-policy  selfservice            --destination-app  directdebit-connector  -s "$CF_SPACE"     --protocol  tcp  --port  8080
  cf  add-network-policy  selfservice            --destination-app  ledger                 -s "$CF_SPACE"     --protocol  tcp  --port  8080
  cf  add-network-policy  selfservice            --destination-app  products               -s "$CF_SPACE"     --protocol  tcp  --port  8080

  cf target -s "$CF_SPACE_CDE"
  cf  add-network-policy  card-connector         --destination-app  egress                 -s "$CF_SPACE"     --protocol  tcp  --port  8080
  cf  add-network-policy  card-connector         --destination-app  postgres               -s "$CF_SPACE"     --protocol  tcp  --port  5432
  cf  add-network-policy  card-connector         --destination-app  sqs                    -s "$CF_SPACE"     --protocol  tcp  --port  9324
  cf  add-network-policy  card-frontend          --destination-app  adminusers             -s "$CF_SPACE"     --protocol  tcp  --port  8080
  cf  add-network-policy  card-frontend          --destination-app  card-connector         -s "$CF_SPACE_CDE" --protocol  tcp  --port  8080
  cf  add-network-policy  card-frontend          --destination-app  cardid                 -s "$CF_SPACE_CDE" --protocol  tcp  --port  8080

  # -- Create databases
  db_apps=(
  publicauth
  adminusers
  products
  directdebit-connector
  ledger
  )

  cde_db_apps=(
  card-connector
  )

  if test "$CREATE_DBS" = true; then
    cf target -s "$CF_SPACE"
    for app in ${db_apps[@]}; do
      create_db "${app}-db"
      bind_db "$app" "${app}-db"
    done

    cf target -s "$CF_SPACE_CDE"
    for app in ${cde_db_apps[@]}; do
      create_db "${app}-db"
      bind_db "$app" "${app}-db"
    done
  fi

  # -- Create domain
  if test -n "$DOMAIN"; then
    cf domains | grep -q "$DOMAIN" || cf create-domain "$CF_ORG" "$DOMAIN"
  fi

  exit 0
fi
