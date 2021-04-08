webapi_dir = src/webapi

.PHONY: install
install :
	npm install --prefix $(webapi_dir)

.PHONY: test
test : build
	npm run test --prefix $(webapi_dir)

.PHONY: start
start : build
	npm run start --prefix $(webapi_dir)

.PHONY: clean
clean :
	rm -r $(webapi_dir)/node_modules

.PHONY: build
# TODO: Add your application build process here.

.PHONY: migrate_db
migrate_db :
	npm run migrate_db --prefix $(webapi_dir)

.PHONY: seed_db
seed_db : migrate_db
	npm run seed_db --prefix $(webapi_dir)

.PHONY: remove_db
remove_db :
	dropdb postgres && createdb postgres

.PHONY: zip_it
zip_it : build
	cd src/webapi; zip -r ../../webapi.zip .