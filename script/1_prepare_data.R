dir.create(
  "data/processed",
  recursive = TRUE,
  showWarnings = FALSE
)

raw <- read.csv(
  "data/RPWeekData(1151103).csv",
  fileEncoding = "UTF-8-BOM",
  stringsAsFactors = FALSE,
  check.names = FALSE
)

# Check that required columns exist
stopifnot(
  all(
    c(
      "CASE_T",
      "CASE_F",
      "DISTRICT",
      "UPRICE",
      "TPRICE",
      "FAREA",
      "BUITYPE",
      "SDATE"
    ) %in% names(raw)
  )
)

# Convert ROC year to Gregorian year (ROC + 1911)
# Do not assume that all years are equally represented.

raw$year <- suppressWarnings(
  as.integer(
    substr(as.character(raw$SDATE), 1, 3)
  ) + 1911L
)


keep <- raw$CASE_T == "買賣" &
  raw$CASE_F %in% c(
    "房地(土地+建物)",
    "房地(土地+建物)+車位"
  )

keep[is.na(keep)] <- FALSE
d <- raw[keep, , drop = FALSE]

for (v in c("UPRICE", "TPRICE", "FAREA")) {
  d[[v]] <- suppressWarnings(
    as.numeric(d[[v]])
  )
}

d <- d[
  !is.na(d$DISTRICT) &
    nzchar(d$DISTRICT) &
    is.finite(d$UPRICE) &
    d$UPRICE > 0 &
    is.finite(d$FAREA) &
    d$FAREA > 0 &
    !is.na(d$year) &
    d$year >= 2019 &
    d$year <= 2026,
  ,
  drop = FALSE
]


d$building_group <- ifelse(
  grepl("大樓", d$BUITYPE),
  "High-rise (11+ floors)",
  ifelse(
    grepl("華廈", d$BUITYPE),
    "Mid-rise with elevator",
    ifelse(
      grepl("公寓", d$BUITYPE),
      "Walk-up apartment",
      NA_character_
    )
  )
)

d$price_per_ping_10k_ntd <- d$UPRICE

write.csv(
  d,
  "data/processed/taipei_residential_sales.csv",
  row.names = FALSE,
  fileEncoding = "UTF-8"
)


cat("Raw records:", nrow(raw), "\n")

cat("Eligible cleaned sales:", nrow(d), "\n")

# Transactions by year
print(table(d$year))

# Transactions by district
print(table(d$DISTRICT))

# Missing building completion dates
cat(
  "Missing completion dates among cleaned sales:",
  sum(is.na(d$FDATE)),
  "/",
  nrow(d),
  "\n"
)
