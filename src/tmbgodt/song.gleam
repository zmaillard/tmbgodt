import birl
import gleam/dynamic.{field, string}
import gleam/hackney
import gleam/http.{Post}
import gleam/http/request
import gleam/json
import gleam/option.{type Option, None, Some}
import gleam/pgo
import gleam/result
import tmbgodt/error.{type AppError}

pub type Song {
  Song(
    id: Int,
    day: birl.Day,
    name: String,
    album_name: String,
    year: Int,
    songwhip_url: Option(String),
  )
}

type SongwhipUrl {
  SongwhipUrl(url: String)
}

fn songwhip_request_json(apple_music_url: String) -> String {
  json.object([#("url", json.string(apple_music_url))])
  |> json.to_string
}

fn songwhip_response_to_url(json_response: String) -> Option(String) {
  let song_decoder = dynamic.decode1(SongwhipUrl, field("url", of: string))

  let json_res = json.decode(from: json_response, using: song_decoder)

  case json_res {
    Ok(j) -> Some(j.url)
    _ -> None
  }
}

pub fn songwhip_url(apple_music_url: String) -> Option(String) {
  let req =
    request.new()
    |> request.set_method(Post)
    |> request.set_host("songwhip.com")
    |> request.set_body(songwhip_request_json(apple_music_url))

  let assert Ok(resp) = hackney.send(req)

  songwhip_response_to_url(resp.body)
}

fn song_row_decoder() -> dynamic.Decoder(Song) {
  dynamic.decode6(
    Song,
    dynamic.element(0, dynamic.int),
    dynamic.element(
      1,
      dynamic.decode3(
        birl.Day,
        dynamic.element(0, dynamic.int),
        dynamic.element(1, dynamic.int),
        dynamic.element(2, dynamic.int),
      ),
    ),
    dynamic.element(2, dynamic.string),
    dynamic.element(3, dynamic.string),
    dynamic.element(4, dynamic.int),
    dynamic.element(5, dynamic.optional(dynamic.string)),
  )
}

pub fn song_by_id(db: pgo.Connection, song_id: Int) -> Song {
  let sql =
    "
    select
         songs.id,
         songs.day,
         songs.name,
         album.name,
         album.year,
         songs.songwhip
       from
         songs
       inner join album on songs.album_id = album.id
       where songs.id = $1
       "

  let assert Ok(returned) =
    pgo.execute(sql, db, [pgo.int(song_id)], song_row_decoder())

  let assert [row] = returned.rows

  row
}

pub fn all_songs(db: pgo.Connection) -> List(Song) {
  let sql =
    "
    select
         songs.id,
         songs.day,
         songs.name,
         album.name,
         album.year,
         songs.songwhip
       from
         songs
       inner join album on songs.album_id = album.id
       order by
        songs.day
    "

  let assert Ok(returned) = pgo.execute(sql, db, [], song_row_decoder())

  returned.rows
}

pub fn update_song(
  name: String,
  album_id: Int,
  song_id: Int,
  db: pgo.Connection,
) -> Result(Int, AppError) {
  let sql =
    "
  update songs
    SET name = $1, album_id = $2, updated_at = now()
    WHERE id = $3
  returning
   id
      "

  use results <- result.then(
    pgo.execute(
      sql,
      db,
      [pgo.text(name), pgo.int(album_id), pgo.int(song_id)],
      dynamic.element(0, dynamic.int),
    )
    |> result.map_error(fn(error) {
      case error {
        _ -> error.Database
      }
    }),
  )

  let assert [id] = results.rows
  Ok(id)
}

pub fn insert_song(
  name: String,
  album_id: Int,
  songwhip_url: Option(String),
  db: pgo.Connection,
) -> Result(Int, AppError) {
  let sql =
    "
    insert into songs
      (name, album_id, songwhip, day, inserted_at, updated_at)
    SELECT $1, $2, $3, max(day) + 1, now(), now()
      FROM songs
    returning
     id
        "

  use results <- result.then(
    pgo.execute(
      sql,
      db,
      [pgo.text(name), pgo.int(album_id), pgo.nullable(pgo.text, songwhip_url)],
      dynamic.element(0, dynamic.int),
    )
    |> result.map_error(fn(error) {
      case error {
        _ -> error.Database
      }
    }),
  )

  let assert [id] = results.rows
  Ok(id)
}
