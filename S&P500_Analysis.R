# S&P 500 CONSTITUENT ANALYSIS

# Base R Financial Data Analysis

# Objective:
# Analyze S&P 500 constituents using Base R to investigate:
# - Data quality
# - Sector and industry composition
# - Index concentration
# - Market capitalization
# - Revenue growth
# - Sector-level financial characteristics
# - Statistical outliers
# - Relationships between financial variables
# - Base R visualizations


# 1. IMPORT DATA

SP500 <- read.csv("data/SP500.csv")

str(SP500)
head(SP500)
dim(SP500)


# 2. DATA QUALITY CHECK

sum(is.na(SP500))

colSums(is.na(SP500))

colSums(is.na(SP500)) / nrow(SP500) * 100

sum(duplicated(SP500))

class(SP500$Fulltimeemployees)
class(SP500$Currentprice)
class(SP500$Marketcap)
class(SP500$Sector)

summary(SP500$Currentprice)
summary(SP500$Marketcap)
summary(SP500$Revenuegrowth)
summary(SP500$Weight)

sum(SP500$Weight, na.rm = TRUE)


# 3. SECTOR ANALYSIS

sector_counts <- table(SP500$Sector)

sector_counts

sector_percent <- prop.table(sector_counts) * 100

sector_percent

max(sector_counts)

names(sector_counts)[which.max(sector_counts)]


# 4. SECTOR INDEX WEIGHTS

sector_weights <- tapply(
  SP500$Weight,
  SP500$Sector,
  sum
)

sector_weights

sum(sector_weights)

sector_weight_percent <- sector_weights * 100

sector_weight_percent


# 5. COMPANY COUNT VS INDEX WEIGHT

sector_comparison <- data.frame(
  Sector = names(sector_counts),
  Company_Percent = as.numeric(sector_counts) /
    nrow(SP500) * 100,
  Index_Weight_Percent = as.numeric(sector_weights) * 100
)

sector_comparison

sector_comparison$Weight_Difference <-
  sector_comparison$Index_Weight_Percent -
  sector_comparison$Company_Percent

sector_comparison[
  order(
    sector_comparison$Weight_Difference,
    decreasing = TRUE
  ),
]

sector_comparison[
  sector_comparison$Weight_Difference > 0,
]

sector_comparison[
  sector_comparison$Weight_Difference < 0,
]


# 6. INDUSTRY ANALYSIS

length(unique(SP500$Industry))

industry_counts <- table(SP500$Industry)

sort(industry_counts, decreasing = TRUE)

top_industries <- sort(
  industry_counts,
  decreasing = TRUE
)[1:10]

top_industries

top_industry_percent <-
  top_industries / nrow(SP500) * 100

top_industry_percent


# 7. TOP COMPANIES BY MARKET CAPITALIZATION

SP500_sorted <- SP500[
  order(SP500$Marketcap, decreasing = TRUE),
]

top10_companies <- SP500_sorted[
  1:10,
  c(
    "Symbol",
    "Shortname",
    "Marketcap",
    "Sector",
    "Weight"
  )
]

top10_companies


# 8. S&P 500 INDEX CONCENTRATION

top5_marketcap_weight <-
  sum(SP500_sorted$Weight[1:5]) * 100

top10_marketcap_weight <-
  sum(SP500_sorted$Weight[1:10]) * 100

remaining_weight <-
  100 - top10_marketcap_weight

top5_marketcap_weight
top10_marketcap_weight
remaining_weight


# 9. REVENUE GROWTH ANALYSIS

max(
  SP500$Revenuegrowth,
  na.rm = TRUE
)

min(
  SP500$Revenuegrowth,
  na.rm = TRUE
)

max_growth_row <-
  which.max(SP500$Revenuegrowth)

SP500[
  max_growth_row,
  c(
    "Symbol",
    "Shortname",
    "Revenuegrowth",
    "Sector",
    "Marketcap"
  )
]

min_growth_row <-
  which.min(SP500$Revenuegrowth)

SP500[
  min_growth_row,
  c(
    "Symbol",
    "Shortname",
    "Revenuegrowth",
    "Sector",
    "Marketcap"
  )
]


# 10. REVENUE GROWTH DESCRIPTIVE STATISTICS

mean(
  SP500$Revenuegrowth,
  na.rm = TRUE
)

median(
  SP500$Revenuegrowth,
  na.rm = TRUE
)

sd(
  SP500$Revenuegrowth,
  na.rm = TRUE
)

summary(SP500$Revenuegrowth)


# 11. REVENUE GROWTH BY SECTOR

sector_growth_values <- tapply(
  SP500$Revenuegrowth,
  SP500$Sector,
  mean,
  na.rm = TRUE
)

sort(
  sector_growth_values,
  decreasing = TRUE
)

sector_growth <- data.frame(
  Sector = names(sector_growth_values),
  Average_Revenue_Growth =
    as.numeric(sector_growth_values)
)

sector_growth$Index_Weight_Percent <-
  as.numeric(sector_weight_percent)

sector_growth$Growth_Weight_Gap <-
  sector_growth$Average_Revenue_Growth -
  sector_growth$Index_Weight_Percent

sector_growth


# 12. MARKET CAP VS REVENUE GROWTH

marketcap_growth_correlation <- cor(
  SP500$Marketcap,
  SP500$Revenuegrowth,
  use = "complete.obs"
)

marketcap_growth_correlation


# 13. OUTLIER ANALYSIS — IQR METHOD

quantile(
  SP500$Revenuegrowth,
  na.rm = TRUE
)

revenue_growth_IQR <- IQR(
  SP500$Revenuegrowth,
  na.rm = TRUE
)

