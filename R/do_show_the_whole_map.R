# tar_load(load_and_extract)
# tar_load(load_ABS_SA1)
do_show_the_whole_map <- function(
    load_and_extract
    ,
    sa1 = load_ABS_SA1
){
  
  myplot <- function(
    date_i = load_and_extract$date[1]
    ,
    poll
    ){
    tomap <- load_and_extract[date == date_i,]
    sa1v2 <- merge(sa1, tomap, by = "SA1_MAIN16")
    
    png(paste0("figures_and_tables/qc_map_",poll,"_",date_i,".png"))
    plot(sa1v2[,poll])
    dev.off()
  }
  myplot(load_and_extract$date[1],"tmax")
  myplot(load_and_extract$date[1],"tmin")
  myplot(load_and_extract$date[1],"vapourpres_h09")
  myplot(load_and_extract$date[1], "vapourpres_h15")
  #myplot("precip")
  # no rain in summer in perth
  with(load_and_extract[SA1_MAIN16 == "50704117722" & date %in% seq(as.Date("2021-07-01"),
                                                                    as.Date("2021-07-31"),
                                                                    1)], plot(date, precip, type = 'l'))
  date_i <- as.Date("2021-07-27")
  myplot(date_i, "precip")
}