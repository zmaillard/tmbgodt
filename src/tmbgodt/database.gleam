import tmbgodt/error.{type AppError}
import gleam/result
import sqlight

pub type Connection =
  sqlight.Connection

pub fn with_connection(name: String, f: fn(sqlight.Connection) -> a) -> a {
  use db <- sqlight.with_connection(name)
  let assert Ok(_) = sqlight.exec("pragma foreign_keys = on;", db)
  f(db)
}

pub fn empty(_: sqlight.Connection) -> Result(Nil, AppError) {
  Ok(Nil)
}
