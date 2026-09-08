BOOTSTRAP_DIR := infrastructure/bootstrap

.PHONY: init apply deploy

init:
	terraform -chdir=$(BOOTSTRAP_DIR) init

apply:
	terraform -chdir=$(BOOTSTRAP_DIR) apply

deploy: init apply
