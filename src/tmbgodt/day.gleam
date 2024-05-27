import birl

pub fn to_day_string(day: birl.Day) -> String {
  let birl.Day(year, month, day) = day
  birl.from_erlang_local_datetime(#(#(year, month, day), #(12, 0, 0)))
  |> birl.to_naive_date_string
}
