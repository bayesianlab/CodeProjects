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
             pwt90[pwt90$countrycode == 'TTO' & pwt90$year >= 1960, c('rgdpna', 'rconna', 'rnna')],
             pwt90[pwt90$countrycode == 'ARG' & pwt90$year >= 1960, c('rgdpna', 'rconna', 'rnna')],
             pwt90[pwt90$countrycode == 'BOL' & pwt90$year >= 1960, c('rgdpna', 'rconna', 'rnna')],
             pwt90[pwt90$countrycode == 'BRA' & pwt90$year >= 1960, c('rgdpna', 'rconna', 'rnna')],
             pwt90[pwt90$countrycode == 'CHL' & pwt90$year >= 1960, c('rgdpna', 'rconna', 'rnna')],
             pwt90[pwt90$countrycode == 'COL' & pwt90$year >= 1960, c('rgdpna', 'rconna', 'rnna')],
             pwt90[pwt90$countrycode == 'ECU' & pwt90$year >= 1960, c('rgdpna', 'rconna', 'rnna')],
             pwt90[pwt90$countrycode == 'PRY' & pwt90$year >= 1960, c('rgdpna', 'rconna', 'rnna')],
             pwt90[pwt90$countrycode == 'PER' & pwt90$year >= 1960, c('rgdpna', 'rconna', 'rnna')],
             pwt90[pwt90$countrycode == 'URY' & pwt90$year >= 1960, c('rgdpna', 'rconna', 'rnna')],
             pwt90[pwt90$countrycode == 'VEN' & pwt90$year >= 1960, c('rgdpna', 'rconna', 'rnna')],
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
             pwt90[pwt90$countrycode == 'ZWE' & pwt90$year >= 1960, c('rgdpna', 'rconna', 'rnna')],
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

colnames(KOW) <- c('year', 'rgdpnaUSA', 'rconnaUSA', 'rnnaUSA',
  'rgdpnaCAN', 'rconnaCAN', 'rnnaCAN',
  'rgdpnaMEX', 'rconnaMEX', 'rnnaMEX',
  'rgdpnaAUS', 'rconnaAUS', 'rnnaAUS',
  'rgdpnaNZL', 'rconnaNZL', 'rnnaNZL',
  'rgdpnaCRI', 'rconnaCRI', 'rnnaCRI',
  'rgdpnaDOM', 'rconnaDOM', 'rnnaDOM',
  'rgdpnaSLV', 'rconnaSLV', 'rnnaSLV',
  'rgdpnaGTM', 'rconnaGTM', 'rnnaGTM',
  'rgdpnaHND', 'rconnaHND', 'rnnaHND',
  'rgdpnaJAM', 'rconnaJAM', 'rnnaJAM',
  'rgdpnaPAN', 'rconnaPAN', 'rnnaPAN',
  'rgdpnaTTO', 'rconnaTTO', 'rnnaTTO',
  'rgdpnaARG', 'rconnaARG', 'rnnaARG',
  'rgdpnaBOL', 'rconnaBOL', 'rnnaBOL',
  'rgdpnaBRA', 'rconnaBRA', 'rnnaBRA',
  'rgdpnaCHL', 'rconnaCHL', 'rnnaCHL',
  'rgdpnaCOL', 'rconnaCOL', 'rnnaCOL',
  'rgdpnaECU', 'rconnaECU', 'rnnaECU',
  'rgdpnaPRY', 'rconnaPRY', 'rnnaPRY',
  'rgdpnaPER', 'rconnaPER', 'rnnaPER',
  'rgdpnaURY', 'rconnaURY', 'rnnaURY',
  'rgdpnaVEN', 'rconnaVEN', 'rnnaVEN',
  'rgdpnaFRA', 'rconnaFRA', 'rnnaFRA',
  'rgdpnaAUT', 'rconnaAUT', 'rnnaAUT',
  'rgdpnaBEL', 'rconnaBEL', 'rnnaBEL',
  'rgdpnaDNK', 'rconnaDNK', 'rnnaDNK',
  'rgdpnaFIN', 'rconnaFIN', 'rnnaFIN',
  'rgdpnaDEU', 'rconnaDEU', 'rnnaDEU',
  'rgdpnaGRC', 'rconnaGRC', 'rnnaGRC',
  'rgdpnaISL', 'rconnaISL', 'rnnaISL',
  'rgdpnaIRL', 'rconnaIRL', 'rnnaIRL',
  'rgdpnaITA', 'rconnaITA', 'rnnaITA',
  'rgdpnaLUX', 'rconnaLUX', 'rnnaLUX',
  'rgdpnaNLD', 'rconnaNLD', 'rnnaNLD',
  'rgdpnaNOR', 'rconnaNOR', 'rnnaNOR',
  'rgdpnaPRT', 'rconnaPRT', 'rnnaPRT',
  'rgdpnaESP', 'rconnaESP', 'rnnaESP',
  'rgdpnaSWE', 'rconnaSWE', 'rnnaSWE',
  'rgdpnaCHE', 'rconnaCHE', 'rnnaCHE',
  'rgdpnaGBR', 'rconnaGBR', 'rnnaGBR',
  'rgdpnaCMR', 'rconnaCMR', 'rnnaCMR',
  'rgdpnaCIV', 'rconnaCIV', 'rnnaCIV',
  'rgdpnaKEN', 'rconnaKEN', 'rnnaKEN',
  'rgdpnaMAR', 'rconnaMAR', 'rnnaMAR',
  'rgdpnaSEN', 'rconnaSEN', 'rnnaSEN',
  'rgdpnaZAF', 'rconnaZAF', 'rnnaZAF',
  'rgdpnaZWE', 'rconnaZWE', 'rnnaZWE',
  'rgdpnaBGD', 'rconnaBGD', 'rnnaBGD',
  'rgdpnaIND', 'rconnaIND', 'rnnaIND',
  'rgdpnaIDN', 'rconnaIDN', 'rnnaIDN',
  'rgdpnaPAK', 'rconnaPAK', 'rnnaPAK',
  'rgdpnaPHL', 'rconnaPHL', 'rnnaPHL',
  'rgdpnaLKA', 'rconnaLKA', 'rnnaLKA',
  'rgdpnaHKG', 'rconnaHKG', 'rnnaHKG',
  'rgdpnaJPN', 'rconnaJPN', 'rnnaJPN',
  'rgdpnaKOR', 'rconnaKOR', 'rnnaKOR',
  'rgdpnaMYS', 'rconnaMYS', 'rnnaMYS',
  'rgdpnaSGP', 'rconnaSGP', 'rnnaSGP',
  'rgdpnaTHA', 'rconnaTHA', 'rnnaTHA')

