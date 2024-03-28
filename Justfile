default:
  @just --list

run:
  gleam run

template:
  matcha && gleam format .
