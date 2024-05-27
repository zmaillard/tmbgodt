import gleam/dynamic
import gleam/pgo
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

pub fn all_album_types(db: pgo.Connection) -> List(AlbumType) {
  let sql =
    "
        SELECT id, name
        FROM album_type
        "
  let assert Ok(results) = pgo.execute(sql, db, [], album_type_row_decoder())

  results.rows
}

pub fn all_albums(db: pgo.Connection) -> List(Album) {
  let sql =
    "
        SELECT album.id, album.name, album.year, album_type.name
        FROM album
        INNER JOIN album_type ON album.album_type_id = album_type.id
        order by album.year
        "
  let assert Ok(results) = pgo.execute(sql, db, [], album_row_decoder())

  results.rows
}

pub fn insert_album(
  name: String,
  year: Int,
  album_type: Int,
  db: pgo.Connection,
) -> Result(Int, AppError) {
  let sql =
    "
      insert into album
        (name, year, album_type_id, inserted_at, updated_at)
      values
        (?1, ?2, ?3, now(), now())
      returning
       id
        "
  use results <- result.then(
    pgo.execute(
      sql,
      db,
      [pgo.text(name), pgo.int(year), pgo.int(album_type)],
      dynamic.element(0, dynamic.int),
    )
    |> result.map_error(fn(error) {
      case error {
        _ -> error.Database
      }
    }),
  )

  //TODO: Add detail
  let assert [id] = results.rows
  Ok(id)
}
