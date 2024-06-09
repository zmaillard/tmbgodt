import gleam/erlang/os
import gleam/list
import gleam/pgo
import gleam/result
import tmbgodt/error.{type AppError}
import tmbgodt/models/auth.{type Auth}
import wisp.{type Response}

const cookie_name = "tmbgid"

pub type Context {
  Context(
    db: pgo.Connection,
    auth: Auth,
    static_directory: String,
    version_number: String,
  )
}

pub fn is_authenticated(req: wisp.Request) -> Bool {
  let is_debug = case os.get_env("DEBUG") {
    Ok("true") -> True
    _ -> False
  }

  case is_debug {
    True -> True
    False -> {
      let user_cookie = wisp.get_cookie(req, cookie_name, wisp.Signed)
      let user_id = os.get_env("USER_ID")

      case user_cookie, user_id {
        Ok(user_cookie), Ok(user_id) if user_cookie == user_id -> True
        _, _ -> False
      }
    }
  }
}

pub fn authentication_middleware(
  req: wisp.Request,
  handle_request: fn() -> wisp.Response,
) -> wisp.Response {
  case is_authenticated(req) {
    True -> handle_request()
    False -> wisp.redirect("/login")
  }
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
