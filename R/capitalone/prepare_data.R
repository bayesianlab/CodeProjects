source("/home/dillon/CodeProjects/R/capitalone/flight_functions.R")

Airport_Codes <-
  read_csv("/home/dillon/CodeProjects/R/capitalone/Airport_Codes.csv")
Tickets <-
  read_csv("/home/dillon/CodeProjects/R/capitalone/Tickets.csv")
Flights <-
  read_csv("/home/dillon/CodeProjects/R/capitalone/Flights.csv")

##  Data Quality Insights
colSums(is.na(Flights))
colSums(is.na(Tickets))
# 1. na's for distances of flights. Flights connecting the same two 
# airports have good data for distance in the file. This does cause problems
# for computing the distances unless these values are dealt with by dropping
# them. Example, BWI to DFW has many NA's, however, the distance is known
# from other records in the data:
Flights[which(is.na(Flights$DISTANCE)),]
Flights %>% filter(ORIGIN == "BWI" & DESTINATION == "DFW") %>%
  select(ORIGIN, DESTINATION, DISTANCE)
# 2. The same issue of NA's occurs with ITIN_FARE. Several are missing which
# did cause problems computing an average itinerary fare. 
# 3. Computing round trips flights is ambiguous with this dataset. Planes that 
# return to and from the same airports exist in the data, however, if this 
# should qualify as a roundtrip is not clear. In the Tickets dataset passengers
# who purchased roundtrip tickets are known by the column ROUNDTRIP, however,
# they may have connecting flights in between their origin and destination. 
# Therefore, it is difficult to know if flights that are round trip are actually
# the best roundtrip routes, since connections are not taken into account. 
# The tickets and flights dataset can only be connected through the origin
# and destination airports, which most likely were taken on a variety of flights. 

## Cleaning the data for use
## Airports, only medium and large used
big_airports <- clean_airport_codes(Airport_Codes)
big_airports <-
  select(big_airports, -c(CONTINENT, MUNICIPALITY, ISO_COUNTRY))
## Flights, eliminate canceled flights and flights in and out of small 
# airports
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

## Tickets
tickets_roundtrip <- drop_oneways(Tickets)
tickets_roundtrip$ITIN_FARE <-
  as.numeric(tickets_roundtrip$ITIN_FARE)
tickets_roundtrip <- select(tickets_roundtrip,
                            ORIGIN, PASSENGERS, ITIN_FARE, DESTINATION)
tickets_roundtrip$rowid <- 1:nrow(tickets_roundtrip)
tickets_roundtrip <-
  tickets_roundtrip %>% inner_join(big_airports[, c(1, 4)],
                                   by = c("ORIGIN" = "IATA_CODE")) %>%
  rename(origin_airport_size = TYPE) %>%
  inner_join(big_airports[, c(1, 4)],
             by = c("DESTINATION" = "IATA_CODE")) %>%
  rename(dest_airport_size = TYPE)
## Data is cleaned and ready to connect together

uniquelevels <- unique(c(
  levels(factor(valid_flights$ORIGIN)),
  levels(factor(valid_flights$DESTINATION)),
  levels(factor(tickets_roundtrip$ORIGIN)),
  levels(factor(tickets_roundtrip$DESTINATION))
))
airid_dict <- make_airid_dict(uniquelevels)
airid <- airid_dict %>% mutate(NAME = rownames(airid_dict))
rownames(airid) <- 1:nrow(airid)
roundtripid <- make_roundtripid(uniquelevels)

## Connect Flights and Tickets through the airid
valid_flights <-
  inner_join(valid_flights, airid, by = c("ORIGIN" = "NAME"))
valid_flights <- rename(valid_flights, ORG_AIRID = AIRID)
valid_flights <-
  inner_join(valid_flights, airid, by = c("DESTINATION" = "NAME"))
valid_flights <- rename(valid_flights, DEST_AIRID = AIRID)

tickets_roundtrip <- tickets_roundtrip %>%
  inner_join(airid, by = c("ORIGIN" = "NAME")) %>%
  rename(ORG_AIRID = AIRID) %>%
  inner_join(airid, by = c("DESTINATION" = "NAME")) %>%
  rename(DEST_AIRID = AIRID)


valid_flights <-
  impute_flightid(valid_flights, roundtripid, airid_dict)
tickets_roundtrip <-
  impute_flightid(tickets_roundtrip, roundtripid, airid_dict)


valid_flights <-
  select(
    valid_flights,
    ORIGIN,
    DESTINATION,
    ORIGIN_AIRPORT_ID,
    DEST_AIRPORT_ID,
    ORIGIN_CITY_NAME,
    DEST_CITY_NAME,
    TAIL_NUM,
    DEP_DELAY,
    ARR_DELAY,
    AIR_TIME,
    DISTANCE,
    OCCUPANCY_RATE,
    ORIGIN_SIZE,
    DEST_SIZE,
    ORIGIN_AIRPORT_NAME,
    DEST_AIRPORT_NAME,
    ORIGIN_COOR,
    DEST_COOR,
    flightid
  )
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

# Busiest Flight Route
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
    ORIGIN_AIRPORT_NAME = mode(ORIGIN_AIRPORT_NAME),
    DEST_AIRPORT_NAME = mode(DEST_AIRPORT_NAME),
    ORIGIN_COOR = mode(ORIGIN_COOR),
    DEST_COOR = mode(DEST_COOR)
  )

flights_roundtrips <- busy_route %>% group_by(flightid) %>%
  summarise(
    N_FLIGHTS = min(N_FLIGHTS),
    ORIGIN_SIZE = mode(ORIGIN_SIZE),
    DEST_SIZE = mode(DEST_SIZE),
    ORIGIN = mode(ORIGIN),
    DESTINATION = mode(DESTINATION)
  ) %>%
  arrange(desc(N_FLIGHTS))

tickets_roundtrip <-
  tickets_roundtrip[which(!is.na(tickets_roundtrip$ITIN_FARE)),]

ticket_summary <- tickets_roundtrip %>% group_by(flightid) %>%
  summarise(N_TICKETS = n(),
            AVG_ITIN_FARE = mean(ITIN_FARE)) %>%
  arrange(desc(N_TICKETS))


## Actually connects the three tables together
flights_roundtrips <-
  inner_join(flights_roundtrips, summarydata, by = c("flightid" = "flightid"))


ten_busiest <- flights_roundtrips[1:10,]

popular_flights <-
  flights_roundtrips %>% inner_join(ticket_summary, by = c("flightid" = "flightid"))
popular_flights$FLIGHT_REV <- compute_flightrev(popular_flights)
popular_flights$FLIGHT_COST <- compute_flightcost(popular_flights)
popular_flights <- popular_flights %>% 
  mutate(PROFIT = (FLIGHT_REV - FLIGHT_COST)) %>%
  arrange(desc(PROFIT))

