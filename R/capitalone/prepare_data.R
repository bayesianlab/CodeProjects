source('/home/dillon/CodeProjects/R/capitalone/capital_one_airline/flight_functions.R')

Flights <-
  read_csv("/home/dillon/CodeProjects/R/capitalone/Flights.csv")
Tickets <-
  read_csv("/home/dillon/CodeProjects/R/capitalone/Tickets.csv")
Airports <-
  read_csv("/home/dillon/CodeProjects/R/capitalone/Airport_Codes.csv")

library(mapdata)
library(ggrepel)
library(usmap)
library(profvis)



sourceCpp("caponecpp.cpp")

flights <- join_data(Airports, Tickets, Flights)


flights <- join_data(Airports, Tickets, Flights)
flights$REVENUE <-  compute_flightrev(flights)
flights$COSTS <- compute_flightcost(flights)
flights <-
  flights %>% mutate(PROFIT = REVENUE - COSTS) %>% filter(N_TICKETS > 75,
                                                          PROFIT > 0)
repflights <- flights
repflights$TRIP_NAME <- make_tripname(repflights)
FLIGHTS_TO_BREAKEVEN <- unlist(lapply(repflights$PROFIT, breakeven))
repflights$FLIGHTS_TO_BREAKEVEN <- FLIGHTS_TO_BREAKEVEN
top_ten <- flights[1:10,]
top_ten <- cbind(top_ten, unpack_latlon(top_ten))
top_ten$TRIP_NAME <- make_tripname(top_ten)

usa <- map_data('usa')
ggplot() +
  geom_polygon(data = usa,
               aes(x = long, y = lat, group = group),
               fill = 'black') +
  theme(
    axis.title.x = element_blank(),
    axis.text.x = element_blank(),
    axis.ticks.x = element_blank(),
    axis.title.y = element_blank(),
    axis.text.y = element_blank(),
    axis.ticks.y = element_blank(),
    panel.grid = element_blank(),
    panel.background = element_rect("grey15")
  ) +
  ggtitle('U.S. Map') + coord_fixed(1.3) +
  geom_point(data = top_ten,
             aes(x = ORIGIN_LAT, y = ORIGIN_LON),
             color = 'red') + geom_curve(
               curvature = .25,
               data = top_ten,
               aes(
                 x = ORIGIN_LAT,
                 y = ORIGIN_LON,
                 xend = DEST_LAT,
                 yend = DEST_LON
               ),
               col = "orange"
             ) +
  geom_text_repel(data = top_ten,
                  aes(x = ORIGIN_LAT, y = ORIGIN_LON, label = TRIP_NAME),
                  col = "yellow") +
  geom_label_repel(
    data = top_ten,
    aes(x = ORIGIN_LAT, y = ORIGIN_LON, label = N_FLIGHTS),
    arrow = arrow(length = unit(.01, 'npc')),
    box.padding = unit(2.5, 'lines'),
    segment.color = "red"
  )

profit1 <- lm(PROFIT ~  DIST ,
              data = repflights)
summary(profit)

profit2 <- lm(PROFIT ~ DIST + AVG_ITIN_FARE,
              data = repflights)

summary(profit2)



top_profit <- repflights %>% arrange(desc(PROFIT))
top_profit <- top_profit[1:10, ]
top_profit <- cbind(top_profit, unpack_latlon(top_profit))

top_profit$TRIP_NAME <- make_tripname(top_profit)

ggplot() +
  geom_polygon(data = usa,
               aes(x = long, y = lat, group = group),
               fill = 'black') +
  theme(
    axis.title.x = element_blank(),
    axis.text.x = element_blank(),
    axis.ticks.x = element_blank(),
    axis.title.y = element_blank(),
    axis.text.y = element_blank(),
    axis.ticks.y = element_blank(),
    panel.grid = element_blank(),
    panel.background = element_rect("grey15")
  ) +
  ggtitle('U.S. Map') + coord_fixed(1.3) +
  geom_point(data = top_profit,
             aes(x = ORIGIN_LAT, y = ORIGIN_LON),
             color = 'red') + geom_curve(
               curvature = .25,
               data = top_profit,
               aes(
                 x = ORIGIN_LAT,
                 y = ORIGIN_LON,
                 xend = DEST_LAT,
                 yend = DEST_LON
               ),
               col = "orange"
             ) +
  geom_text_repel(data = top_profit,
                  aes(x = ORIGIN_LAT, y = ORIGIN_LON, label = TRIP_NAME),
                  col = "yellow") +
  geom_label_repel(
    data = top_profit,
    aes(x = ORIGIN_LAT, y = ORIGIN_LON, label = N_TICKETS),
    arrow = arrow(length = unit(.01, 'npc')),
    box.padding = unit(2.5, 'lines'),
    segment.color = "red"
  )



