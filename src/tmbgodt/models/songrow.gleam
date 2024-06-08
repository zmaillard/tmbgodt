import tmbgodt/song.{type Song}

pub type SongRow {
  SongRow(song: Song, is_authenticated: Bool)
}
