library(readxl)
pwt90 <- read_excel("~/GoogleDrive/Datasets/pwt100.xlsx", 
                          sheet = "Data")

KOW <- cbind(pwt90[pwt90$countrycode == 'USA' & pwt90$year >= 1960, c('year', 'rgdpna', 'rconna', 'rnna')],
             pwt90[pwt90$countrycode == 'CAN' & pwt90$year >= 1960, c('rgdpna', 'rconna', 'rnna')],
             pwt90[pwt90$countrycode == 'MEX' & pwt90$year >= 1960, c('rgdpna', 'rconna', 'rnna')],
             pwt90[pwt90$countrycode == 'AUS' & pwt90$year >= 1960, c('rgdpna', 'rconna', 'rnna')],
             pwt90[pwt90$countrycode == 'NZL' & pwt90$year >= 1960, c('rgdpna', 'rconna', 'rnna')],
             pwt90[pwt90$countrycode == 'CRI' & pwt90$year >= 1960, c('rgdpna', 'rconna', 'rnna')],
             pwt90[pwt90$countrycode == 'DOM' & pwt90$year >= 1960, c('rgdpna', 'rconna', 'rnna')],
             pwt90[pwt90$countrycode == 'SLV' & pwt90$year >= 1960, c('rgdpna', 'rconna', 'rnna')],
             pwt90[pwt90$countrycode == 'GTM' & pwt90$year >= 1960, c('rgdpna', 'rconna', 'rnna')],
             pwt90[pwt90$countrycode == 'HND' & pwt90$year >= 1960, c('rgdpna', 'rconna', 'rnna')],
             pwt90[pwt90$countrycode == 'JAM' & pwt90$year >= 1960, c('rgdpna', 'rconna', 'rnna')],
             pwt90[pwt90$countrycode == 'PAN' & pwt90$year >= 1960, c('rgdpna', 'rconna', 'rnna')],
             #pwt90[pwt90$countrycode == 'TTO' & pwt90$year >= 1960, c('rgdpna', 'rconna', 'rnna')],
             pwt90[pwt90$countrycode == 'ARG' & pwt90$year >= 1960, c('rgdpna', 'rconna', 'rnna')],
             pwt90[pwt90$countrycode == 'BOL' & pwt90$year >= 1960, c('rgdpna', 'rconna', 'rnna')],
             pwt90[pwt90$countrycode == 'BRA' & pwt90$year >= 1960, c('rgdpna', 'rconna', 'rnna')],
             pwt90[pwt90$countrycode == 'CHL' & pwt90$year >= 1960, c('rgdpna', 'rconna', 'rnna')],
             pwt90[pwt90$countrycode == 'COL' & pwt90$year >= 1960, c('rgdpna', 'rconna', 'rnna')],
             pwt90[pwt90$countrycode == 'ECU' & pwt90$year >= 1960, c('rgdpna', 'rconna', 'rnna')],
             pwt90[pwt90$countrycode == 'PRY' & pwt90$year >= 1960, c('rgdpna', 'rconna', 'rnna')],
             pwt90[pwt90$countrycode == 'PER' & pwt90$year >= 1960, c('rgdpna', 'rconna', 'rnna')],
             pwt90[pwt90$countrycode == 'URY' & pwt90$year >= 1960, c('rgdpna', 'rconna', 'rnna')],
             #pwt90[pwt90$countrycode == 'VEN' & pwt90$year >= 1960, c('rgdpna', 'rconna', 'rnna')],
             pwt90[pwt90$countrycode == 'FRA' & pwt90$year >= 1960, c('rgdpna', 'rconna', 'rnna')],
             pwt90[pwt90$countrycode == 'AUT' & pwt90$year >= 1960, c('rgdpna', 'rconna', 'rnna')],
             pwt90[pwt90$countrycode == 'BEL' & pwt90$year >= 1960, c('rgdpna', 'rconna', 'rnna')],
             pwt90[pwt90$countrycode == 'DNK' & pwt90$year >= 1960, c('rgdpna', 'rconna', 'rnna')],
             pwt90[pwt90$countrycode == 'FIN' & pwt90$year >= 1960, c('rgdpna', 'rconna', 'rnna')],
             pwt90[pwt90$countrycode == 'DEU' & pwt90$year >= 1960, c('rgdpna', 'rconna', 'rnna')],
             pwt90[pwt90$countrycode == 'GRC' & pwt90$year >= 1960, c('rgdpna', 'rconna', 'rnna')],
             pwt90[pwt90$countrycode == 'ISL' & pwt90$year >= 1960, c('rgdpna', 'rconna', 'rnna')],
             pwt90[pwt90$countrycode == 'IRL' & pwt90$year >= 1960, c('rgdpna', 'rconna', 'rnna')],
             pwt90[pwt90$countrycode == 'ITA' & pwt90$year >= 1960, c('rgdpna', 'rconna', 'rnna')],
             pwt90[pwt90$countrycode == 'LUX' & pwt90$year >= 1960, c('rgdpna', 'rconna', 'rnna')],
             pwt90[pwt90$countrycode == 'NLD' & pwt90$year >= 1960, c('rgdpna', 'rconna', 'rnna')],
             pwt90[pwt90$countrycode == 'NOR' & pwt90$year >= 1960, c('rgdpna', 'rconna', 'rnna')],
             pwt90[pwt90$countrycode == 'PRT' & pwt90$year >= 1960, c('rgdpna', 'rconna', 'rnna')],
             pwt90[pwt90$countrycode == 'ESP' & pwt90$year >= 1960, c('rgdpna', 'rconna', 'rnna')],
             pwt90[pwt90$countrycode == 'SWE' & pwt90$year >= 1960, c('rgdpna', 'rconna', 'rnna')],
             pwt90[pwt90$countrycode == 'CHE' & pwt90$year >= 1960, c('rgdpna', 'rconna', 'rnna')],
             pwt90[pwt90$countrycode == 'GBR' & pwt90$year >= 1960, c('rgdpna', 'rconna', 'rnna')],
             pwt90[pwt90$countrycode == 'CMR' & pwt90$year >= 1960, c('rgdpna', 'rconna', 'rnna')],
             pwt90[pwt90$countrycode == 'CIV' & pwt90$year >= 1960, c('rgdpna', 'rconna', 'rnna')],
             pwt90[pwt90$countrycode == 'KEN' & pwt90$year >= 1960, c('rgdpna', 'rconna', 'rnna')],
             pwt90[pwt90$countrycode == 'MAR' & pwt90$year >= 1960, c('rgdpna', 'rconna', 'rnna')],
             pwt90[pwt90$countrycode == 'SEN' & pwt90$year >= 1960, c('rgdpna', 'rconna', 'rnna')],
             pwt90[pwt90$countrycode == 'ZAF' & pwt90$year >= 1960, c('rgdpna', 'rconna', 'rnna')],
             #pwt90[pwt90$countrycode == 'ZWE' & pwt90$year >= 1960, c('rgdpna', 'rconna', 'rnna')],
             pwt90[pwt90$countrycode == 'BGD' & pwt90$year >= 1960, c('rgdpna', 'rconna', 'rnna')],
             pwt90[pwt90$countrycode == 'IND' & pwt90$year >= 1960, c('rgdpna', 'rconna', 'rnna')],
             pwt90[pwt90$countrycode == 'IDN' & pwt90$year >= 1960, c('rgdpna', 'rconna', 'rnna')],
             pwt90[pwt90$countrycode == 'PAK' & pwt90$year >= 1960, c('rgdpna', 'rconna', 'rnna')],
             pwt90[pwt90$countrycode == 'PHL' & pwt90$year >= 1960, c('rgdpna', 'rconna', 'rnna')],
             pwt90[pwt90$countrycode == 'LKA' & pwt90$year >= 1960, c('rgdpna', 'rconna', 'rnna')],
             pwt90[pwt90$countrycode == 'HKG' & pwt90$year >= 1960, c('rgdpna', 'rconna', 'rnna')],
             pwt90[pwt90$countrycode == 'JPN' & pwt90$year >= 1960, c('rgdpna', 'rconna', 'rnna')],
             pwt90[pwt90$countrycode == 'KOR' & pwt90$year >= 1960, c('rgdpna', 'rconna', 'rnna')],
             pwt90[pwt90$countrycode == 'MYS' & pwt90$year >= 1960, c('rgdpna', 'rconna', 'rnna')],
             pwt90[pwt90$countrycode == 'SGP' & pwt90$year >= 1960, c('rgdpna', 'rconna', 'rnna')],
             pwt90[pwt90$countrycode == 'THA' & pwt90$year >= 1960, c('rgdpna', 'rconna', 'rnna')])
