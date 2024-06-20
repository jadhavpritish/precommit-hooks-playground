SHELL := /bin/bash

.PHONY = init clean
PYTHON_VERSION=$(shell cat .python-version)

clean:

	@envs=$$(poetry env list | awk '{print $$1}'); \
	if [ -n "$$envs" ]; then \
		for env in $$envs; do \
			echo "Removing virtual environment at $$env"; \
			poetry env remove "$$env"; \
		done \
	else \
		echo "No virtual environments found."; \
	fi

init:
	@if command -v poetry > /dev/null; then \
		echo "Poetry is installed."; \
		poetry env use $(PYTHON_VERSION) ; \
		if [ pyproject.toml -nt poetry.lock ]; then \
			echo "pyproject.toml has changed. Locking dependencies..."; \
			poetry lock; \
		else \
			echo "pyproject.toml has not changed. No need to lock dependencies."; \
		fi; \
		echo "Initializing environment..."; \
		poetry install; \
	else \
		echo "Poetry is not installed. Please install it using 'brew install poetry'."; \
	fi

	@echo "Installing pre-commit hooks ...."
	poetry run pre-commit install


ruff-check:
	poetry run ruff check

ruff-fix: init
	poetry run ruff check --fix

ruff-format: init
	## Format __ALL__ the .py files in the current directory
	poetry run ruff format