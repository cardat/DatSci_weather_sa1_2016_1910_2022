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
  ,
  tidy_up = F
){
  #### load_and_extract for study period ####
  dir_store <- "data_provided/agcd_v1-0-1"
  if(!dir.exists(dir_store)) dir.create(dir_store)
  
  ## raster data for each var
  sa1_out2_by_var <- list()
  for(var_i in c("tmax", "tmin", "vapourpres_h09", "vapourpres_h15", "precip")){
    # var_i = "tmin"
    print(var_i)
  
  sa1_out <- list()
  for(yy in yy_min:yy_max){
    ## yy = 2021
    print(yy)
    
    # infile <- paste0("https://dapds00.nci.org.au/thredds/dodsC/zv2/agcd/v1-0-1/tmax/mean/r005/01day/agcd_v1-0-1_tmax_mean_r005_daily_",yy_min,".nc") #  use this for a THREDDS service (but slower)
    # this version downloads the file quicker
    if(var_i != "precip"){
    infile <- paste0("https://dapds00.nci.org.au/thredds/fileServer/zv2/agcd/v1-0-1/",var_i,"/mean/r005/01day/agcd_v1-0-1_",var_i,"_mean_r005_daily_",yy,".nc")
    } else {
    infile <- paste0("https://dapds00.nci.org.au/thredds/fileServer/zv2/agcd/v1-0-1/precip/total/r005/01day/agcd_v1-0-1_precip_total_r005_daily_",yy,".nc")
    }
    infile2 <- file.path(dir_store,basename(infile))
    
    if(!file.exists(infile2)){
      system(paste0("wget ",infile," ", basename(infile)))
      file.rename(basename(infile), infile2)
    }
    
    b2 <- raster::brick(infile2)
    sa1 <- st_transform(sa1, crs(b2))  
    # b2
    # plot(b2)

    # WARNING TERRA EXTRACT MUCH SLOWER THAN EXACTEXTRACTR
    # b_sa1 <- terra::extract(b2, sa1, mean, na.rm = T)
    # b2 <- brick(b2) # this is only needed if you use are not using local ncdf files 
    
    b_sa1 <- exactextractr::exact_extract(b2, sa1, fun = "mean", progress = FALSE)
    if(tidy_up == TRUE){
      file.remove(infile2)
    }
    out <- cbind(st_drop_geometry(sa1[,1]), b_sa1)
    setDT(out)
    
    out2 <- melt(out, id.vars = c(names(out)[1]))
    out2$measure <- var_i
    ## tidy up the dates
    out2$date <- gsub("mean.X","",out2$variable)
    out2$date <- as.Date(gsub("\\.","-",out2$date))
    out2$variable <- NULL
    
    sa1_out[[as.character(yy)]] <- out2
  }
  
  sa1_out2 <- rbindlist(sa1_out)
  sa1_out2_by_var[[var_i]] <- sa1_out2
}
  # sa1_out2_by_var
  sa1_out2_by_var2 <- rbindlist(sa1_out2_by_var)
  ## check a day
  # sa1_out2_by_var2[ SA1_MAIN16 == 60101100101 & substr(sa1_out2$date, 6, 11) == "01-09"]
  
  # str(sa1_out2_by_var2)
  outdat_wide <- dcast(sa1_out2_by_var2, SA1_MAIN16 + date ~ measure, value.var = "value")

  
  ## get sa1 codes
  sa1_df <- st_drop_geometry(sa1)
  setDT(sa1_df)
  
  outdat_wide2 <- merge(sa1_df, outdat_wide, by = "SA1_MAIN16")
  # unique(outdat_wide2$SA1_7DIG16 )
  return(outdat_wide2)
  }
  