# KOW <- cbind(pwt90[pwt90$countrycode == 'USA' & pwt90$year >= 1960, c('year', 'rgdpna', 'rconna', 'rnna')],
#              pwt90[pwt90$countrycode == 'CAN' & pwt90$year >= 1960, c('rgdpna', 'rconna', 'rkna')],
#              pwt90[pwt90$countrycode == 'MEX' & pwt90$year >= 1960, c('rgdpna', 'rconna', 'rkna')],
#              pwt90[pwt90$countrycode == 'AUS' & pwt90$year >= 1960, c('rgdpna', 'rconna', 'rkna')],
#              pwt90[pwt90$countrycode == 'NZL' & pwt90$year >= 1960, c('rgdpna', 'rconna', 'rkna')],
#              pwt90[pwt90$countrycode == 'CRI' & pwt90$year >= 1960, c('rgdpna', 'rconna', 'rkna')],
#              pwt90[pwt90$countrycode == 'DOM' & pwt90$year >= 1960, c('rgdpna', 'rconna', 'rkna')],
#              pwt90[pwt90$countrycode == 'SLV' & pwt90$year >= 1960, c('rgdpna', 'rconna', 'rkna')],
#              pwt90[pwt90$countrycode == 'GTM' & pwt90$year >= 1960, c('rgdpna', 'rconna', 'rkna')],
#              pwt90[pwt90$countrycode == 'HND' & pwt90$year >= 1960, c('rgdpna', 'rconna', 'rkna')],
#              pwt90[pwt90$countrycode == 'JAM' & pwt90$year >= 1960, c('rgdpna', 'rconna', 'rkna')],
#              pwt90[pwt90$countrycode == 'PAN' & pwt90$year >= 1960, c('rgdpna', 'rconna', 'rkna')],
#              pwt90[pwt90$countrycode == 'TTO' & pwt90$year >= 1960, c('rgdpna', 'rconna', 'rkna')],
#              pwt90[pwt90$countrycode == 'ARG' & pwt90$year >= 1960, c('rgdpna', 'rconna', 'rkna')],
#              pwt90[pwt90$countrycode == 'BOL' & pwt90$year >= 1960, c('rgdpna', 'rconna', 'rkna')],
#              pwt90[pwt90$countrycode == 'BRA' & pwt90$year >= 1960, c('rgdpna', 'rconna', 'rkna')],
#              pwt90[pwt90$countrycode == 'CHL' & pwt90$year >= 1960, c('rgdpna', 'rconna', 'rkna')],
#              pwt90[pwt90$countrycode == 'COL' & pwt90$year >= 1960, c('rgdpna', 'rconna', 'rkna')],
#              pwt90[pwt90$countrycode == 'ECU' & pwt90$year >= 1960, c('rgdpna', 'rconna', 'rkna')],
#              pwt90[pwt90$countrycode == 'PRY' & pwt90$year >= 1960, c('rgdpna', 'rconna', 'rkna')],
#              pwt90[pwt90$countrycode == 'PER' & pwt90$year >= 1960, c('rgdpna', 'rconna', 'rkna')],
#              pwt90[pwt90$countrycode == 'URY' & pwt90$year >= 1960, c('rgdpna', 'rconna', 'rkna')],
#              pwt90[pwt90$countrycode == 'VEN' & pwt90$year >= 1960, c('rgdpna', 'rconna', 'rkna')],
#              pwt90[pwt90$countrycode == 'FRA' & pwt90$year >= 1960, c('rgdpna', 'rconna', 'rkna')],
#              pwt90[pwt90$countrycode == 'AUT' & pwt90$year >= 1960, c('rgdpna', 'rconna', 'rkna')],
#              pwt90[pwt90$countrycode == 'BEL' & pwt90$year >= 1960, c('rgdpna', 'rconna', 'rkna')],
#              pwt90[pwt90$countrycode == 'DNK' & pwt90$year >= 1960, c('rgdpna', 'rconna', 'rkna')],
#              pwt90[pwt90$countrycode == 'FIN' & pwt90$year >= 1960, c('rgdpna', 'rconna', 'rkna')],
#              pwt90[pwt90$countrycode == 'DEU' & pwt90$year >= 1960, c('rgdpna', 'rconna', 'rkna')],
#              pwt90[pwt90$countrycode == 'GRC' & pwt90$year >= 1960, c('rgdpna', 'rconna', 'rkna')],
#              pwt90[pwt90$countrycode == 'ISL' & pwt90$year >= 1960, c('rgdpna', 'rconna', 'rkna')],
#              pwt90[pwt90$countrycode == 'IRL' & pwt90$year >= 1960, c('rgdpna', 'rconna', 'rkna')],
#              pwt90[pwt90$countrycode == 'ITA' & pwt90$year >= 1960, c('rgdpna', 'rconna', 'rkna')],
#              pwt90[pwt90$countrycode == 'LUX' & pwt90$year >= 1960, c('rgdpna', 'rconna', 'rkna')],
#              pwt90[pwt90$countrycode == 'NLD' & pwt90$year >= 1960, c('rgdpna', 'rconna', 'rkna')],
#              pwt90[pwt90$countrycode == 'NOR' & pwt90$year >= 1960, c('rgdpna', 'rconna', 'rkna')],
#              pwt90[pwt90$countrycode == 'PRT' & pwt90$year >= 1960, c('rgdpna', 'rconna', 'rkna')],
#              pwt90[pwt90$countrycode == 'ESP' & pwt90$year >= 1960, c('rgdpna', 'rconna', 'rkna')],
#              pwt90[pwt90$countrycode == 'SWE' & pwt90$year >= 1960, c('rgdpna', 'rconna', 'rkna')],
#              pwt90[pwt90$countrycode == 'CHE' & pwt90$year >= 1960, c('rgdpna', 'rconna', 'rkna')],
#              pwt90[pwt90$countrycode == 'GBR' & pwt90$year >= 1960, c('rgdpna', 'rconna', 'rkna')],
#              pwt90[pwt90$countrycode == 'CMR' & pwt90$year >= 1960, c('rgdpna', 'rconna', 'rkna')],
#              pwt90[pwt90$countrycode == 'CIV' & pwt90$year >= 1960, c('rgdpna', 'rconna', 'rkna')],
#              pwt90[pwt90$countrycode == 'KEN' & pwt90$year >= 1960, c('rgdpna', 'rconna', 'rkna')],
#              pwt90[pwt90$countrycode == 'MAR' & pwt90$year >= 1960, c('rgdpna', 'rconna', 'rkna')],
#              pwt90[pwt90$countrycode == 'SEN' & pwt90$year >= 1960, c('rgdpna', 'rconna', 'rkna')],
#              pwt90[pwt90$countrycode == 'ZAF' & pwt90$year >= 1960, c('rgdpna', 'rconna', 'rkna')],
#              pwt90[pwt90$countrycode == 'ZWE' & pwt90$year >= 1960, c('rgdpna', 'rconna', 'rkna')],
#              pwt90[pwt90$countrycode == 'BGD' & pwt90$year >= 1960, c('rgdpna', 'rconna', 'rkna')],
#              pwt90[pwt90$countrycode == 'IND' & pwt90$year >= 1960, c('rgdpna', 'rconna', 'rkna')],
#              pwt90[pwt90$countrycode == 'IDN' & pwt90$year >= 1960, c('rgdpna', 'rconna', 'rkna')],
#              pwt90[pwt90$countrycode == 'PAK' & pwt90$year >= 1960, c('rgdpna', 'rconna', 'rkna')],
#              pwt90[pwt90$countrycode == 'PHL' & pwt90$year >= 1960, c('rgdpna', 'rconna', 'rkna')],
#              pwt90[pwt90$countrycode == 'LKA' & pwt90$year >= 1960, c('rgdpna', 'rconna', 'rkna')],
#              pwt90[pwt90$countrycode == 'HKG' & pwt90$year >= 1960, c('rgdpna', 'rconna', 'rkna')],
#              pwt90[pwt90$countrycode == 'JPN' & pwt90$year >= 1960, c('rgdpna', 'rconna', 'rkna')],
#              pwt90[pwt90$countrycode == 'KOR' & pwt90$year >= 1960, c('rgdpna', 'rconna', 'rkna')],
#              pwt90[pwt90$countrycode == 'MYS' & pwt90$year >= 1960, c('rgdpna', 'rconna', 'rkna')],
#              pwt90[pwt90$countrycode == 'SGP' & pwt90$year >= 1960, c('rgdpna', 'rconna', 'rkna')],
#              pwt90[pwt90$countrycode == 'THA' & pwt90$year >= 1960, c('rgdpna', 'rconna', 'rkna')])

