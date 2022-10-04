


dev-setup: .git/hooks/pre-commit


.git/hooks/pre-commit:
	cp scripts/pre-commit .git/hooks/pre-commit
	chmod +x .git/hooks/pre-commit

:PHONY lint
lint:
	$(info linting Dockerfile with hadolint...)
	docker run --rm -i hadolint/hadolint < Dockerfile

:PHONY fmt
fmt:
	$(info format code but pending formater...)
