import sqlight
import gleam/dynamic

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
