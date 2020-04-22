default: install-providers

.PHONY: install-paas-provider
install-pass-provider:
	go get github.com/camptocamp/terraform-provider-pass
	GOBIN=~/.terraform.d/plugins/darwin_amd64 go install github.com/camptocamp/terraform-provider-pass

.PHONY: install-cf-provider
install-cf-provider:
	mkdir -p ${GOPATH}/src/github.com/terraform-providers
	if [ ! -d "${GOPATH}/src/github.com/terraform-providers/terrform-provider-cloudfoundry" ]; then \
    	git clone -b v3_app_resource git@github.com:alphagov/terraform-provider-cf.git ${GOPATH}/src/github.com/terraform-providers/terrform-provider-cloudfoundry; \
	fi
	cd ${GOPATH}/src/github.com/terraform-providers/terrform-provider-cloudfoundry; GOBIN=~/.terraform.d/plugins/darwin_amd64 go install

.PHONY: install-providers
install-providers: install-pass-provider install-cf-provider