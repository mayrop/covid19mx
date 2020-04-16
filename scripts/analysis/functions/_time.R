# -------------------------------------------------------------------------------------

# Usage: add_time_columns(times, "my_time", "etc", tz = "UTC", hours=TRUE, format="%Y-%m-%d %H:%M:%S")

add_time_columns <- function(df, column, prefix, format="%Y-%m-%d", tz="America/Los_Angeles", hours = FALSE) {
  colname <- paste0(prefix, "_std")
  # to create quotation: https://thisisnic.github.io/2018/04/16/how-do-i-make-my-own-dplyr-style-functions/
  # column <- enquo(column)
  #browser()
  df <- df %>%
    dplyr::mutate(
      # remember !! is for evaluating right away
      # remember sym is for converting strings to symbols
      !!colname := as.POSIXct(!!rlang::sym(column), format=format, tz=tz, usetz=TRUE),
      !!paste0(prefix, "_iso") := lubridate::as_date(!!rlang::sym(colname)),
      !!paste0(prefix, "_day") := day(!!rlang::sym(colname)),
      !!paste0(prefix, "_month") := month(!!rlang::sym(colname)),
      !!paste0(prefix, "_month_name") := factor(!!rlang::sym(paste0(prefix, "_month")), levels = 1:12, labels = c("Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec")),
      !!paste0(prefix, "_year") := year(!!rlang::sym(colname)),
      !!paste0(prefix, "_weekday") := wday(!!rlang::sym(colname), week_start = getOption("lubridate.week.start", 7)),
      !!paste0(prefix, "_weekday_name") := factor(!!rlang::sym(paste0(prefix, "_weekday")), levels = 1:7, labels = c("Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat")),
      !!paste0(prefix, "_weekday_name") := forcats::fct_explicit_na(!!rlang::sym(paste0(prefix, "_weekday_name")), na_level = "NA")
    )
  
  if (hours) {
    df <- df %>%
      dplyr::mutate(
        # remember !! is for evaluating right away
        # remember sym is for converting strings to symbols
        # format = "%Y-%m-%d %h:%m"
        !!colname := as.POSIXct(!!rlang::sym(column), format=format, tz=tz, usetz=TRUE),
        !!paste0(prefix, "_hour") := hour(!!rlang::sym(colname)),
        !!paste0(prefix, "_minute") := minute(!!rlang::sym(colname)),
        !!paste0(prefix, "_second") := second(!!rlang::sym(colname))
      )
  }
  
  df
}

# -------------------------------------------------------------------------------------
