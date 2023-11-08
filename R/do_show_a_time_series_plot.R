# tar_load(dat_pop_weighted)
do_show_a_time_series_plot <- function(
    dat_pop_weighted
){
  if(!dir.exists("figures_and_tables")) dir.create("figures_and_tables")
  png("figures_and_tables/qc_timeseries.png")
  par(mfrow = c(2,2))
  with(dat_pop_weighted, plot(date, tmax, ylim = c(0,45)))
  with(dat_pop_weighted, lines(date, tmin))
  with(dat_pop_weighted, plot(date, vapourpres_h09, ylim = c(0,30)))
  with(dat_pop_weighted, lines(date, vapourpres_h15))
  with(dat_pop_weighted, plot(date, precip, type = "h"))
  dev.off()
  
  qc <- fread("data_provided/BoM_oberservations/data_provided/IDCJAC0010_009225_1800/IDCJAC0010_009225_1800_Data.csv")
  
  qc$date <- as.Date(paste(qc$Year, qc$Month, qc$Day, sep = "-"))
  str(qc)
  qc2 <- merge(dat_pop_weighted, qc, by = "date")
  names(qc2) <- make.names(names(qc2))
  png("figures_and_tables/qc_tmax_against_obs.png")
  with(qc2, plot(tmax, Maximum.temperature..Degree.C.))
  abline(0,1)
  dev.off()
}
