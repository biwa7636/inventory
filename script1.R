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
# 399 captured / 463 days in total between "2013-08-08" and "2014-11-14"

# (1) fill missing days with 0 because we only scraped parts that on shelf
# (2) interpolate missing days
# (3) don't care about missing days, treat them as purely numeric array problem instead of time seires problem
#     currently Hive solution
days <- data.frame(date_all = seq(from=min(result$date), to=max(result$date), by="day"))
days.all <- merge(x=days, y=result, by.x="date_all", by.y="date", all.x=TRUE)
# I noticed that most of the days with missing values are actually truly "missing values" instead of "out-of-stock"
# fill in missing values with 0 will dramatically overestimate their sales. 




# Hive solution
sales.hive <- sum(pmax(0, -diff(result$qtyavail_max)))
# 598,730
refill.hive <- sum(pmin(0, -diff(result$qtyavail_max)))
# 632,890


result.zoo <- zoo(days.all$qtyavail_max, days.all$date)
result.complete.approx <- na.approx(result.zoo)
sales.approx <- sum(pmax(0, as.vector(-diff(result.complete.approx[,1]))))
# 598,730
result.complete.fill <- na.fill(result.zoo, fill=0)
sales.fill <- sum(pmax(0, as.vector(-diff(result.complete.fill[,1]))))
# 3,300,206



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


