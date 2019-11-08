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

setup: start-concourse login create-team login-team set-pipelines
	
destroy:
	docker-compose down

.PHONY: setup destroy
