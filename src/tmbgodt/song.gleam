import birl
import gleam/dynamic.{field, string}
import gleam/hackney
import gleam/http.{Post}
import gleam/http/request
import gleam/json
import gleam/option.{type Option, None, Some}
import gleam/pgo
import gleam/result.{try}
import tmbgodt/error.{type AppError}

pub type Song {
  Song(
    day: #(Int, Int, Int),
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
  dynamic.decode5(
    Song,
    dynamic.element(0, dynamic.tuple3(dynamic.int, dynamic.int, dynamic.int)),
    dynamic.element(1, dynamic.string),
    dynamic.element(2, dynamic.string),
    dynamic.element(3, dynamic.int),
    dynamic.element(4, dynamic.optional(dynamic.string)),
  )
}

pub fn all_songs(db: pgo.Connection) -> List(Song) {
  let sql =
    "
    select
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
// pub fn convert_time(time: Time) -> pgo.Value {
//   time
//   |> birl.to_erlang_universal_datetime()
//   |> dynamic.from()
//   |> dynamic.unsafe_coerce()
// }

// pub fn decode_time(data: Dynamic) {
//   data
//   |> dynamic.tuple2(decode_time_tuple, decode_time_tuple)
//   |> result.map(birl.from_erlang_universal_datetime)
// }

// fn rounded_float(data: Dynamic) {
//   data
//   |> dynamic.float()
//   |> result.map(float.round)
// }
