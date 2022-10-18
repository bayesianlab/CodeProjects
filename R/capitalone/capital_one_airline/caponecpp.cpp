#include <Rcpp.h>
#include <bits/stdc++.h>
using namespace Rcpp;
using namespace std; 
// This is a simple example of exporting a C++ function to R. You can
// source this function into an R session using the Rcpp::sourceCpp 
// function (or via the Source button on the editor toolbar). Learn
// more about Rcpp at:
//
//   http://www.rcpp.org/
//   http://adv-r.had.co.nz/Rcpp.html
//   http://gallery.rcpp.org/
//

// [[Rcpp::export]]
vector<int> impute_flightid_cpp(DataFrame F, NumericMatrix M, DataFrame Airid) {
  NumericVector Rowid =  F["ORG_AIRID"];
  NumericVector Colid = F["DEST_AIRID"];
  vector<int> flightid; 
  for(int i = 0; i < Rowid.size(); ++i){
    flightid.push_back(M(Rowid(i)-1, Colid(i)-1));
  }
  return flightid; 
}


// You can include R code blocks in C++ files processed with sourceCpp
// (useful for testing and development). The R code will be automatically 
// run after the compilation.
//

/*** R


  
  */