KOWpercent <- (KOW[2:nrow(KOW),2:181] - KOW[1:nrow(KOW)-1, 2:181])/KOW[2:nrow(KOW), 2:181]
KOWlfd <- log(KOW[2:nrow(KOW),2:181]) - log(KOW[1:nrow(KOW)-1, 2:181])
k <- round(t(KOWlfd), 10)
kz <- (k-apply(k, 1, mean))/apply(k,1, sd)

codePath <- '~/CodeProjects/CProjects/build/'
dataPath <- '~/GoogleDrive/Datasets/'

yt <- k[,2:ncol(k)]
ytz <- kz[,2:ncol(k)]
write.table(ytz, paste(codePath, 'kowz.csv', sep=''), row.names = FALSE, col.names=FALSE, sep=",")
write.table(k[,2:ncol(k)], paste(codePath, 'kow.csv', sep=''), row.names = FALSE, col.names=FALSE, sep=",")
r <- nrow(k)/3
Xtz <- matrix(0, nrow=3*r*(ncol(k)-1), ncol=3)
Xt <- matrix(0, nrow=3*r*(ncol(k)-1), ncol=3)
ones <-matrix(rep(1,3,1), nrow=3, ncol=1)
for(t in 1:(ncol(k)-1))
{
  for (j in 1:r)
  {
    w <- (1:3) + ((j-1)*3)
    q <- w + ( (t-1)*180 )
    Xtz[q, ] = kronecker(ones, t(as.matrix(kz[w, t])))
    Xt[q, ] = kronecker(ones, t(as.matrix(k[w, t])))
  }
}
write.table(Xtz, paste(codePath, 'kowXtz.csv', sep=''), row.names = FALSE, col.names=FALSE, sep=",")
write.table(Xt, paste(codePath, 'kowXt.csv', sep=''), row.names = FALSE, col.names=FALSE, sep=",")

