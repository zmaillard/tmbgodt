import gleam/int
import birl
import birl/duration

const jan_one_2024_epoch = 1_704_128_400

pub fn convert_day_to_date(day: Int) -> String {
  birl.add(get_first_day_of_2024(), duration.days(day - 1))
  |> birl.to_naive_date_string
}

fn get_first_day_of_2024() -> birl.Time {
  birl.from_unix(jan_one_2024_epoch)
}
