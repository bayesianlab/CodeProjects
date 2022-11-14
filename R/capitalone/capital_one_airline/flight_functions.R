library(dplyr)
library(readr)
library(Rcpp)
library(stringi)
library(tidyverse)
library(knitr)
setwd("/home/dillon/CodeProjects/R/capitalone/capital_one_airline/")
sourceCpp("caponecpp.cpp")

unpack_latlon <- function(data) {
  x <-
    data %>% mutate(
      ORIGIN_LAT = unlist(strsplit(ORIGIN_COOR, ','))[1],
      ORIGIN_LON = unlist(strsplit(ORIGIN_COOR, ','))[2],
      DEST_LAT = unlist(strsplit(DEST_COOR, ','))[1],
      DEST_LON = unlist(strsplit(DEST_COOR, ','))[2]
    )
  x
}

clean_airport_codes <- function(codes) {
  df <- codes[codes$TYPE == "medium_airport" |
                codes$TYPE == "large_airport", ]
  df <- df[which(df$ISO_COUNTRY == "US"), ]
  df <- df[which(!is.na(df$IATA_CODE)), ]
  df
}

filter_airports <- function(valid_airports, flight_data) {
  codes <- data.frame(IATA_CODE = valid_airports$IATA_CODE)
  x <-
    merge(flight_data, codes, by.x = "ORIGIN", by.y = "IATA_CODE")
  x <- merge(x, codes, by.x = "DESTINATION", by.y = "IATA_CODE")
}

drop_cancelled <- function(flight_data) {
  flight_data <- flight_data[which(flight_data$CANCELLED == 0),]
  flight_data
}

drop_oneways <- function(ticketdata) {
  ticketdata <- ticketdata[ticketdata$ROUNDTRIP == 1,]
  ticketdata <- select(ticketdata,-ROUNDTRIP)
  ticketdata
}

create_trip_code <- function(data) {
  TRIP_CODE <- list()
  for (i in 1:nrow(data)) {
    TRIP_CODE[[i]] <-
      paste(data[i, "ORIGIN"], data[i, "DESTINATION"], sep = "")
  }
  z <- unlist(TRIP_CODE)
  data$TRIP_CODE <- z
  data
}

mode <- function(x) {
  x <- x[which(!is.na(x))]
  ux <- unique(x)
  ux[which.max(tabulate(match(x, ux)))]
}

make_airid_dict <- function(all_airports_set) {
  N <- length(all_airports_set)
  airid_dict <-
    data.frame(row.names = all_airports_set, AIRID = 1:N)
  airid_dict
}

make_roundtripid_matrix <- function(uniquelevels) {
  N <- length(uniquelevels)
  RoundId <- matrix(0, nrow = N,
                    ncol = N)
  c <- 0
  for (i in 1:N) {
    for (j in i:N) {
      if (j != i) {
        c <- c + 1
        RoundId[j, i] = c
        RoundId[i, j] = c
      }
    }
  }
  RoundId
}

impute_flightid <- function(data, roundtripid, airid_dict) {
  flightid <- numeric(nrow(data))
  if (("ORG_AIRID" %in% colnames(data)) &&
      ("DEST_AIRID" %in% colnames(data))) {
    for (i in 1:nrow(data)) {
      flightid[i] <-
        roundtripid[data$ORG_AIRID[i], data$DEST_AIRID[i]]
    }
    data$flightid <- flightid
    data
  }
  else if (("ORIGIN" %in% colnames(data)) &&
           ("DESTINATION" %in% colnames(data))) {
    for (i in 1:nrow(data)) {
      r <- airid_dict[data$ORIGIN[i], ]
      c <- airid_dict[data$DESTINATION[i], ]
      flightid[i] <- roundtripid[r, c]
    }
    data$flightid <- flightid
    data
  }
  else{
    errorCondition("Necessary columns not included in data")
  }
}

inverse_id_rc <- function(tripidmat, id) {
  x <- upper.tri(tripidmat) * tripidmat
  rc <- which(id == x, arr.ind = TRUE)
  rc
}

inverse_id_name <- function(tripidmat, airid, id) {
  rc <- inverse_id_rc(tripidmat, id)
  n1 <- airid[which(airid$AIRID == rc[1]), 2]
  n2 <- airid[which(airid$AIRID == rc[2]), 2]
  n <- paste(n1, n2, sep = ' ')
  n
}

inverse_id_airports <- function(tripidmat, airid, id) {
  rc <- inverse_id_rc(tripidmat, id)
  n1 <- airid[which(airid$AIRID == rc[1]), 2]
  n2 <- airid[which(airid$AIRID == rc[2]), 2]
  n <- c(n1, n2)
  n
}

