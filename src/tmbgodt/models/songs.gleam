import tmbgodt/album.{type Album}
import tmbgodt/song.{type Song}

pub type Songs {
  Songs(songs: List(Song), is_authenticated: Bool)
}
