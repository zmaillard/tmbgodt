import gleam/erlang/os
import gleam/option.{Some}
import gleam/pgo

fn postgres_config() -> pgo.Config {
  let assert Ok(host) = os.get_env("POSTGRES_HOST")
  let assert Ok(database) = os.get_env("POSTGRES_DB")
  let assert Ok(user) = os.get_env("POSTGRES_USER")
  let assert Ok(password) = os.get_env("POSTGRES_PASS")
  pgo.Config(
    ..pgo.default_config(),
    host: host,
    database: database,
    user: user,
    password: Some(password),
  )
}

pub fn connect() -> pgo.Connection {
  pgo.connect(postgres_config())
}

pub fn with_connection(f: fn(pgo.Connection) -> t) -> t {
  let connection = pgo.connect(postgres_config())

  let result = f(connection)

  result
}
