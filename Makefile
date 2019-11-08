start-concourse:
	docker-compose up -d
	while ! wget -q http://localhost:8080 -O /dev/null; do sleep 1; done;

login:
	fly -t local login --concourse-url=http://localhost:8080 --insecure --username=test --password=test

create-team:
	fly -t local set-team --team-name pay --local-user test --non-interactive

login-team:
	fly -t local-pay login --concourse-url=http://localhost:8080 --insecure --username=test --password=test -n pay

set-pipelines:
	fly -t local-pay set-pipeline \
		--pipeline provision-dev-envs \
		--config concourse/provision-dev-envs.yml \
		--var concourse-url=http://concourse:8080 \
		--var concourse-team=pay \
		--var concourse-username=test \
		--var concourse-password=test \
		--non-interactive
	fly -t local-pay unpause-pipeline -p provision-dev-envs

add-creds:
	 docker-compose exec localstack \
		 awslocal ssm put-parameter \
		 --name /concourse/pay/cf-username \
		 --value $$(env PASSWORD_STORE_DIR=secrets pass paas-london/govuk-pay/org-manager-bot/username) \
		 --type String \
		 --overwrite
	 docker-compose exec localstack \
		 awslocal ssm put-parameter \
		 --name /concourse/pay/cf-password \
		 --value $$(env PASSWORD_STORE_DIR=secrets pass paas-london/govuk-pay/org-manager-bot/password) \
		 --type String \
		 --overwrite

setup: start-concourse add-creds login create-team login-team set-pipelines
	
destroy:
	docker-compose down

.PHONY: setup destroy
