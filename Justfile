default:
  @just --list

build: matcha template
  gleam build

run: template tailwind
  gleam run

template:
  matcha && gleam format .

matcha:
  cargo install --path matcha

tailwind:
  npx tailwindcss -i ./priv/static/input.css -o ./priv/static/index.css --jit

schema:
  dbmate --url "sqlite:db/tmbg.sqlite" -d "./db/migrations" -s "./db/schema.sql" dump

create-migration MIGRATION_NAME:
  dbmate --url "sqlite:db/tmbg.sqlite" -d "./db/migrations" -s "./db/schema.sql" new {{MIGRATION_NAME}}

db-apply:
  dbmate --url "sqlite:db/tmbg.sqlite" -d "./db/migrations" -s "./db/schema.sql" up

db-rollback:
  dbmate --url "sqlite:db/tmbg.sqlite" -d "./db/migrations" -s "./db/schema.sql" rollback