names_from_flightid <-
  function(data_with_flightid,
           airid_data,
           roundtripmatrix) {
    names <- list()
    org <- list()
    dest <- list()
    for (i in 1:nrow(data_with_flightid)) {
      id <- data_with_flightid$flightid[i]
      n <- inverse_id_name(roundtripmatrix, airid, id)
      orgdest <- inverse_id_airports(roundtripmatrix, airid, id)
      org[[i]] <- orgdest[1]
      dest[[i]] <- orgdest[2]
      names[[i]] <- n
    }
    data_with_flightid$ORIGIN <-  do.call(rbind, org)
    data_with_flightid$DESTINATION <- do.call(rbind, dest)
    data_with_flightid$TRIP_NAME <-  do.call(rbind, names)
    data_with_flightid
  }

flight_revenue <- function(occ_rate, avg_fare) {
  pass_rev <- occ_rate * avg_fare * 200
  bags_rev <- 7000 * occ_rate
  rev <- pass_rev + bags_rev
  rev
}

airport_cost <- function(airport_size) {
  cost <- 0
  if (airport_size == "large_airport") {
    cost <- 10000
  }
  else{
    cost <- 5000
  }
  cost
}

delay_cost <- function(delay_time) {
  cost <- 0
  if (delay_time > 15) {
    cost <- (delay_time - 15) * 75
  }
  cost
}

flight_costs <-
  function(dist,
           airport_org_size,
           airport_dest_size,
           avg_dep_delay,
           avg_arr_delay) {
    dep <- 9.44 * dist
    fixed_airport_cost <- airport_cost(airport_org_size) +
      airport_cost(airport_dest_size)
    delay1 <- delay_cost(avg_arr_delay)
    delay2 <- delay_cost(avg_arr_delay)
    cost <- dep + fixed_airport_cost + delay1 + delay2
    cost
  }

compute_flightrev <- function(flight_data) {
  rev = list()
  for (i in 1:nrow(flight_data)) {
    occ_rate <- flight_data[i, "AVG_OCCUPANCY"]
    fare <- flight_data[i, "AVG_ITIN_FARE"]
    rev[[i]] <-
      flight_revenue(as.numeric(occ_rate), as.numeric(fare))
  }
  rev <- do.call(rbind, rev)
  rev
}

compute_flightcost <- function(flight_data) {
  cost = list()
  for (i in 1:nrow(flight_data)) {
    org_size <- flight_data[i, "ORIGIN_SIZE"]
    dest_size <- flight_data[i, "DEST_SIZE"]
    dist <- as.numeric(flight_data[i, "DIST"])
    ar_delay <- as.numeric(flight_data[i, "AVG_ARR_DELAY"])
    dep_delay <- as.numeric(flight_data[i, "AVG_DEP_DELAY"])
    cost[[i]] <-
      flight_costs(dist, org_size, dest_size, ar_delay, dep_delay)
  }
  cost <- do.call(rbind, cost)
  cost
}

clean_airports <- function(Airports) {
  big_airports <- clean_airport_codes(Airports)
  big_airports <-
    select(big_airports,-c(CONTINENT, MUNICIPALITY, ISO_COUNTRY))
  big_airports
}

clean_flights <- function(Flights, big_airports) {
  valid_flights <- drop_cancelled(Flights)
  valid_flights <-
    valid_flights %>% inner_join(big_airports[, c(1, 2, 4, 5)], c("ORIGIN" = "IATA_CODE")) %>%
    rename(ORIGIN_SIZE = TYPE) %>% rename(ORIGIN_AIRPORT_NAME = NAME) %>%
    rename(ORIGIN_COOR = COORDINATES) %>%
    inner_join(big_airports[, c(1, 2, 4, 5)], c("DESTINATION" = "IATA_CODE")) %>%
    rename(DEST_SIZE = TYPE) %>% rename(DEST_AIRPORT_NAME = NAME) %>%
    rename(DEST_COOR = COORDINATES)
  # Some flights were into and out of the same airport, not useful for this
  # exercise
  valid_flights <-
    valid_flights[-which(valid_flights$ORIGIN == valid_flights$DESTINATION), ]
}

