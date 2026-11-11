if (!requireNamespace("ggplot2", quietly = TRUE)) {
  stop("Install ggplot2: install.packages('ggplot2')")
}

library(ggplot2)

dir.create("figures", showWarnings = FALSE)

d <- read.csv(
  "data/processed/taipei_residential_sales.csv",
  fileEncoding = "UTF-8",
  stringsAsFactors = FALSE
)

# Restrict to 2026 because historical coverage is uneven
d <- d[d$year == 2026, , drop = FALSE]

if (nrow(d) == 0) {
  stop("No 2026 records after filtering.")
}

district_labels <- c(
  "中正區" = "中正區 (Zhongzheng)",
  "大安區" = "大安區 (Da'an)",
  "松山區" = "松山區 (Songshan)",
  "中山區" = "中山區 (Zhongshan)",
  "信義區" = "信義區 (Xinyi)",
  "大同區" = "大同區 (Datong)",
  "內湖區" = "內湖區 (Neihu)",
  "南港區" = "南港區 (Nangang)",
  "北投區" = "北投區 (Beitou)",
  "萬華區" = "萬華區 (Wanhua)",
  "士林區" = "士林區 (Shilin)",
  "文山區" = "文山區 (Wenshan)"
)

# Keep districts with at least 5 records
tab <- table(d$DISTRICT)

f1 <- d[
  d$DISTRICT %in% names(tab[tab >= 5]),
  ,
  drop = FALSE
]

if (nrow(f1) == 0) {
  stop("No districts have at least five observations.")
}

# Calculate median prices
med <- tapply(
  f1$price_per_ping_10k_ntd,
  f1$DISTRICT,
  median
)

# Order districts by median price
f1$district_ordered <- factor(
  f1$DISTRICT,
  levels = names(sort(med))
)

# Create Figure 1
p1 <- ggplot(
  f1,
  aes(
    x = district_ordered,
    y = price_per_ping_10k_ntd
  )
) +
  geom_boxplot(
    fill = "#7BA9D6",
    color = "#333333",
    outlier.alpha = 0.35,
    width = 0.7
  ) +
  coord_flip() +
  scale_x_discrete(
    labels = district_labels
  ) +
  labs(
    title = "Taipei residential sale prices by district (2026)",
    subtitle = paste(
      "Recorded sales; n =", nrow(f1),
      "| Districts with at least 5 records"
    ),
    x = "District",
    y = "Price per ping (NT$10,000)"
  ) +
  theme_minimal(base_size = 12) +
  theme(
    plot.title = element_text(
      size = 15,
      face = "bold"
    ),
    plot.subtitle = element_text(
      size = 11,
      color = "grey40"
    ),
    axis.text.y = element_text(
      size = 10
    ),
    axis.text.x = element_text(
      size = 10
    ),
    panel.grid.major.y = element_blank(),
    plot.margin = margin(12, 15, 12, 15)
  )

# Save Figure 1
ggsave(
  filename = "figures/figure1_district.png",
  plot = p1,
  width = 11,
  height = 7,
  dpi = 300
)


# Remove missing building groups
f2 <- d[
  !is.na(d$building_group),
  ,
  drop = FALSE
]

# Keep building groups with at least 5 observations
tab2 <- table(f2$building_group)

f2 <- f2[
  f2$building_group %in% names(tab2[tab2 >= 5]),
  ,
  drop = FALSE
]

if (nrow(f2) == 0) {
  stop("No building groups have at least five observations.")
}

# Calculate median prices by building type
med2 <- tapply(
  f2$price_per_ping_10k_ntd,
  f2$building_group,
  median
)

# Order building types by median price
f2$building_group <- factor(
  f2$building_group,
  levels = names(sort(med2))
)

p2 <- ggplot(
  f2,
  aes(
    x = building_group,
    y = price_per_ping_10k_ntd
  )
) +
  geom_boxplot(
    fill = "#91C5AE",
    color = "#333333",
    outlier.alpha = 0.35,
    width = 0.65
  ) +
  labs(
    title = "Taipei residential sale prices by building type (2026)",
    subtitle = paste(
      "Recorded sales; n =", nrow(f2),
      "| Groups with at least 5 records"
    ),
    x = "Building type",
    y = "Price per ping (NT$10,000)"
  ) +
  theme_minimal(base_size = 12) +
  theme(
    plot.title = element_text(
      size = 15,
      face = "bold"
    ),
    plot.subtitle = element_text(
      size = 11,
      color = "grey40"
    ),
    axis.text.x = element_text(
      size = 10
    ),
    panel.grid.major.x = element_blank(),
    plot.margin = margin(12, 15, 12, 15)
  )

ggsave(
  filename = "figures/figure2_building_type.png",
  plot = p2,
  width = 10,
  height = 6,
  dpi = 300
)

# Display figures
print(p1)
print(p2)

# Print summary statistics
cat("\nFigure 1 district medians (NT$10,000 per ping):\n")
print(sort(med))

cat("\nFigure 2 building-type medians (NT$10,000 per ping):\n")
print(sort(med2))

cat("\nNumber of records used in Figure 1:", nrow(f1), "\n")
cat("Number of records used in Figure 2:", nrow(f2), "\n")

cat("\nBoth figures saved successfully.\n")