revenue_growth_IQR

lower_bound <-
  quantile(
    SP500$Revenuegrowth,
    0.25,
    na.rm = TRUE
  ) -
  1.5 * revenue_growth_IQR

upper_bound <-
  quantile(
    SP500$Revenuegrowth,
    0.75,
    na.rm = TRUE
  ) +
  1.5 * revenue_growth_IQR

lower_bound
upper_bound


# 14. IDENTIFY REVENUE-GROWTH OUTLIERS

outliers <- SP500$Revenuegrowth[
  !is.na(SP500$Revenuegrowth) &
    (
      SP500$Revenuegrowth < lower_bound |
        SP500$Revenuegrowth > upper_bound
    )
]

length(outliers)


# 15. IDENTIFY OUTLIER COMPANIES

outlier_companies <- SP500[
  !is.na(SP500$Revenuegrowth) &
    (
      SP500$Revenuegrowth < lower_bound |
        SP500$Revenuegrowth > upper_bound
    ),
]

outlier_companies[
  ,
  c(
    "Symbol",
    "Shortname",
    "Revenuegrowth",
    "Sector"
  )
]


# 16. OUTLIERS BY SECTOR

outlier_sector_counts <-
  table(outlier_companies$Sector)

sort(
  outlier_sector_counts,
  decreasing = TRUE
)

sector_outlier_rate <-
  outlier_sector_counts /
  sector_counts[
    names(outlier_sector_counts)
  ] * 100

sort(
  sector_outlier_rate,
  decreasing = TRUE
)


# 17. EXTREME OUTLIERS

outlier_sorted <- outlier_companies[
  order(
    outlier_companies$Revenuegrowth
  ),
]

extreme_outliers <- rbind(
  head(outlier_sorted, 5),
  tail(outlier_sorted, 5)
)

extreme_outliers[
  ,
  c(
    "Symbol",
    "Shortname",
    "Revenuegrowth",
    "Sector"
  )
]


# 18. BASE R VISUALIZATIONS

if (!dir.exists("figures")) {
  dir.create("figures")
}


# 18.1 Companies by sector

png(
  "figures/sector_companies.png",
  width = 1400,
  height = 900,
  res = 150
)

par(mar = c(10, 5, 4, 2))

barplot(
  sector_counts,
  main = "S&P 500 Companies by Sector",
  xlab = "Sector",
  ylab = "Number of Companies",
  las = 2,
  cex.names = 0.8
)

dev.off()


# 18.2 Index weight by sector

png(
  "figures/sector_index_weight.png",
  width = 1400,
  height = 900,
  res = 150
)

par(mar = c(10, 5, 4, 2))

barplot(
  sector_weight_percent,
  main = "S&P 500 Index Weight by Sector",
  xlab = "Sector",
  ylab = "Index Weight (%)",
  las = 2,
  cex.names = 0.8
)

dev.off()


# 18.3 Revenue growth distribution

png(
  "figures/revenue_growth_distribution.png",
  width = 1200,
  height = 900,
  res = 150
)

hist(
  SP500$Revenuegrowth * 100,
  main = "Distribution of S&P 500 Revenue Growth",
  xlab = "Revenue Growth (%)",
  ylab = "Number of Companies"
)

dev.off()


# 18.4 Top 10 companies by market cap: index weight

top10_weights <-
  SP500_sorted$Weight[1:10] * 100

png(
  "figures/top10_index_weight.png",
  width = 1400,
  height = 900,
  res = 150
)

par(mar = c(7, 5, 4, 2))

barplot(
  top10_weights,
  names.arg = SP500_sorted$Symbol[1:10],
  main = "Top 10 S&P 500 Companies by Market Cap: Index Weight",
  xlab = "Company",
  ylab = "Index Weight (%)",
  cex.names = 0.9
)

dev.off()


# 18.5 Extreme revenue-growth outliers

png(
  "figures/extreme_revenue_growth_outliers.png",
  width = 1400,
  height = 900,
  res = 150
)

par(mar = c(7, 5, 4, 2))

barplot(
  extreme_outliers$Revenuegrowth * 100,
  names.arg = extreme_outliers$Symbol,
  main = "Extreme Revenue Growth Outliers",
  xlab = "Company",
  ylab = "Revenue Growth (%)",
  las = 2,
  cex.names = 0.9
)

dev.off()


# 19. FINAL KEY METRICS

nrow(SP500)

length(unique(SP500$Sector))

length(unique(SP500$Industry))

top5_marketcap_weight

top10_marketcap_weight

mean(
  SP500$Revenuegrowth,
  na.rm = TRUE
)

median(
  SP500$Revenuegrowth,
  na.rm = TRUE
)

sd(
  SP500$Revenuegrowth,
  na.rm = TRUE
)

revenue_growth_IQR

length(outliers)

marketcap_growth_correlation


# Store final metrics

final_metrics <- list(
  companies = nrow(SP500),
  sectors = length(unique(SP500$Sector)),
  industries = length(unique(SP500$Industry)),
  top5_marketcap_weight = top5_marketcap_weight,
  top10_marketcap_weight = top10_marketcap_weight,
  mean_revenue_growth = mean(
    SP500$Revenuegrowth,
    na.rm = TRUE
  ),
  median_revenue_growth = median(
    SP500$Revenuegrowth,
    na.rm = TRUE
  ),
  revenue_growth_sd = sd(
    SP500$Revenuegrowth,
    na.rm = TRUE
  ),
  revenue_growth_IQR = revenue_growth_IQR,
  revenue_growth_outliers = length(outliers),
  marketcap_growth_correlation =
    marketcap_growth_correlation
)

final_metrics


# END OF ANALYSIS