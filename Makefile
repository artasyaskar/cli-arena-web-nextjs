# Makefile for the cli-arena-web-nextjs project

# Stop if any command fails
.SHELLFLAGS = -ec

# Default target
all: setup build test lint

# Install dependencies and initialize DB
setup:
	docker-compose run --rm web sh -c "npm install --legacy-peer-deps"
	docker-compose run --rm web sh -c "npx prisma migrate dev --name init || npx prisma migrate reset --force"
	docker-compose run --rm web sh -c "npm run db:seed"

# Build the app using Docker
build:
	docker-compose build

# Serve app and services in background
serve:
	docker-compose up -d

# Stop all running containers
stop:
	docker-compose down

# Run test suite inside container
test:
	docker-compose exec web npm run test

# Run linter inside container
lint:
	docker-compose run --rm web sh -c "npm install --legacy-peer-deps && npm run lint"

# Optional: force-reset Prisma schema & re-seed (⚠️ destructive)
prisma-reset:
	docker-compose run --rm web sh -c "\
		npx prisma migrate reset --force && \
		npx prisma generate && \
		npm run db:seed"


.PHONY: all setup build serve stop test lint prisma-reset
