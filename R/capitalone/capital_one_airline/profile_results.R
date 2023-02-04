library(profvis)
source('flight_functions.R')
Airports <-
  read_csv("/home/dillon/CodeProjects/R/capitalone/Airport_Codes.csv")
Tickets <-
  read_csv("/home/dillon/CodeProjects/R/capitalone/Tickets.csv")
Flights <-
  read_csv("/home/dillon/CodeProjects/R/capitalone/Flights.csv")
profvis(
  {join_data(Airports, Tickets, Flights)}
)
profvis(
  {join_data_slow(Airports, Tickets, Flights)}
  )
