do_qc_against_obs <- function(
    infile = "data_provided/BoM_oberservations/data_provided/IDCJAC0010_009225_1800/IDCJAC0010_009225_1800_Data.csv"
){
  qc <- fread(infile)
  
  qc$date <- as.Date(paste(qc$Year, qc$Month, qc$Day, sep = "-"))
  str(qc)
  qc2 <- merge(dat_pop_weighted, qc, by = "date")
  names(qc2) <- make.names(names(qc2))
  png("figures_and_tables/qc_tmax_against_obs.png")
  with(qc2, plot(tmax, Maximum.temperature..Degree.C.))
  abline(0,1)
  dev.off()
  
}