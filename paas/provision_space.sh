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
EOF
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

  # -- Set cleanup
  function cleanup {
    default_space_permissions "$CF_ORG" "$CF_SPACE" "$DEPLOYER_USER"
    if test "$SEPARATE_CDE" = true; then
      default_space_permissions "$CF_ORG" "$CF_SPACE_CDE" "$DEPLOYER_USER"
    fi
  }
  trap cleanup EXIT SIGINT

  # -- Create spaces
  cf target -o "$CF_ORG"
  cf space "$CF_SPACE" >/dev/null || cf create-space "$CF_SPACE"

  if test "$SEPARATE_CDE" = true; then
    export CF_SPACE_CDE="${CF_SPACE}-cde"
    cf space "$CF_SPACE_CDE" >/dev/null || cf create-space "$CF_SPACE_CDE"
  fi

  # -- Temporarily grant write permissions
  write_space_permissions "$CF_ORG" "$CF_SPACE"
  write_space_permissions "$CF_ORG" "$CF_SPACE_CDE"

  # -- Create domain
  if test -n "$DOMAIN"; then
    cf domains | grep -q "$DOMAIN" || cf create-domain "$CF_ORG" "$DOMAIN"
  fi

  exit 0
fi
