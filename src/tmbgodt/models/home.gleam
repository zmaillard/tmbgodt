import tmbgodt/album.{type Album}
import tmbgodt/song.{type Song}

pub type Home {
  Home(songs: List(Song), albums: List(Album), is_authenticated: Bool)
}
