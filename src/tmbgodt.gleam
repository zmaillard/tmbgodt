import gleam/erlang/os
import gleam/erlang/process
import gleam/int
import gleam/result
import mist
import tmbgodt/database
import tmbgodt/models/auth
import tmbgodt/router
import tmbgodt/web.{Context}
import wisp

pub fn main() {
  wisp.configure_logger()

  let port = load_port()
  let secret_key = load_secret_key()

  let version_number = os.get_env("APP_VERSION") |> result.unwrap("1.0.0")
  let assert Ok(domain) = os.get_env("AUTH0_DOMAIN")
  let assert Ok(client_id) = os.get_env("AUTH0_CLIENTID")
  let assert Ok(callback) = os.get_env("AUTH0_CALLBACK")

  let auth = auth.Auth(domain, client_id, callback)

  let handle_request = fn(req) {
    use db <- database.with_connection()
    let ctx =
      Context(
        db: db,
        auth: auth,
        static_directory: static_directory(),
        version_number: version_number,
      )
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

fn static_directory() -> String {
  let assert Ok(priv_directory) = wisp.priv_directory("tmbgodt")

  priv_directory <> "/static"
}
