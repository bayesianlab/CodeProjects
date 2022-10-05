setwd('/home/dillon/CodeProjects/R/capitalone')
library(dplyr)
library(readr)
library(Rcpp)
library(stringi)

clean_airport_codes <- function(codes) {
  df <- codes[codes$TYPE == "medium_airport" |
                codes$TYPE == "large_airport",]
  df <- df[which(df$ISO_COUNTRY == "US"),]
  df <- df[which(!is.na(df$IATA_CODE)),]
  df
}

filter_airports <- function(valid_airports, flight_data) {
  codes <- data.frame(IATA_CODE = valid_airports$IATA_CODE)
  x <-
    merge(flight_data, codes, by.x = "ORIGIN", by.y = "IATA_CODE")
  x <- merge(x, codes, by.x = "DESTINATION", by.y = "IATA_CODE")
}

drop_cancelled <- function(flight_data) {
  flight_data <- flight_data[which(flight_data$CANCELLED == 0), ]
  flight_data
}

drop_oneways <- function(ticketdata) {
  ticketdata <- ticketdata[ticketdata$ROUNDTRIP == 1, ]
  ticketdata <- select(ticketdata, -ROUNDTRIP)
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

make_roundtripid <- function(uniquelevels) {
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
      r <- airid_dict[data$ORIGIN[i],]
      c <- airid_dict[data$DESTINATION[i],]
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
  x <- lower.tri(tripidmat) * tripidmat
  rc <- which(id == x, arr.ind = TRUE)
  rc
}

inverse_id_name <- function(tripidmat, airid, id) {
  rc <- inverse_id_rc(tripidmat, id)
  n1 <- airid[which(airid$AIRID == rc[1]), 2]
  n2 <- airid[which(airid$AIRID == rc[2]), 2]
  n <- paste(n1, n2, sep = '')
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

compute_flightcost <- function(flight_data){
  cost = list()
  for (i in 1:nrow(flight_data)) {
    org_size <- as.numeric(flight_data[i, "ORIGIN_SIZE"])
    dest_size <- as.numeric(flight_data[i, "DEST_SIZE"])
    dist <- as.numeric(flight_data[i, "DIST"])
    ar_delay <- as.numeric(flight_data[i, "AVG_ARR_DELAY"])
    dep_delay<- as.numeric(flight_data[i, "AVG_DEP_DELAY"])
    cost[[i]] <-
      flight_costs(dist, org_size, dest_size, ar_delay, dep_delay)
  }
  cost <- do.call(rbind, cost)
  cost
}