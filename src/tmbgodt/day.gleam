import birl
import gleam/int

//import birl/duration
import gleam/dynamic

//const jan_one_2024_epoch = 1_704_128_400

// pub fn convert_day_to_date(day: Int) -> String {
//   birl.add(get_first_day_of_2024(), duration.days(day - 1))
//   |> birl.to_naive_date_string
// }

// fn get_first_day_of_2024() -> birl.Time {
//   birl.from_unix(jan_one_2024_epoch)
// }

pub fn to_day_string(day: #(Int, Int, Int)) -> String {
  let #(year, month, day) = day
  int.to_string(year)
  <> "-"
  <> int.to_string(month)
  <> "-"
  <> int.to_string(day)
}

pub fn convert_db_day_to_day() -> dynamic.Decoder(birl.Day) {
  dynamic.decode3(birl.Day, dynamic.int, dynamic.int, dynamic.int)
}
