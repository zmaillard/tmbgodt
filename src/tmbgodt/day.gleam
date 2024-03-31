import birl
import birl/duration

const jan_one_2024 = birl.Day(2024, 1, 1)

pub fn convert_day_to_date(day: Int) -> String {
  birl.add(get_first_day_of_2024(), duration.days(day - 1))
  |> birl.to_naive_date_string
}

fn get_first_day_of_2024() -> birl.Time {
  birl.now()
  |> birl.set_time_of_day(birl.TimeOfDay(0, 0, 0, 0))
  |> birl.set_day(jan_one_2024)
}
