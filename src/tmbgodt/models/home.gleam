import tmbgodt/album.{type Album}
import tmbgodt/models/songs.{type Songs}
import tmbgodt/song.{type Song}

pub type Home {
  Home(songs: Songs, albums: List(Album), is_authenticated: Bool)
}
