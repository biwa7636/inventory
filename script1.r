library(dplyr)
library(gridExtra)
library(ggplot2)
library(zoo)

# read in mfr_mpn.csv
data <- read.csv(file.choose(), stringsAsFactors=FALSE)
data$date <- as.Date(as.character(data$ingestdate), "%Y%m%d")

p1 <- ggplot(data=data, aes(x=date, y=qtyavail, colour=partnumber)) + geom_point() + geom_line() +
   theme(legend.justification=c(1,0), legend.position=c(1,0))

result <- data %>% 
  filter(price > 0) %>%
  group_by(source, mpn, mfr, date) %>%
  summarise(qtyavail_max = max(qtyavail), price_min = min(price)) %>%
  arrange(date)

p2 <- ggplot(data=result, aes(x=date, y=qtyavail_max)) + geom_point() + geom_line()
grid.arrange(p1,p2)

 
# fill in empty cell
# 399 captured / 463 days in total between "201-08-08" and "2014-11-14"

# (1) fill missing days with 0 because we only scraped parts that on shelf
# (2) interpolate missing days
# (3) don't care about missing days, treat them as purely numeric array problem instead of time seires problem
#     currently Hive solution

result.zoo <- zoo(result$qtyavail_max, result$date)
result.complete <- na.approx(result.zoo, xout=seq(start(result.zoo), end(result.zoo), by="day"))
par(mfrow=c(3,1))
plot(result.zoo)
plot(zoo(pmax(0, as.vector(-diff(result.complete[,1]))), seq(start(result.complete), end(result.complete), by="day")))
plot(zoo(pmin(0, as.vector(-diff(result.complete[,1]))), seq(start(result.complete), end(result.complete), by="day")))


# Goals:
# 1. Quantity Sold
# 2. Quantity Bought in
# 3. Minimum Price
# 4. Average Inventory Value, Qtysold/Avg= inventory turns
# 5. #ofmovingdays / #ofobservedonshelfdays


