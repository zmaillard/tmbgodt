// DO NOT EDIT: Code generated by matcha from song.matcha

import gleam/string_builder.{type StringBuilder}
import gleam/list
import gleam/int
import tmbgodt/song.{type Song}
import tmbgodt/day
import wisp

pub fn render_builder(songs songs: List(Song)) -> StringBuilder {
  let builder = string_builder.from_string("")
  let builder =
    string_builder.append(
      builder,
      "
",
    )
  let builder =
    string_builder.append(
      builder,
      "


<div class=\"relative overflow-x-auto\">
    <table class=\"w-full text-sm text-left rtl:text-right text-gray-500 dark:text-gray-400\">
        <thead class=\"text-xs text-gray-700 uppercase bg-gray-50 dark:bg-gray-700 dark:text-gray-400\">
        <tr>
          <th scope=\"col\" class=\"px-6 py-3\">Day</th>
          <th scope=\"col\" class=\"px-6 py-3\">Song</th>
          <th scope=\"col\" class=\"px-6 py-3\">Album</th>
          <th scope=\"col\" class=\"px-6 py-3\">Year</th>
        </tr>
    </thead>
    <tbody>
    ",
    )
  let builder =
    list.fold(songs, builder, fn(builder, song: Song) {
      let builder =
        string_builder.append(
          builder,
          "
     <tr class=\"bg-white border-b dark:bg-gray-800 dark:border-gray-700\">
        <th scope=\"row\" class=\"px-6 py-4 font-medium text-gray-900 whitespace-nowrap dark:text-white\">",
        )
      let builder =
        string_builder.append(builder, day.convert_day_to_date(song.day))
      let builder =
        string_builder.append(
          builder,
          "</th>
        <td class=\"px-6 py-4\">",
        )
      let builder = string_builder.append(builder, song.name)
      let builder =
        string_builder.append(
          builder,
          "</td>
        <td class=\"px-6 py-4\">",
        )
      let builder = string_builder.append(builder, song.album_name)
      let builder =
        string_builder.append(
          builder,
          "</td>
        <td class=\"px-6 py-4\">",
        )
      let builder = string_builder.append(builder, int.to_string(song.year))
      let builder =
        string_builder.append(
          builder,
          "</td>
    </tr>
    ",
        )

      builder
    })
  let builder =
    string_builder.append(
      builder,
      "
    </tbody>
</table>
</div>",
    )

  builder
}

pub fn render(songs songs: List(Song)) -> String {
  string_builder.to_string(render_builder(songs: songs))
}
