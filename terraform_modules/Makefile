PASSED_ACCOUNT ?= $(shell read -e -p "account: " account; echo $$account)
PASSED_PROJECT_NAME ?= $(shell read -e -p "projectname: " projectname; echo $$projectname)
PASSED_PROJECT_NAME := $(PASSED_PROJECT_NAME) # <- fix 'immediately' to prevent multiple prompts

CURRENT_ACCOUNT:=$$(gcloud config list account \
	--format 'value(core.account)')
EXISTING_PROJECT_NAME:=$$(gcloud projects list --filter $(PASSED_PROJECT_NAME) \
	--format 'value(NAME)')
ACTIVE_PROJECT:=$$(gcloud config get-value project)
SERVICE_ACCOUNT_NAME:=$$(gcloud iam service-accounts list \
	--filter="NAME=$(PASSED_PROJECT_NAME)-service-account" \
	--format="value(NAME)")
SERVICE_ACCOUNT_EMAIL:=$$(gcloud iam service-accounts list \
	--filter="NAME=$(PASSED_PROJECT_NAME)-service-account" \
	--format="value(EMAIL)")
GCP_CREDENTIALS_PATH:=./secrets/$(PASSED_PROJECT_NAME)_service_account_secret_key.json

.PHONY: all
all: login create_project activate_project make_service_account get_and_store_service_account_key

login:
	@if [ "$(CURRENT_ACCOUNT)" != "$(PASSED_ACCOUNT)" ];\
	then gcloud auth login;\
	else echo "already logged in";\
	fi

create_project: login
	@if [ "$(EXISTING_PROJECT_NAME)" != "$(PASSED_PROJECT_NAME)" ];\
	then gcloud projects create $(PASSED_PROJECT_NAME) --labels=type=practice;\
	else echo "project already exists in";\
	fi

activate_project: login
	@if [ "$(ACTIVE_PROJECT)" != "$(PASSED_PROJECT_NAME)" ];\
	then gcloud config set project $(PASSED_PROJECT_NAME);\
	else echo "project already activated in";\
	fi

make_service_account: login
	@if [ "$(SERVICE_ACCOUNT_NAME)" = "" ];\
	then gcloud iam service-accounts create $(PASSED_PROJECT_NAME) \
		--description="service account for $(PASSED_PROJECT_NAME)" \
		--display-name="$(PASSED_PROJECT_NAME)-service-account";\
	else echo "service account already exists in";\
	fi

# is it okay to store locally? How can I authenticate service account without storing a secret?
get_and_store_service_account_key: login
	@if ! [ -f $(GCP_CREDENTIALS_PATH) ];\
	then gcloud iam service-accounts keys create \
		$(GCP_CREDENTIALS_PATH) \
		--iam-account $(SERVICE_ACCOUNT_EMAIL);\
	else echo "some file already present in $(GCP_CREDENTIALS_PATH)";\
	fi
