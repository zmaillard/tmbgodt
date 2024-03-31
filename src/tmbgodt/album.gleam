import sqlight
import gleam/dynamic
import gleam/result
import tmbgodt/error.{type AppError}

pub type Album {
  Album(id: Int, name: String, year: Int)
}

pub fn album_row_decoder() -> dynamic.Decoder(Album) {
  dynamic.decode3(
    Album,
    dynamic.element(0, dynamic.int),
    dynamic.element(1, dynamic.string),
    dynamic.element(2, dynamic.int),
  )
}

pub fn all_albums(db: sqlight.Connection) -> List(Album) {
  let sql =
    "
        SELECT id, name, year
        FROM album
        "
  let assert Ok(rows) =
    sqlight.query(sql, on: db, with: [], expecting: album_row_decoder())

  rows
}

pub fn insert_album(
  name: String,
  year: Int,
  compilation: Bool,
  db: sqlight.Connection,
) -> Result(Int, AppError) {
  let sql =
    "
      insert into album
        (name, year, compilation)
      values
        (?1, ?2, ?3)
      returning
       id 
        "
  let comp_int = case compilation {
    True -> 1
    False -> 0
  }

  use rows <- result.then(
    sqlight.query(
      sql,
      on: db,
      with: [sqlight.text(name), sqlight.int(year), sqlight.int(comp_int)],
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
