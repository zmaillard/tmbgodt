import tmbgodt/song.{type Song}
import tmbgodt/album.{type Album}

pub type Home {
  Home(songs: List(Song), albums: List(Album))
}
