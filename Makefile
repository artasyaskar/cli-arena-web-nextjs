.PHONY: clean setup build serve test lint

clean:
	rm -rf node_modules package-lock.json .next

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
