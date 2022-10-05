roundtrips <- read_csv('roundtrips.csv')
tickets <- read_csv('tickets.csv')

by_trip <- roundtrips %>% group_by(TRIP_CODE)
common_routes <- arrange(by_trip %>% summarise(count = n()), -count)

# tickets %>% 
  # summarise(AVG_FARE = mean(ITIN_FARE), n = n()) %>%

avg_prices  <- tickets %>% group_by(TRIP_CODE) %>% 
    summarise(AVG_FARE = mean(ITIN_FARE), 
              n = n()) %>%
    arrange(-n)


avg_occupancy <- roundtrips %>% group_by(TRIP_CODE) %>%
  summarise(AVG_OCCUPANCY = mean(OCCUPANCY_RATE),
            DISTANCE = mean(DISTANCE), 
            ORIGIN = mean(ORIGIN), 
            n = n())


price = numeric(length=nrow(avg_prices))
for(i in 1:nrow(avg_prices)){
  # print(avg_prices[i,])
  x<-paste(rev(stri_sub(avg_prices[i,1], from=c(1,4), length=3)), collapse='')
  tbl <- avg_prices[avg_prices$TRIP_CODE == x, ]
  if(!is.null(dim(tbl))){
    price[[i]] <- (as.numeric(tbl[,2]) + as.numeric(avg_prices[i,2]))/2
  }
  else{
    price[[i]] <- as.numeric(avg_prices[i,2])
  }
}
avg_prices$price <- price
price_occupancy <- merge(avg_occupancy[,1:3], avg_prices[,1:2], by= "TRIP_CODE")

bag_fees <- function(price_occupancy_data){
  BAG_FEES <- 7000*price_occupancy_data$AVG_OCCUPANCY
  BAG_FEES
}

price_occupancy$BAG_FEES <-  bag_fees(price_occupancy)

rev_function <- function(price_occupancy_data){
  BAG_FEES <- bag_fees(price_occupancy_data)
  d1 <- price_occupancy_data$AVG_OCCUPANCY
  d2 <- price_occupancy_data$AVG_FARE
  FLIGHT_REVENUE <- d1*d2*200 + BAG_FEES
  FLIGHT_REVENUE
}

cost_function  <- function(price_occupancy_data){
  
}

price_occupancy$FLIGHT_REVENUE <- rev_function(price_occupancy)
