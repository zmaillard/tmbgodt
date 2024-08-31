import tmbgodt/album.{type Album}
import tmbgodt/models/songs.{type Songs}

pub type Home {
  Home(songs: Songs, albums: List(Album), is_authenticated: Bool)
}
