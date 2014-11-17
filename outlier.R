# remove outlier data point
library(dplyr)
library(ggplot2)
library(zoo)

data <- read.csv(file.choose(), stringsAsFactors=TRUE)
data$date <- as.Date(as.character(data$ingestdate), "%Y%m%d")
plot(x=data$date, y=data$qtyavail)



result <- data %>% 
  filter(price > 0) %>%
  group_by(source, mpn, mfr, date) %>%
  summarise(qtyavail_max = max(qtyavail), price_min = min(price)) %>%
  arrange(date)

qtyavail_limit <- 10 * median(result$qtyavail_max)
result$qtyavail_max <- ifelse(result$qtyavail_max < qtyavail_limit, result$qtyavail_max, NA)

days <- data.frame(date_all = seq(from=min(result$date), to=max(result$date), by="day"))
days.all <- merge(x=days, y=result, by.x="date_all", by.y="date", all.x=TRUE)

result.zoo <- zoo(days.all$qtyavail_max, days.all$date)
result.complete.approx <- na.approx(result.zoo)
sales.approx <- sum(pmax(0, as.vector(-diff(result.complete.approx[,1]))))

days_total <- nrow(result)
# capture the number of days with outliers
# capcure the number of days with sold
# days with replenishment
# dyas without unchanged

# total sales
# total replenishment


