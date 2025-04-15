# Makefile

.PHONY: up init install down reset

up:
	docker compose up -d

init:
	@echo "🔧 Running WordPress install (only if needed)..."
	./setup.sh

install: up init

down:
	docker compose down

reset:
	docker compose down -v
