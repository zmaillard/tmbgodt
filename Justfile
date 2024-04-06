default:
  @just --list

run:
  gleam run

template:
  matcha && gleam format .

matcha:
  cargo install --path matcha

tailwind:
  npx tailwindcss -i ./priv/static/input.css -o ./priv/static/index.css --jit