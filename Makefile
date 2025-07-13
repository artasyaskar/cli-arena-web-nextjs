.PHONY: setup build serve test lint

setup:
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
