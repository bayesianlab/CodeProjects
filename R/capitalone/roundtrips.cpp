#include <Rcpp.h> 
#include <vector>
#include <string>
#include "roundtrips_help.hpp"

using namespace Rcpp; 
using namespace std; 

// [[Rcpp::export]]

DataFrame getMatches(Rcpp::DataFrame X){
  /* Finds matches in the flight data frame
   * Creates a new departure column and return column
   * These columns are the distinct row id number 
   * given to the flight data. Each departure id
   * is connected to a return id if the same plane went
   * to an airport and then returned again to the same airport.
   * Therefore a plane going from ORD to JFK in the flight database
   * with rowid 1 will also have a flight from JFK to ORD with 
   * a different rowid.  
   */ 
  Matches M; 
  M.findMatch(X["ORIGIN"], X["DESTINATION"], X["ID"]);
  DataFrame D = DataFrame::create(Named("DEPARTURE") = M.m1, 
                                  Named("RETURN") = M.m2);
  return D; 
  }