clean_tickets <- function(TicketsData, big_airports) {
  tickets_roundtrip <- drop_oneways(TicketsData)
  tickets_roundtrip$ITIN_FARE <-
    as.numeric(tickets_roundtrip$ITIN_FARE)
  tickets_roundtrip <- select(tickets_roundtrip,
                              ORIGIN,
                              PASSENGERS,
                              ITIN_FARE,
                              DESTINATION)
  tickets_roundtrip$rowid <- 1:nrow(tickets_roundtrip)
  tickets_roundtrip <-
    tickets_roundtrip %>% inner_join(big_airports[, c(1, 4)],
                                     by = c("ORIGIN" = "IATA_CODE")) %>%
    rename(origin_airport_size = TYPE) %>%
    inner_join(big_airports[, c(1, 4)],
               by = c("DESTINATION" = "IATA_CODE")) %>%
    rename(dest_airport_size = TYPE)
  tickets_roundtrip
}

connect_airid <- function(data, airid) {
  newdata <- data %>% inner_join(airid, by = c("ORIGIN" =  "NAME")) %>%
    rename(ORG_AIRID = AIRID) %>%
    inner_join(airid, by = c("DESTINATION" = "NAME")) %>%
    rename(DEST_AIRID = AIRID)
  newdata
}


impossible_airspeed <- function(flights){
  c <- 1
  tol <- 1000
  badrows <- list()
  for(i in 1:nrow(flights)){
    d <- 500*(flights$AVG_AIR_TIME[i]/60)
    if(is.na(d)){
      badrows[[c]] <- i 
      c<- c+1
    }
    else{
      diff <- abs(flights$DIST[i] - d)
      if(is.na(diff)){
        badrows[[c]] <- i
        c<-c+1
        break 
      }
      else{
        if( diff > tol ){
          badrows[[c]] <- i
          c<- c+1
        }
      }
    }
  }
  do.call(rbind,badrows)
}


join_data <- function(AirportData, TicketData, FlightData) {
  big_airports <- clean_airports(AirportData)
  valid_flights <- clean_flights(FlightData, big_airports)
  tickets_roundtrip <- clean_tickets(TicketData, big_airports)
  uniquelevels <- unique(c(
    levels(factor(valid_flights$ORIGIN)),
    levels(factor(valid_flights$DESTINATION)),
    levels(factor(tickets_roundtrip$ORIGIN)),
    levels(factor(tickets_roundtrip$DESTINATION))
  ))
  airid_dict <- make_airid_dict(uniquelevels)
  airid <- airid_dict %>% mutate(NAME = rownames(airid_dict))
  rownames(airid) <- 1:nrow(airid)
  roundtripidmatrix <- make_roundtripid_matrix(uniquelevels)
  roundtripmatrix <<- roundtripidmatrix
  airid <<- airid
  valid_flights <- connect_airid(valid_flights, airid)
  fid <- impute_flightid_cpp(valid_flights, roundtripidmatrix)
  valid_flights$flightid <- fid
  # valid_flights <- impute_flightid(valid_flights, roundtripidmatrix, airid)
  tickets_roundtrip <- connect_airid(tickets_roundtrip, airid)
  # tickets_roundtrip <- impute_flightid(tickets_roundtrip, roundtripidmatrix, airid)
  fid <- impute_flightid_cpp(tickets_roundtrip, roundtripidmatrix)
  tickets_roundtrip$flightid <- fid
  # Now the tables are connected through the airid
  valid_flights <-
    valid_flights %>% mutate(
      DEP_DELAY = as.numeric(DEP_DELAY),
      ARR_DELAY = as.numeric(ARR_DELAY),
      OCCUPANCY_RATE = as.numeric(OCCUPANCY_RATE),
      DISTANCE = as.numeric(DISTANCE),
      AIR_TIME = as.numeric(AIR_TIME),
      DEST_SIZE = factor(DEST_SIZE),
      ORIGIN_SIZE = factor(ORIGIN_SIZE)
    )
  # Aggregate data down to link together
  busy_route <- valid_flights %>% group_by(ORIGIN, DESTINATION) %>%
    summarise(
      N_FLIGHTS = n(),
      ORIGIN_SIZE = mode(ORIGIN_SIZE),
      DEST_SIZE = mode(DEST_SIZE),
      flightid = mode(flightid)
    )
  
  summarydata <-
    valid_flights %>% group_by(flightid) %>%
    summarise(
      AVG_DEP_DELAY = mean(DEP_DELAY),
      AVG_ARR_DELAY = mean(ARR_DELAY, na.rm = TRUE),
      AVG_AIR_TIME = mean(AIR_TIME, na.rm = TRUE),
      DIST = mode(DISTANCE),
      AVG_OCCUPANCY = mean(OCCUPANCY_RATE, na.rm = TRUE),
    )
  
  flights_roundtrips <- busy_route %>% group_by(flightid) %>%
    summarise(
      N_FLIGHTS = min(N_FLIGHTS),
      ORIGIN = mode(ORIGIN),
      DESTINATION = mode(DESTINATION)
    ) %>%
    arrange(desc(N_FLIGHTS))
  flights_roundtrips <- flights_roundtrips %>%
    inner_join(big_airports[, c(1, 2, 4, 5)], by = c("ORIGIN" = "IATA_CODE")) %>%
    rename(
      "ORIGIN_NAME" = "NAME",
      "ORIGIN_SIZE" = "TYPE",
      "ORIGIN_COOR" = "COORDINATES"
    ) %>%
    inner_join(big_airports[, c(1, 2, 4, 5)], by = c("DESTINATION" = "IATA_CODE")) %>%
    rename(
      "DEST_NAME" = "NAME",
      "DEST_SIZE" = "TYPE",
      "DEST_COOR" = "COORDINATES"
    )
  
  tickets_roundtrip <-
    tickets_roundtrip[which(!is.na(tickets_roundtrip$ITIN_FARE)), ]
  ticket_summary <- tickets_roundtrip %>% group_by(flightid) %>%
    summarise(N_TICKETS = n(),
              AVG_ITIN_FARE = mean(ITIN_FARE)) %>%
    arrange(desc(N_TICKETS))
  
  flights_roundtrips <-
    inner_join(flights_roundtrips,
               summarydata,
               by = c("flightid" = "flightid"))
  ## Actually connects the three tables together
  flights_roundtrips <- flights_roundtrips %>% 
    inner_join(ticket_summary, by=c("flightid" = "flightid"))
  
  flights_roundtrips <- flights_roundtrips %>% select(
    flightid,
    N_FLIGHTS,
    N_TICKETS,
    ORIGIN,
    DESTINATION,
    ORIGIN_SIZE,
    DEST_SIZE,
    ORIGIN_COOR,
    DEST_COOR,
    ORIGIN_NAME,
    DEST_NAME,
    AVG_ITIN_FARE,
    AVG_DEP_DELAY,
    AVG_ARR_DELAY,
    AVG_AIR_TIME,
    AVG_OCCUPANCY,
    DIST
  )
  bad <- impossible_airspeed(flights_roundtrips)
  flights_roundtrips <- flights_roundtrips[-bad, ]
  
  flights_roundtrips
}

