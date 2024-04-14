// DO NOT EDIT: Code generated by matcha from songs.matcha

import gleam/string_builder.{type StringBuilder}
import gleam/list
import tmbgodt/templates/song as song_template
import tmbgodt/models/home.{type Home}
import tmbgodt/album.{type Album}
import gleam/int

pub fn render_builder(home home: Home) -> StringBuilder {
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

<div id=\"songs\">
",
    )
  let builder =
    string_builder.append_builder(
      builder,
      song_template.render_builder(home.songs),
    )
  let builder =
    string_builder.append(
      builder,
      "
</div>
  ",
    )
  let builder = case home.is_authenticated {
    True -> {
      let builder =
        string_builder.append(
          builder,
          "
  <section class=\"section\">
    <div class=\"container\">
      <form 
      method=\"POST\" 
      hx-post=\"/song\" 
      hx-target=\"#songs\"
      enctype=\"multipart/form-data\">
      <div class=\"select is-link\">
  <select name=\"album\">
          ",
        )
      let builder =
        list.fold(home.albums, builder, fn(builder, album: Album) {
          let builder =
            string_builder.append(
              builder,
              "
          <option value=",
            )
          let builder = string_builder.append(builder, int.to_string(album.id))
          let builder = string_builder.append(builder, ">")
          let builder = string_builder.append(builder, album.name)
          let builder =
            string_builder.append(
              builder,
              "</option>
          ",
            )

          builder
        })
      let builder =
        string_builder.append(
          builder,
          "
  </select>
    <input class=\"control\" type=\"text\" name=\"song\" />
<button class=\"button\" type=\"submit\">Add Song</button>
</form>
</div>
    </div>
  </section>
  ",
        )

      builder
    }
    False -> {
      let builder =
        string_builder.append(
          builder,
          "
  ",
        )

      builder
    }
  }

  builder
}

pub fn render(home home: Home) -> String {
  string_builder.to_string(render_builder(home: home))
}