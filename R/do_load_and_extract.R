# tar_load(load_ABS_SA1)
do_load_and_extract <- function(
  infile = config$infile
  ,
  sa1 = load_ABS_SA1
  , 
  var_i = config$var_i
  ,
  yy_min = 2021
  , 
  yy_max = 2022
  , 
  variables = config$var_i
){
  #### load_and_extract for study period ####
  sa1_out <- list()
  for(yy in yy_min:yy_max){
    ## yy = 2022
    study_period <- list(mindate=paste0(yy,"-01-01"), maxdate =paste0(yy,"-01-10"))
    
    ## raster data for each var
    # print(var_i)
    b <- raster::brick(gsub("agcd_v1-0-1_tmax_mean_r005_daily_2022.nc", 
                            paste0("agcd_v1-0-1_tmax_mean_r005_daily_",yy,".nc"), infile), 
                       varname = var_i)
    # b
    # plot(b)
    b2 <- b[[which(getZ(b) >= as.Date(study_period[["mindate"]]) & getZ(b) <= as.Date(study_period[["maxdate"]]))]]
    # plot(b2)
    # WARNING TERRA EXTRACT MUCH SLOWER THAN EXACTEXTRACTR
    #b_sa1 <- terra::extract(b2, sa1, mean, na.rm = T)
    b2 <- brick(b2)
    b_sa1 <- exactextractr::exact_extract(b2, sa1, fun = "mean", progress = FALSE)
    out <- cbind(st_drop_geometry(sa1[,1]), b_sa1)
    setDT(out)
    
    out2 <- melt(out, id.vars = c(names(out)[1], "ID"))
    out2$measure <- var_i
    sa1_out[[yy]] <- out2
  }
  
  sa1_out2 <- rbindlist(sa1_out)
  # sa1_out2
  ## check a day
  sa1_out2[substr(sa1_out2$variable, 6, 11) == ".01.09"
           & SA1_MAIN16 == 60101100101 ]
  
  
  outdat <- sa1_out2
  # str(outdat)
  
  ## tidy up the dates
  outdat$date <- gsub("X","",outdat$variable)
  outdat$date <- as.Date(gsub("\\.","-",outdat$date))
  outdat$variable <- NULL
  outdat_wide <- dcast(outdat, SA1_MAIN16 + ID + date ~ measure, value.var = "value")
  
  ## get sa1 codes
  sa1_df <- st_drop_geometry(sa1)
  sa1_df$ID <- 1:nrow(sa1_df)
  setDT(sa1_df)
  
  outdat_wide2 <- merge(sa1_df[,.(SA1_MAIN16, SA1_7DIG16 , ID)], outdat_wide, by = "ID")
  # unique(outdat_wide2$SA1_7DIG16 )
  return(outdat_wide2)
}