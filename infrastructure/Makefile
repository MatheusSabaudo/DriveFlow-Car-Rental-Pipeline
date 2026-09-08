STATE_BUCKET    ?= driveflow-terraform-state
STATE_KEY       ?= infrastructure/terraform.tfstate
AWS_REGION      ?= eu-central-1
SNS_ALERT_EMAIL ?=

.PHONY: init apply deploy

init:
	terraform init \
		-backend-config="bucket=$(STATE_BUCKET)" \
		-backend-config="key=$(STATE_KEY)" \
		-backend-config="region=$(AWS_REGION)" \
		-backend-config="encrypt=true"

apply:
	terraform apply -var="sns_alert_email=$(SNS_ALERT_EMAIL)"

deploy: init apply
