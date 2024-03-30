import gleam/list
import gleam/result
import tmbgodt/database
import tmbgodt/error.{type AppError}
import wisp.{type Response}

pub type Context {
  Context(db: database.Connection)
}

pub fn key_find(list: List(#(k, v)), key: k) -> Result(v, AppError) {
  list
  |> list.key_find(key)
  |> result.replace_error(error.UnprocessableEntity)
}

pub fn require_ok(t: Result(t, AppError), next: fn(t) -> Response) -> Response {
  case t {
    Ok(t) -> next(t)
    Error(error) -> error_to_response(error)
  }
}

pub fn error_to_response(_: AppError) -> Response {
  wisp.internal_server_error()
  //Fix responses based on AppError
}
