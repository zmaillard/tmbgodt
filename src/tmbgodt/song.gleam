pub type Song {
  Song(day: Int, name: String, album: Int)
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
        id
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
        _, _ -> error.BadRequest //TODO: Add detail
      }
    }),
  )

  let assert [id] = rows
  Ok(id)
}
