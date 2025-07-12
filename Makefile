.PHONY: setup build serve test lint

setup:
	npm install
	npx prisma migrate dev --name init
	npx prisma db seed

build:
	npm run build

serve:
	npm run dev

test:
	npm run test

lint:
	npm run lint