repflights <-
  repflights %>% mutate(SIZE = as.numeric((ORIGIN_SIZE == 'medium_airport' &
                                             DEST_SIZE == 'medium_airport')
  ) +
    2 * as.numeric((
      ORIGIN_SIZE == 'medium_airport' &
        DEST_SIZE == 'large_airport'
    )) +
    3 * as.numeric((
      ORIGIN_SIZE == 'large_airport' &
        DEST_SIZE == 'medium_airport'
    )))

repflights$SIZE <- factor(repflights$SIZE)
levels(repflights$SIZE) <-
  c("Large_to_Large",
    "Medium_to_Medium",
    "Medium_to_Large",
    "Large_to_Medium")

# repflights <-
#   repflights %>% mutate(SIZE = (MEDMED == 1) + 2 * (MEDLARGE == 1) + 3 * (LARGEMED == 1))
#


ggplot() +geom_point(data=repflights, aes(x=AVG_ARR_DELAY, y = PROFIT)) + 
  ggtitle("Profit on Arrival Delay")
ggplot() +geom_point(data=repflights, aes(x=AVG_DEP_DELAY, y = PROFIT))+
  ggtitle("Profit on Departure Delay")


ggplot() + geom_point(data = repflights, aes(x = DIST, y = AVG_ITIN_FARE))

ggplot() + geom_point(data = repflights, aes(x = N_TICKETS, y = PROFIT))
ggplot() + geom_point(data = repflights, aes(x = N_FLIGHTS, y = PROFIT))

summary(lm(PROFIT ~ N_FLIGHTS + DIST + AVG_ITIN_FARE + SIZE + AVG_ARR_DELAY + AVG_DEP_DELAY, data = repflights))

ggplot() +
  geom_point(data = repflights, aes(x = DIST, y = PROFIT, colour = SIZE)) +
  scale_colour_manual(
    values = c(
      "Large_to_Large" = "darkgrey",
      "Large_to_Medium" = "red",
      "Medium_to_Medium" = "green",
      "Medium_to_Large" = "purple"
    )
  ) +
  ggtitle("Profit vs Dist Colored by Airport Size") +
  geom_smooth(data = repflights,
              method = "lm",
              aes(x = DIST, y = PROFIT),
              se = FALSE)
ggplot() +
  geom_point(data = repflights, aes(x = DIST, y = PROFIT, colour = SIZE)) +
  scale_colour_manual(
    values = c(
      "Large_to_Large" = "darkgrey",
      "Large_to_Medium" = "red",
      "Medium_to_Medium" = "green",
      "Medium_to_Large" = "purple"
    )
  ) +
  ggtitle(label = "Profit vs Distance", subtitle = "Colored by Airport Size")

geom_smooth(data = repflights,
            method = "lm",
            aes(x = DIST, y = PROFIT),
            se = FALSE) +
  geom_jitter() + xlab("Distance") + ylab("Profit")


ggplot(data = repflights, aes(x = AVG_ITIN_FARE, y = PROFIT)) + geom_point() +
  geom_smooth(method = "lm", se = FALSE)


ggplot(data = repflights, aes(x = SIZE, y = PROFIT, fill = SIZE)) + geom_boxplot() +
  ggtitle("Profit Summary By Airport Size")

repflights %>% group_by(SIZE) %>%
  summarise(
    Min = min(PROFIT),
    Q1 = quantile(PROFIT, .25),
    Median = median(PROFIT),
    Avg = mean(PROFIT),
    Q3 = quantile(PROFIT, .75),
    Max = max(PROFIT)
  ) %>%
  arrange(desc(Median))


