import gleam/erlang/process
import gleam/erlang/os
import gleam/int
import gleam/result
import wisp
import mist
import tmbgodt/database
import tmbgodt/router
import tmbgodt/web.{Context}

fn database_name() {
  case os.get_env("DATABASE_PATH") {
    Ok(path) -> path
    Error(Nil) -> "tmbg.sqlite"
  }
}

pub fn main() {
  wisp.configure_logger()

  let port = load_port()
  let secret_key = load_secret_key()

  let handle_request = fn(req) {
    let assert Ok(_) = database.with_connection(database_name(), database.empty)
    use db <- database.with_connection(database_name())
    let ctx = Context(db: db)
    router.handle_request(req, ctx)
  }

  let assert Ok(_) =
    wisp.mist_handler(handle_request, secret_key)
    |> mist.new
    |> mist.port(port)
    |> mist.start_http

  process.sleep_forever()
}

fn load_port() -> Int {
  os.get_env("PORT")
  |> result.then(int.parse)
  |> result.unwrap(3000)
}

fn load_secret_key() -> String {
  os.get_env("SECRET_KEY")
  |> result.unwrap("2B08C3E458998CEF6088F84C036D85B95F6982C282F1B7")
}