colnames(KOW) <- c('year', 'rgdpnaUSA', 'rconnaUSA', 'rcapUSA',
  'rgdpnaCAN', 'rconnaCAN', 'rcapCAN',
  'rgdpnaMEX', 'rconnaMEX', 'rcapMEX',
  'rgdpnaAUS', 'rconnaAUS', 'rcapAUS',
  'rgdpnaNZL', 'rconnaNZL', 'rcapNZL',
  'rgdpnaCRI', 'rconnaCRI', 'rcapCRI',
  'rgdpnaDOM', 'rconnaDOM', 'rcapDOM',
  'rgdpnaSLV', 'rconnaSLV', 'rcapSLV',
  'rgdpnaGTM', 'rconnaGTM', 'rcapGTM',
  'rgdpnaHND', 'rconnaHND', 'rcapHND',
  'rgdpnaJAM', 'rconnaJAM', 'rcapJAM',
  'rgdpnaPAN', 'rconnaPAN', 'rcapPAN',
  #'rgdpnaTTO', 'rconnaTTO', 'rcapTTO',
  'rgdpnaARG', 'rconnaARG', 'rcapARG',
  'rgdpnaBOL', 'rconnaBOL', 'rcapBOL',
  'rgdpnaBRA', 'rconnaBRA', 'rcapBRA',
  'rgdpnaCHL', 'rconnaCHL', 'rcapCHL',
  'rgdpnaCOL', 'rconnaCOL', 'rcapCOL',
  'rgdpnaECU', 'rconnaECU', 'rcapECU',
  'rgdpnaPRY', 'rconnaPRY', 'rcapPRY',
  'rgdpnaPER', 'rconnaPER', 'rcapPER',
  'rgdpnaURY', 'rconnaURY', 'rcapURY',
  #'rgdpnaVEN', 'rconnaVEN', 'rcapVEN',
  'rgdpnaFRA', 'rconnaFRA', 'rcapFRA',
  'rgdpnaAUT', 'rconnaAUT', 'rcapAUT',
  'rgdpnaBEL', 'rconnaBEL', 'rcapBEL',
  'rgdpnaDNK', 'rconnaDNK', 'rcapDNK',
  'rgdpnaFIN', 'rconnaFIN', 'rcapFIN',
  'rgdpnaDEU', 'rconnaDEU', 'rcapDEU',
  'rgdpnaGRC', 'rconnaGRC', 'rcapGRC',
  'rgdpnaISL', 'rconnaISL', 'rcapISL',
  'rgdpnaIRL', 'rconnaIRL', 'rcapIRL',
  'rgdpnaITA', 'rconnaITA', 'rcapITA',
  'rgdpnaLUX', 'rconnaLUX', 'rcapLUX',
  'rgdpnaNLD', 'rconnaNLD', 'rcapNLD',
  'rgdpnaNOR', 'rconnaNOR', 'rcapNOR',
  'rgdpnaPRT', 'rconnaPRT', 'rcapPRT',
  'rgdpnaESP', 'rconnaESP', 'rcapESP',
  'rgdpnaSWE', 'rconnaSWE', 'rcapSWE',
  'rgdpnaCHE', 'rconnaCHE', 'rcapCHE',
  'rgdpnaGBR', 'rconnaGBR', 'rcapGBR',
  'rgdpnaCMR', 'rconnaCMR', 'rcapCMR',
  'rgdpnaCIV', 'rconnaCIV', 'rcapCIV',
  'rgdpnaKEN', 'rconnaKEN', 'rcapKEN',
  'rgdpnaMAR', 'rconnaMAR', 'rcapMAR',
  'rgdpnaSEN', 'rconnaSEN', 'rcapSEN',
  'rgdpnaZAF', 'rconnaZAF', 'rcapZAF',
  #'rgdpnaZWE', 'rconnaZWE', 'rcapZWE',
  'rgdpnaBGD', 'rconnaBGD', 'rcapBGD',
  'rgdpnaIND', 'rconnaIND', 'rcapIND',
  'rgdpnaIDN', 'rconnaIDN', 'rcapIDN',
  'rgdpnaPAK', 'rconnaPAK', 'rcapPAK',
  'rgdpnaPHL', 'rconnaPHL', 'rcapPHL',
  'rgdpnaLKA', 'rconnaLKA', 'rcapLKA',
  'rgdpnaHKG', 'rconnaHKG', 'rcapHKG',
  'rgdpnaJPN', 'rconnaJPN', 'rcapJPN',
  'rgdpnaKOR', 'rconnaKOR', 'rcapKOR',
  'rgdpnaMYS', 'rconnaMYS', 'rcapMYS',
  'rgdpnaSGP', 'rconnaSGP', 'rcapSGP',
  'rgdpnaTHA', 'rconnaTHA', 'rcapTHA')

numcols = ncol(KOW)
KOWlfd <- log(KOW[2:nrow(KOW),2:ncol(KOW)]) - log(KOW[1:nrow(KOW)-1, 2:numcols])

codePath <- '~/CodeProjects/CProjects/build/'
dataPath <- '~/GoogleDrive/Datasets/'



r <- nrow(KOWlfd)/3
ncolkow <- ncol(KOWlfd) 
Xt <- matrix(0, nrow=3*r*(ncolkow-1), ncol=3)
