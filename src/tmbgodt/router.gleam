import gleam/http
import gleam/int
import tmbgodt/web.{type Context}
import tmbgodt/album
import tmbgodt/error
import tmbgodt/song.{Song}
import tmbgodt/models/home.{Home}
import wisp.{type Request, type Response}
import tmbgodt/templates/home as home_template
import tmbgodt/templates/song as song_template
import gleam/result

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

  let res = {
    use song_name <- result.try(web.key_find(params.values, "song"))
    use album <- result.try(web.key_find(params.values, "album"))
    use album_id <- result.try(
      int.parse(album)
      |> result.replace_error(error.InvalidAlbum),
    )

    use id <- result.try(song.insert_song(song_name, album_id, ctx.db))

    Ok(id)
  }

  let assert Ok(_) = res
  let songs = song.all_songs(ctx.db)

  song_template.render_builder(songs)
  |> wisp.html_response(201)
}

fn song(req: Request, ctx: Context) -> Response {
  case req.method {
    http.Post -> create_song(req, ctx)
    _ -> wisp.method_not_allowed([http.Post])
  }
}

fn home(ctx: Context) -> Response {
  let albums = album.all_albums(ctx.db)
  let songs = song.all_songs(ctx.db)

  let home = Home(songs, albums)

  home_template.render_builder(home)
  |> wisp.html_response(200)
}
