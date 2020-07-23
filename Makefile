#TODO currently requires project name to be passed in prompt if it already exists. error otherwise (issue)
#TODO automatically fill terraform.env file
PASSED_ACCOUNT ?= $(shell read -e -p "account: " account; echo $$account)
PASSED_PROJECT_NAME ?= $(shell read -e -p "projectname: " projectname; echo $$projectname)
PASSED_PROJECT_NAME := $(PASSED_PROJECT_NAME) # <- overwrite 'immediately' to prevent multiple prompts


### gcloud get commands ###
CURRENT_ACCOUNT:=$$( \
	gcloud config list account \
	--format 'value(core.account)' \
)

EXISTING_PROJECT_NAME:=$$( \
	gcloud projects list \
	--filter $(PASSED_PROJECT_NAME) \
	--format 'value(NAME)' \
)

ACTIVE_PROJECT:=$$( \
	gcloud config get-value project \
)

SERVICE_ACCOUNT_NAME:=$$( \
	gcloud iam service-accounts list \
	--filter="NAME=$(PASSED_PROJECT_NAME)-service-account" \
	--format="value(NAME)" \
)

SERVICE_ACCOUNT_EMAIL:=$$( \
	gcloud iam service-accounts list \
	--filter="NAME=$(PASSED_PROJECT_NAME)-service-account" \
	--format="value(EMAIL)"\
)

#TODO though it works, I don't quite understand --flatten='bindings[].members'
SERVICE_ACCOUNT_ROLES:=$$( \
	gcloud projects get-iam-policy \
	$(PASSED_PROJECT_NAME) \
	--flatten='bindings[].members' \
	--format='table(bindings.role)' \
	--filter="bindings.members:serviceAccount:$(PASSED_PROJECT_NAME)@$(PASSED_PROJECT_NAME).iam.gserviceaccount.com" \
)

RESOURCE_MANAGER:=$$( \
	gcloud services list \
	--enabled \
	--filter="NAME=cloudresourcemanager.googleapis.com" \
	--format="value(NAME)" \
)

ENABLE_RESOURCE_MANAGER_API=$$( \
	gcloud services enable \
	cloudresourcemanager.googleapis.com \
	--project $(PASSED_PROJECT_NAME) \
)

GCP_CREDENTIALS_PATH:=./terraform_modules/secrets/$(PASSED_PROJECT_NAME)_service_account_secret_key.json

.PHONY: all
all: login \
create_project \
activate_project \
make_service_account \
make_sa_editor \
get_and_store_service_account_key \
enable_resource_manager_api

login:
	@if [ "$(CURRENT_ACCOUNT)" != "$(PASSED_ACCOUNT)" ];\
	then gcloud auth login;\
	else echo "already logged in";\
	fi

create_project: login
	@if [ "$(EXISTING_PROJECT_NAME)" != "$(PASSED_PROJECT_NAME)" ];\
	then gcloud projects create \
		$(PASSED_PROJECT_NAME) \
		--labels=type=practice;\
	else echo "project already exists";\
	fi

activate_project: login
	@if [ "$(ACTIVE_PROJECT)" != "$(PASSED_PROJECT_NAME)" ];\
	then gcloud config set project $(PASSED_PROJECT_NAME);\
	else echo "project already activated";\
	fi

make_service_account: login
	@if [ "$(SERVICE_ACCOUNT_NAME)" = "" ];\
	then gcloud iam service-accounts create \
		$(PASSED_PROJECT_NAME) \
		--description="service account for $(PASSED_PROJECT_NAME)" \
		--display-name="$(PASSED_PROJECT_NAME)-service-account";\
	else echo "service account already exists";\
	fi

make_sa_editor: login
	@if ! echo $(SERVICE_ACCOUNT_ROLES) | grep -q "roles/owner";\
	then gcloud projects add-iam-policy-binding \
		$(PASSED_PROJECT_NAME) \
		--member serviceAccount:$(SERVICE_ACCOUNT_EMAIL) \
		--role "roles/owner";\
	else echo "owner role already attached";\
	fi

# is it okay to store locally? How can I authenticate service account without storing a secret?
get_and_store_service_account_key: login
	@if ! [ -f $(GCP_CREDENTIALS_PATH) ];\
	then gcloud iam service-accounts keys create \
		$(GCP_CREDENTIALS_PATH) \
		--iam-account $(SERVICE_ACCOUNT_EMAIL);\
	else echo "some file already present in $(GCP_CREDENTIALS_PATH)";\
	fi

enable_resource_manager_api: login
	@if [ "$(RESOURCE_MANAGER)" = "" ];\
	then $(ENABLE_RESOURCE_MANAGER_API);\
	else echo "resource manager api already enabled";\
	fi
