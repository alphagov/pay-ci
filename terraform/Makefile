default: install-providers

.PHONY: install-paas-provider
install-pass-provider:
	go get github.com/camptocamp/terraform-provider-pass
	GOBIN=~/.terraform.d/plugins/darwin_amd64 go install github.com/camptocamp/terraform-provider-pass
	mv ~/.terraform.d/plugins/darwin_amd64/terraform-provider-pass ~/.terraform.d/plugins/darwin_amd64/terraform-provider-pass_v1.2.1

.PHONY: install-cf-provider
install-cf-provider:
	mkdir -p ${GOPATH}/src/github.com/terraform-providers
	if [ ! -d "${GOPATH}/src/github.com/terraform-providers/terraform-provider-cloudfoundry" ]; then \
    	git clone -b v3_app_resource git@github.com:alphagov/terraform-provider-cf.git ${GOPATH}/src/github.com/terraform-providers/terraform-provider-cloudfoundry; \
	fi
	cd ${GOPATH}/src/github.com/terraform-providers/terraform-provider-cloudfoundry; GOBIN=~/.terraform.d/plugins/darwin_amd64 go install
	mv ~/.terraform.d/plugins/darwin_amd64/terraform-provider-cloudfoundry ~/.terraform.d/plugins/darwin_amd64/terraform-provider-cloudfoundry_v0.11.0

.PHONY: install-providers
install-providers: install-pass-provider install-cf-provider