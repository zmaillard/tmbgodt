import sqlight
import gleam/result.{try}
import gleam/dynamic.{field, string}
import gleam/json
import gleam/option.{type Option, None, Some}
import tmbgodt/error.{type AppError}
import gleam/hackney
import gleam/http.{Post}
import gleam/http/request

pub type Song {
  Song(day: Int, name: String, album_name: String, year: Int)
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
  dynamic.decode4(
    Song,
    dynamic.element(0, dynamic.int),
    dynamic.element(1, dynamic.string),
    dynamic.element(2, dynamic.string),
    dynamic.element(3, dynamic.int),
  )
}

pub fn all_songs(db: sqlight.Connection) -> List(Song) {
  let sql =
    "
      select
        song.day,
        song.name,
        album.name,
        album.year
      from
        song
      inner join album on song.albumId = album.id
      order by
       song.day
    "

  let assert Ok(rows) =
    sqlight.query(sql, on: db, with: [], expecting: song_row_decoder())

  rows
}

pub fn insert_song(
  name: String,
  album_id: Int,
  songwhip_url: Option(String),
  db: sqlight.Connection,
) -> Result(Int, AppError) {
  let sql =
    "
      insert into song
        (name, albumId, songwhipUrl)
      values
        (?1, ?2, ?3)
      returning
       day
        "

  use rows <- result.then(
    sqlight.query(
      sql,
      on: db,
      with: [
        sqlight.text(name),
        sqlight.int(album_id),
        sqlight.nullable(sqlight.text, songwhip_url),
      ],
      expecting: dynamic.element(0, dynamic.int),
    )
    |> result.map_error(fn(error) {
      case error.code, error.message {
        _, _ -> error.Database
      }
    }),
  )

  //TODO: Add detail
  let assert [id] = rows
  Ok(id)
}
