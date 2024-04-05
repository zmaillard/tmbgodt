import tmbgodt/album.{type Album, type AlbumType}

pub type AlbumEdit {
  AlbumEdit(albums: List(Album), album_types: List(AlbumType))
}
