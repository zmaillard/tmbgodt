import gleam/list
import tmbgodt/database
import tmbgodt/error.{type AppError}

pub type Context {
  Context(db: database.Connection)
}

pub fn key_find(list: List(#(k, v)), key: k) -> Result(v, AppError) {
    list
    |> list.key_find(key)
    |> result.replace_error(error.UnprocessableEntity)
}
