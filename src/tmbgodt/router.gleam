import gleam/http
import tmbgodt/web.{type Context}
import tmbgodt/album
import wisp.{type Request, type Response}
import tmbgodt/templates/home as home_template

pub fn handle_request(req: Request, ctx: Context) {
  let req = wisp.method_override(req)
  use <- wisp.log_request(req)
  use <- wisp.rescue_crashes
  use req <- wisp.handle_head(req)
  //use ctx <- <- web.authenticate(req,ctx)

  case wisp.path_segments(req) {
    [] -> home(ctx)
    ["song"] -> song(req, ctx)
    _ -> wisp.not_found()
  }
}


fn create_song(request: Request, ctx: Context) -> Response {
  use params <- wisp.require_form(request)

  let _ = {
      use song <- result.try(web.key_find(params.values, "song"))
      use album <- result.try(web.key_find(params.values, "album"))
    
      use id <- result.try(song.insert_song(song, album, ctx.db))

      Ok(Song(day: id, name: song, album: album))
  }

    wisp.ok()
}

fn song(req: Request, ctx: Context) -> Response {
    case req.method {
        http.Post -> create_song(req, ctx)
        _ -> wisp.method_not_allowed([http.Post])
    }
}

fn home(ctx: Context) -> Response {
  let items = album.all_albums(ctx.db)

  home_template.render_builder(items)
  |> wisp.html_response(200)
}