join_data_slow <- function(AirportData, TicketData, FlightData) {
  big_airports <- clean_airports(AirportData)
  valid_flights <- clean_flights(FlightData, big_airports)
  tickets_roundtrip <- clean_tickets(TicketData, big_airports)
  uniquelevels <- unique(c(
    levels(factor(valid_flights$ORIGIN)),
    levels(factor(valid_flights$DESTINATION)),
    levels(factor(tickets_roundtrip$ORIGIN)),
    levels(factor(tickets_roundtrip$DESTINATION))
  ))
  airid_dict <- make_airid_dict(uniquelevels)
  airid <- airid_dict %>% mutate(NAME = rownames(airid_dict))
  rownames(airid) <- 1:nrow(airid)
  roundtripidmatrix <- make_roundtripid_matrix(uniquelevels)
  roundtripmatrix <<- roundtripidmatrix
  airid <<- airid
  valid_flights <- connect_airid(valid_flights, airid)
  # fid <- impute_flightid_cpp(valid_flights, roundtripidmatrix, airid)
  # valid_flights$flightid <- fid
  valid_flights <- impute_flightid(valid_flights, roundtripidmatrix, airid)
  tickets_roundtrip <- connect_airid(tickets_roundtrip, airid)
  tickets_roundtrip <- impute_flightid(tickets_roundtrip, roundtripidmatrix, airid)
  # fid <- impute_flightid_cpp(tickets_roundtrip, roundtripidmatrix, airid)
  # tickets_roundtrip$flightid <- fid
  # Now the tables are connected through the airid
  valid_flights <-
    valid_flights %>% mutate(
      DEP_DELAY = as.numeric(DEP_DELAY),
      ARR_DELAY = as.numeric(ARR_DELAY),
      OCCUPANCY_RATE = as.numeric(OCCUPANCY_RATE),
      DISTANCE = as.numeric(DISTANCE),
      AIR_TIME = as.numeric(AIR_TIME),
      DEST_SIZE = factor(DEST_SIZE),
      ORIGIN_SIZE = factor(ORIGIN_SIZE)
    )
  # Aggregate data down to link together
  busy_route <- valid_flights %>% group_by(ORIGIN, DESTINATION) %>%
    summarise(
      N_FLIGHTS = n(),
      ORIGIN_SIZE = mode(ORIGIN_SIZE),
      DEST_SIZE = mode(DEST_SIZE),
      flightid = mode(flightid)
    )
  
  summarydata <-
    valid_flights %>% group_by(flightid) %>%
    summarise(
      AVG_DEP_DELAY = mean(DEP_DELAY),
      AVG_ARR_DELAY = mean(ARR_DELAY, na.rm = TRUE),
      AVG_AIR_TIME = mean(AIR_TIME, na.rm = TRUE),
      DIST = mode(DISTANCE),
      AVG_OCCUPANCY = mean(OCCUPANCY_RATE, na.rm = TRUE),
    )
  
  flights_roundtrips <- busy_route %>% group_by(flightid) %>%
    summarise(
      N_FLIGHTS = min(N_FLIGHTS),
      ORIGIN = mode(ORIGIN),
      DESTINATION = mode(DESTINATION)
    ) %>%
    arrange(desc(N_FLIGHTS))
  flights_roundtrips <- flights_roundtrips %>%
    inner_join(big_airports[, c(1, 2, 4, 5)], by = c("ORIGIN" = "IATA_CODE")) %>%
    rename(
      "ORIGIN_NAME" = "NAME",
      "ORIGIN_SIZE" = "TYPE",
      "ORIGIN_COOR" = "COORDINATES"
    ) %>%
    inner_join(big_airports[, c(1, 2, 4, 5)], by = c("DESTINATION" = "IATA_CODE")) %>%
    rename(
      "DEST_NAME" = "NAME",
      "DEST_SIZE" = "TYPE",
      "DEST_COOR" = "COORDINATES"
    )
  
  tickets_roundtrip <-
    tickets_roundtrip[which(!is.na(tickets_roundtrip$ITIN_FARE)), ]
  ticket_summary <- tickets_roundtrip %>% group_by(flightid) %>%
    summarise(N_TICKETS = n(),
              AVG_ITIN_FARE = mean(ITIN_FARE)) %>%
    arrange(desc(N_TICKETS))
  
  flights_roundtrips <-
    inner_join(flights_roundtrips,
               summarydata,
               by = c("flightid" = "flightid"))
  ## Actually connects the three tables together
  flights_roundtrips <- flights_roundtrips %>% 
    inner_join(ticket_summary, by=c("flightid" = "flightid"))
  
  flights_roundtrips <- flights_roundtrips %>% select(
    flightid,
    N_FLIGHTS,
    N_TICKETS,
    ORIGIN,
    DESTINATION,
    ORIGIN_SIZE,
    DEST_SIZE,
    ORIGIN_COOR,
    DEST_COOR,
    ORIGIN_NAME,
    DEST_NAME,
    AVG_ITIN_FARE,
    AVG_DEP_DELAY,
    AVG_ARR_DELAY,
    AVG_AIR_TIME,
    AVG_OCCUPANCY,
    DIST
  )
  bad <- impossible_airspeed(flights_roundtrips)
  flights_roundtrips <- flights_roundtrips[-bad, ]
  
  flights_roundtrips
}


