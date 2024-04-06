import sqlight
import gleam/dynamic
import gleam/result
import tmbgodt/error.{type AppError}

pub type Album {
  Album(id: Int, name: String, year: Int, album_type: String)
}

pub type AlbumType {
  AlbumType(id: Int, name: String)
}

pub fn album_row_decoder() -> dynamic.Decoder(Album) {
  dynamic.decode4(
    Album,
    dynamic.element(0, dynamic.int),
    dynamic.element(1, dynamic.string),
    dynamic.element(2, dynamic.int),
    dynamic.element(3, dynamic.string),
  )
}

pub fn album_type_row_decoder() -> dynamic.Decoder(AlbumType) {
  dynamic.decode2(
    AlbumType,
    dynamic.element(0, dynamic.int),
    dynamic.element(1, dynamic.string),
  )
}

pub fn all_album_types(db: sqlight.Connection) -> List(AlbumType) {
  let sql =
    "
        SELECT id, name
        FROM album_type
        "
  let assert Ok(rows) =
    sqlight.query(sql, on: db, with: [], expecting: album_type_row_decoder())

  rows
}

pub fn all_albums(db: sqlight.Connection) -> List(Album) {
  let sql =
    "
        SELECT album.id, album.name, album.year, album_type.name
        FROM album
        INNER JOIN album_type ON album.album_type_id = album_type.id
        order by album.year 
        "
  let assert Ok(rows) =
    sqlight.query(sql, on: db, with: [], expecting: album_row_decoder())

  rows
}

pub fn insert_album(
  name: String,
  year: Int,
  album_type: Int,
  db: sqlight.Connection,
) -> Result(Int, AppError) {
  let sql =
    "
      insert into album
        (name, year, album_type_id)
      values
        (?1, ?2, ?3)
      returning
       id 
        "
  use rows <- result.then(
    sqlight.query(
      sql,
      on: db,
      with: [sqlight.text(name), sqlight.int(year), sqlight.int(album_type)],
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
