import birl
import gleam/dynamic
import gleam/pgo
import gleam/result
import tmbgodt/error.{type AppError}

pub type Song {
  Song(id: Int, day: birl.Day, name: String, album_name: String, year: Int)
}

fn song_row_decoder() -> dynamic.Decoder(Song) {
  dynamic.decode5(
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
         album.year
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
         album.year
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
  db: pgo.Connection,
) -> Result(Int, AppError) {
  let sql =
    "
    insert into songs
      (name, album_id, day, inserted_at, updated_at)
    SELECT $1, $2, max(day) + 1, now(), now()
      FROM songs
    returning
     id
        "

  use results <- result.then(
    pgo.execute(
      sql,
      db,
      [pgo.text(name), pgo.int(album_id)],
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