library(mltools)

dummy <- one_hot(repflights$SIZE)
dummy <- dummyVars(" ~ .", data = repflights$SIZE)

p <-
  lm(
    PROFIT ~ DIST + AVG_ITIN_FARE + SIZE + DIST * SIZE + AVG_OCCUPANCY + AVG_OCCUPANCY *
      SIZE +
      DIST * AVG_OCCUPANCY + N_FLIGHTS + DIST * AVG_ITIN_FARE,
    data = repflights
  )
summary(p)


topflight <-
  repflights %>% mutate(
    TOP_FARES = AVG_ITIN_FARE > quantile(AVG_ITIN_FARE, .90),
    TOP_DIST = DIST > quantile(DIST, .90)
  )
topflight$TOP_DIST <- factor(topflight$TOP_DIST)
levels(topflight$TOP_DIST) <- c("LOW_DISTANCE", "HIGH_DISTANCE")
topflight$TOP_FARES <- factor(topflight$TOP_FARES)
levels(topflight$TOP_FARES) <- c("LOW_FARE", "HIGH_FARE")

ggplot() +
  geom_point(data = topflight, aes(x = DIST, y = PROFIT, colour =
                                     TOP_FARES)) + ggtitle("Profit vs Fair Paid") + xlab("Distance") +
  ylab("Profit") + guides(colour = guide_legend(title = ">90% In Fares"))

ggplot() +
  geom_point(data = topflight, aes(x = AVG_ITIN_FARE, y = PROFIT, colour =
                                     TOP_DIST)) + ggtitle("Profit vs Average Itinerary Fare") +
  xlab("Average Itinerary Fare") + ylab("Profit") + guides(colour = guide_legend(title =
                                                                                   ">90% In Distance"))




ggplot() + geom_point(data = topflight,
                      aes(x = FLIGHTS_TO_BREAKEVEN,
                          y = PROFIT, colour = TOP_FARES)) +
  geom_line(data = estdata, aes(x = X, y = Y))

est <- lm(log(PROFIT) ~ log(FLIGHTS_TO_BREAKEVEN), data = repflights)
summary(est)

estfun <- function(fls) {
  y <- exp(19.13) * fls ^ (-2.022)
}
a <- min(topflight$FLIGHTS_TO_BREAKEVEN)
y <- unlist(lapply(a:800, estfun))
estdata <-
  data.frame(cbind(X = a:800, Y = unlist(lapply((
    a:800
  ), estfun))))

plot(100:800, y, type = "l")
ggplot() + geom_point(data = topflight, aes(x = FLIGHTS_TO_BREAKEVEN, y = PROFIT, colour =
                                              TOP_DIST))

ggplot() + geom_point(data = topflight,
                      aes(x = FLIGHTS_TO_BREAKEVEN, y = AVG_ITIN_FARE, colour = TOP_DIST))


by_breakeven <- repflights %>% arrange(FLIGHTS_TO_BREAKEVEN)

newdata <- by_breakeven%>% select(PROFIT, SIZE, N_FLIGHTS, N_TICKETS, AVG_ITIN_FARE,
                                  DIST, AVG_OCCUPANCY)
newdata <- newdata %>% mutate(DIFF = N_FLIGHTS - N_TICKETS)
summary(lm(PROFIT ~ SIZE +  DIST +AVG_ITIN_FARE+AVG_OCCUPANCY, data=newdata))




Z <- by_breakeven %>% mutate(zprofit = scale(PROFIT))

score <- function(be, sz, d){
  airport_effect <- 0
  if(sz == "Medium_to_Medium"){
    airport_effect <- 9.52e+03
  }
  if(sz == "Medium_to_Large"){
    airport_effect <- 4.723e+03
  }
  if(sz =="Large_to_Medium"){
    airport_effect <- 4.93e+03
  }
  dist_effect <- -9.418*d
  
  c <- -2.022*exp(19.13)
  s <- abs(c/be^(3.022))
  s
}



Z$SCORE <-  unlist(lapply(Z$FLIGHTS_TO_BREAKEVEN, score))
Z<- Z %>% mutate(zscore = PROFIT - SCORE)




