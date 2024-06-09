import gleam/string_builder.{type StringBuilder}

pub type Version {
  Version(version_number: String, content: StringBuilder)
}

pub fn append_content(content: StringBuilder, version: String) -> Version {
  Version(version, content)
}