years <- 1980:1990
print(dim(ytz))
for (y in 1:10)
{
  ending <- kz[,1:(20+y-1)]
  beginning <- kz[,(20+y):dim(kz)[2]]
  beg <- beginning[,2:dim(beginning)[2]]
  end <- ending[,2:dim(ending)[2]]
  print(dim(beg))
  print(dim(end))
  begnameyt <- sprintf("yt_%d_beg.csv",years[y]+1)
  endnameyt <- sprintf("yt_%d_end.csv",years[y])
  begnameXt <- sprintf("Xt_%d_beg.csv",years[y]+1)
  endnameXt <- sprintf("Xt_%d_end.csv",years[y])
  Xtbeg <- matrix(0, nrow=3*r*(ncol(beg)-1), ncol=3)
  Xtend <- matrix(0, nrow=3*r*(ncol(end)-1), ncol=3)
  for(t in 1:(ncol(beg)-1))
  {
    for (j in 1:r)
    {
      w <- (1:3) + ((j-1)*3)
      q <- w + ( (t-1)*180 )
      Xtbeg[q, ] = kronecker(ones, t(as.matrix(beginning[w, t])))
    }
  }
  for(t in 1:(ncol(end)-1))
  {
    for (j in 1:r)
    {
      w <- (1:3) + ((j-1)*3)
      q <- w + ( (t-1)*180 )
      Xtend[q, ] = kronecker(ones, t(as.matrix(ending[w, t])))
    }
  }
  write.table(beg, paste(paste(codePath, "timebreaks/", sep=''), begnameyt,sep=''), 
              row.names=FALSE,col.names=FALSE,sep=",")
  write.table(Xtbeg, paste(paste(codePath, "timebreaks/", sep=''), begnameXt,sep=''), 
              row.names=FALSE,col.names=FALSE,sep=",")
  write.table(end, paste(paste(codePath, "timebreaks/", sep=''), endnameyt,sep=''), 
              row.names=FALSE,col.names=FALSE,sep=",")
  write.table(Xtend, paste(paste(codePath, "timebreaks/", sep=''), endnameXt,sep=''), 
              row.names=FALSE,col.names=FALSE,sep=",")
}

# setwd("~/CodeProjects/CProjects/build")
# for(y in 1:10)
# {
#   begnameyt <- sprintf("yt_%d_beg.csv",years[y]+1)
#   begnameXt <- sprintf("Xt_%d_beg.csv",years[y]+1)
#   com1 <- paste("timebreaks/", begnameyt, sep="")
#   com2 <- paste(" timebreaks/", begnameXt, sep="")
#   com3 <- paste("./tb ")
#   command <- paste(com3, paste(com1, com2))
#   system(command)
# }
# for(y in 1:10)
# {
#   endnameyt <- sprintf("yt_%d_end.csv",years[y])
#   endnameXt <- sprintf("Xt_%d_end.csv",years[y])
#   com1 <- paste("timebreaks/", endnameyt, sep="")
#   com2 <- paste(" timebreaks/", endnameXt, sep="")
#   com3 <- paste("./tb ")
#   command <- paste(com3, paste(com1, com2))
#   system(command)
# }

tbbeg <- data.frame(rbind(c(-7919.92, "beg1981"),
c(-7629.77, "beg1982"),
c(-7448.75, "beg1983"),
c(-7281.12, "beg1984"),
c(-7082.96, "beg1985"),
c(-6883, "beg1986"),
c(-6713.52, "beg1987"),
c(-6449.11, "beg1988"),
c(-6210.19, "beg1989"),
c(-6096.6, "beg1990")))

tbend <- data.frame(rbind(c(-5266.75, "end1980"),
c(-5405.46, "end1981"),
c(-5745.68, "end1982"),
c(-5938.99, "end1983"),
c(-6147.34, "end1984"),
c(-6350.31, "end1985"),
c(-6581.35, "end1986"),
c(-6787.35, "end1987"),
c(-7082.75, "end1988"),
c(-7218.1, "end1989")))

tb <- data.frame(Date=1980:1989, ML=as.numeric(tbbeg$X1) + as.numeric(tbend$X1))

library(ggplot2)
ggplot(data=tb, aes(x=Date, y = ML)) + geom_line() + theme(text=element_text(size=20), axis.text.x=element_text(size=20),
                                                           axis.text.y=element_text(size=20), panel.grid.minor = element_blank(),
                                                           panel.background = element_blank(), axis.line = element_line(colour = "black")) + 
  xlab("Date") + ylab("Marginal Likelihood") + 
  
  scale_x_continuous(breaks=1980:1989) + geom_hline(yintercept=-12370, color="red", linetype="dashed")

