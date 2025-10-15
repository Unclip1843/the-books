.PHONY: up build down logs tenant-build

build:
	@if [ "$${TENANT_BASE_FORCE}" = "1" ]; then \
		docker compose --profile build-only build tenant-base-build; \
	fi
	docker compose build

up:
	docker compose up -d

down:
	docker compose down

logs:
	docker compose logs -f supervisor

tenant-build:
	docker compose --profile build-only build tenant-base-build
