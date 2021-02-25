.DEFAULT_GOAL := help

SUPPORTED_COMMANDS := ansible contributors git linter
SUPPORTS_MAKE_ARGS := $(findstring $(firstword $(MAKECMDGOALS)), $(SUPPORTED_COMMANDS))
ifneq "$(SUPPORTS_MAKE_ARGS)" ""
  COMMAND_ARGS := $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))
  $(eval $(COMMAND_ARGS):;@:)
endif

.PHONY: help
help:
	@grep -E '(^[a-zA-Z_-]+:.*?##.*$$)|(^##)' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[32m%-30s\033[0m %s\n", $$1, $$2}' | sed -e 's/\[32m##/[33m/'

node_modules:
	@npm install

.PHONY: ansible
ansible: ## Scripts GIT
ifeq ($(COMMAND_ARGS),localhost)
	@ansible-playbook localhost.yml
else ifeq ($(COMMAND_ARGS),servers)
	@ansible-playbook servers.yml
else
	@echo "ARGUMENT missing"
	@echo "---"
	@echo "make ansible ARGUMENT"
	@echo "---"
	@echo "check: CHECK before"
endif

.PHONY: install
install: node_modules ## Installation application

.PHONY: contributors
contributors: node_modules ## Contributors
ifeq ($(COMMAND_ARGS),add)
	@npm run contributors add
else ifeq ($(COMMAND_ARGS),check)
	@npm run contributors check
else ifeq ($(COMMAND_ARGS),generate)
	@npm run contributors generate
else
	@npm run contributors
endif

.PHONY: git
git: node_modules ## Scripts GIT
ifeq ($(COMMAND_ARGS),check)
	@make contributors check -i
	@make linter readme -i
	@git status
else
	@echo "ARGUMENT missing"
	@echo "---"
	@echo "make git ARGUMENT"
	@echo "---"
	@echo "check: CHECK before"
endif

.PHONY: linter
linter: node_modules ## Scripts Linter
ifeq ($(COMMAND_ARGS),readme)
	@npm run linter-markdown README.md
else
	@echo "ARGUMENT missing"
	@echo "---"
	@echo "make linter ARGUMENT"
	@echo "---"
	@echo "readme: linter README.md"
endif