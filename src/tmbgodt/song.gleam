import sqlight
import gleam/result
import gleam/dynamic
import tmbgodt/error.{type AppError}

pub type Song {
  Song(day: Int, name: String, album_name: String, year: Int)
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
  db: sqlight.Connection,
) -> Result(Int, AppError) {
  let sql =
    "
      insert into song
        (name, albumId)
      values
        (?1, ?2)
      returning
       day 
        "

  use rows <- result.then(
    sqlight.query(
      sql,
      on: db,
      with: [sqlight.text(name), sqlight.int(album_id)],
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
