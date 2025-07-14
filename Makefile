# Makefile for the cli-arena-web-nextjs project

# Stop on all errors
.SHELLFLAGS = -ec

# Default target
all: setup build test

# Install dependencies and initialize the database
setup:
	npm install
	npx prisma migrate dev --name init
	npm run db:seed

# Build the Next.js application
build:
	docker-compose build

# Start the application and its services
serve:
	docker-compose up -d

# Stop the application and its services
stop:
	docker-compose down

# Run the test suite
test:
	npm test
	./tasks/run_all_tests.sh

# Lint the codebase
lint:
	npm run lint

.PHONY: all setup build serve stop test lint
