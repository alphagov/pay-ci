start-concourse:
	docker-compose up -d
	while ! wget -q http://localhost:8080 -O /dev/null; do sleep 1; done;

login:
	fly -t ci login --concourse-url=http://localhost:8080 --insecure --username=test --password=test

create-team:
	fly -t ci set-team --team-name pay --local-user test --non-interactive

set-pipelines:
	fly -t ci set-pipeline --pipeline provision-dev-envs --config provision-dev-envs.yml --var concourse-url=http://concourse:8080 --non-interactive

setup: start-concourse login create-team set-pipelines
	
destroy:
	docker-compose down

.PHONY: setup destroy