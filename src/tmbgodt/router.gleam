import gleam/http
import gleam/list
import gleam/int
import gleam/io
import gleam/erlang/os
import tmbgodt/web.{type Context}
import tmbgodt/album
import tmbgodt/error
import tmbgodt/song.{Song}
import tmbgodt/models/home.{Home}
import tmbgodt/models/albumedit.{AlbumEdit}
import wisp.{type Request, type Response}
import tmbgodt/templates/home as home_template
import tmbgodt/templates/album as album_template
import tmbgodt/templates/albums as albums_template
import tmbgodt/templates/song as song_template
import tmbgodt/models/auth
import gleam/result

const cookie_name = "tmbgid"

const state_cookie = "state"

pub fn handle_request(req: Request, ctx: Context) {
  let req = wisp.method_override(req)
  use <- wisp.log_request(req)
  use <- wisp.rescue_crashes
  use req <- wisp.handle_head(req)

  case wisp.path_segments(req) {
    [] -> home(ctx)
    ["login"] -> login(req, ctx)
    ["callback"] -> callback(req)
    ["song"] -> song(req, ctx)
    ["album"] -> album(req, ctx)
    _ -> wisp.not_found()
  }
}

fn callback(req: Request) -> Response {
  let vals = wisp.get_query(req)

  let result = {
    let code = list.key_find(vals, "code")
    let state = list.key_find(vals, "state")
    let orig_state = wisp.get_cookie(req, state_cookie, wisp.Signed)
    let user_id = os.get_env("USER_ID")

    io.debug(code)
    io.debug(state)
    io.debug(orig_state)
    io.debug(user_id)
    case code, state, orig_state, user_id {
      Ok(_), Ok(state), Ok(orig_state), Ok(user_id) if state == orig_state ->
        Ok(user_id)
      _, _, _, _ -> Error("missing code or state")
    }
  }

  case result {
    Ok(uid) ->
      wisp.redirect("/")
      |> wisp.set_cookie(req, cookie_name, uid, wisp.Signed, 60 * 60 * 24)
    Error(_) ->
      wisp.redirect("/")
      |> wisp.set_cookie(req, cookie_name, "", wisp.Signed, 0)
  }
}

fn login(req: Request, ctx: Context) -> Response {
  let random_state = "abcd"

  let resp = wisp.redirect(auth.build_auth_url(random_state, ctx.auth))
  wisp.set_cookie(
    resp,
    req,
    state_cookie,
    random_state,
    wisp.PlainText,
    60 * 60,
  )
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

fn album(req: Request, ctx: Context) -> Response {
  case req.method {
    http.Post -> create_album(req, ctx)
    http.Get -> get_album(ctx)
    _ -> wisp.method_not_allowed([http.Post, http.Get])
  }
}

fn create_album(req: Request, ctx: Context) -> Response {
  use params <- wisp.require_form(req)

  let res = {
    use album_name <- result.try(web.key_find(params.values, "album_name"))
    use album_year <- result.try(web.key_find(params.values, "album_year"))
    use year <- result.try(
      int.parse(album_year)
      |> result.replace_error(error.InvalidAlbum),
    )

    use album_type <- result.try(web.key_find(params.values, "album_type"))
    use album_type_id <- result.try(
      int.parse(album_type)
      |> result.replace_error(error.InvalidAlbum),
    )

    use id <- result.try(album.insert_album(
      album_name,
      year,
      album_type_id,
      ctx.db,
    ))

    Ok(id)
  }

  let assert Ok(_) = res
  let albums = album.all_albums(ctx.db)

  album_template.render_builder(albums)
  |> wisp.html_response(201)
}

fn get_album(ctx: Context) -> Response {
  let albums = album.all_albums(ctx.db)
  let album_types = album.all_album_types(ctx.db)

  albums_template.render_builder(AlbumEdit(albums, album_types))
  |> wisp.html_response(200)
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
