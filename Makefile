# Usage: make plan ENV=dev      make apply ENV=prod      make plan ENV=management
ENV ?= dev
TF  ?= terraform

ifeq ($(ENV),management)
ROOT     := live/management
VAR_FILE :=
else
ROOT     := live/workload
VAR_FILE := -var-file=envs/$(ENV).tfvars
endif

.PHONY: backend init plan apply fmt validate test

backend: ## Generate backend configs from environments.yaml
	python scripts/gen_backend.py

init: backend ## Initialise the chosen environment (-reconfigure because workload envs share a root)
	$(TF) -chdir=$(ROOT) init -reconfigure -backend-config=backend/$(ENV).hcl

plan: init ## Write a plan file for review
	$(TF) -chdir=$(ROOT) plan $(VAR_FILE) -out=$(ENV).tfplan

apply: ## Apply the reviewed plan file, never a fresh plan
	$(TF) -chdir=$(ROOT) apply $(ENV).tfplan

fmt:
	$(TF) fmt -recursive

validate:
	@for dir in modules/* live/management live/workload; do \
		echo "== $$dir"; \
		$(TF) -chdir=$$dir init -backend=false -input=false >/dev/null && $(TF) -chdir=$$dir validate || exit 1; \
	done

test:
	python -m pytest -q tests