make_tripname <- function(data){
  TRIP_NAME <- 0
  for (i in 1:nrow(data)) {
    TRIP_NAME[i] <-
      inverse_id_name(roundtripmatrix, airid, data$flightid[i])
  }
  TRIP_NAME
}

unpack_latlon <- function(data) {
  latvec1 <- 0
  lonvec1 <- 0
  latvec2 <- 0
  lonvec2 <- 0
  for (i in 1:nrow(data)) {
    latlon1 <- as.character(data[i, "ORIGIN_COOR"])
    latlon2 <- as.character(data[i, "DEST_COOR"])
    lat <- as.numeric(unlist(strsplit(latlon1, ','))[1])
    long <- as.numeric(unlist(strsplit(latlon1, ','))[2])
    latvec1[i] <- lat
    lonvec1[i] <- long
    lat <- as.numeric(unlist(strsplit(latlon2, ','))[1])
    long <- as.numeric(unlist(strsplit(latlon2, ','))[2])
    latvec2[i] <- lat
    lonvec2[i] <- long
    
  }
  cbind(
    ORIGIN_LAT = latvec1,
    ORIGIN_LON = lonvec1,
    DEST_LAT = latvec2,
    DEST_LON = lonvec2
  )
}


breakeven <- function(per_flight_profit){
  cost <- 90000000
  c<- 1
  total <- 0
  
  while(total < cost){
    total <- total + per_flight_profit*c
    c<-c+1
  }
  c
}
