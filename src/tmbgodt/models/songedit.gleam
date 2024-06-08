import tmbgodt/album.{type Album}
import tmbgodt/song.{type Song}

pub type SongEdit {
  SongEdit(song: Song, albums: List(Album))
}
