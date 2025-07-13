.PHONY: clean setup build serve test lint

clean:
	@echo "Cleaning up node_modules and build artifacts..."
	@rm -rf node_modules .next package-lock.json || true
	@find node_modules -type d -name 'build' -exec rm -rf {} + || true

setup: clean
	npm install
	./db/check-and-migrate.sh
	npx prisma db seed

build:
	npm run build

serve:
	npm run dev

test:
	npm run test

lint:
	npm run lint
