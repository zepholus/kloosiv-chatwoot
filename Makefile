# Variables
APP_NAME := chatwoot
RAILS_ENV ?= development
DOCKER_REPO=zepholus/kloosiv-platform:chatwoot

# Targets
setup:
	gem install bundler
	bundle install
	pnpm install

db_create:
	RAILS_ENV=$(RAILS_ENV) bundle exec rails db:create

db_migrate:
	RAILS_ENV=$(RAILS_ENV) bundle exec rails db:migrate

db_seed:
	RAILS_ENV=$(RAILS_ENV) bundle exec rails db:seed

db_reset:
	RAILS_ENV=$(RAILS_ENV) bundle exec rails db:reset

db: db_create db_migrate
	RAILS_ENV=$(RAILS_ENV) bundle exec rails db:chatwoot_prepare

console:
	RAILS_ENV=$(RAILS_ENV) bundle exec rails console

server:
	RAILS_ENV=$(RAILS_ENV) bundle exec rails server -b 0.0.0.0 -p 3000

burn:
	bundle install
	pnpm install

run:
	@if [ -f ./.overmind.sock ]; then \
		echo "Overmind is already running. Use 'make force_run' to start a new instance."; \
	else \
		overmind start -f Procfile.dev; \
	fi

force_run:
	rm -f ./.overmind.sock
	overmind start -f Procfile.dev

debug:
	overmind connect backend

debug_worker:
	overmind connect worker

docker-build:
	docker build -t $(DOCKER_REPO) -f ./docker/Dockerfile .

docker-push:
	docker push $(DOCKER_REPO)

clean:
	rm -f ./.overmind.sock
	rm -rf tmp/* log/*

help:
	@echo "Available targets:"
	@echo "  setup          Install dependencies"
	@echo "  db_create      Create database"
	@echo "  db_migrate     Run database migrations"
	@echo "  db_seed        Seed database"
	@echo "  db_reset       Reset database"
	@echo "  db             Prepare Chatwoot database"
	@echo "  console        Start Rails console"
	@echo "  server         Start Rails server"
	@echo "  burn           Reinstall dependencies"
	@echo "  run            Start app with Overmind"
	@echo "  force_run      Force start app with Overmind"
	@echo "  debug          Connect to backend via Overmind"
	@echo "  debug_worker   Connect to worker via Overmind"
	@echo "  docker-build   Build Docker image"
	@echo "  docker-push    Push Docker image"
	@echo "  clean          Remove temporary files"

.PHONY: setup db_create db_migrate db_seed db_reset db console server burn docker-build docker-push run force_run debug debug_worker clean help
