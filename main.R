#' @title do extract abs sa1 tmax
#' @author ivanhanigan
#' @description This is code for the PUBH3007
#' Module 05 computer lab on GIS and big data climate grids
#' @return a raster surface in R and saved to a geotiff file and sa1 extracted values
#' @param infile path to climate grids
#' @param indir_sa1 file path to the input ABS data
#' @param var_i variable name of climate data
#' @param sa1_todo choose one ABS SA1 location to inspect visually
#' @param study_period choose the dates to use for subset

#### functions ####
#library(raster)
library(terra)
library(ncdf4)
library(sf)
library(data.table)

#### input ####
infile <- "https://dapds00.nci.org.au/thredds/dodsC/zv2/agcd/v1-0-1/tmax/mean/r005/01day/agcd_v1-0-1_tmax_mean_r005_daily_2022.nc"

#### variables ####
r_nc <- ncdf4::nc_open(infile)
r_nc
varlist <- names(r_nc[['var']])
varlist
# exclude lon, lat, time and crs
varlist <- varlist[5:length(varlist)]
varlist
## there is only one variable in this climate grids repository 
var_i <- "tmax"


#### load_ABS_SA1 ####
indir_sa1 <- "data_provided/ABS_Census_2016/abs_sa1_2016_data_provided"
## dir(indir_sa1)
infile_sa1 <- "SA1_2016_TAS.shp"
sa1 <- st_read(file.path(indir_sa1, infile_sa1))

#### load_and_extract for study period ####
sa1_out <- list()
for(yy in 2001:2020){
  ## yy = 2001
  study_period <- list(mindate=paste0(yy,"-01-01"), maxdate =paste0(yy,"-01-10"))
  
## raster data for each var
# print(var_i)
  b <- raster::brick(gsub("agcd_v1-0-1_tmax_mean_r005_daily_2020.nc", 
                          paste0("agcd_v1-0-1_tmax_mean_r005_daily_",yy,".nc"), infile), 
                     varname = var_i)
  # b
  # plot(b)
  b2 <- b[[which(getZ(b) >= as.Date(study_period[["mindate"]]) & getZ(b) <= as.Date(study_period[["maxdate"]]))]]
  
  b2 <-rast(brick(b2))
  b_sa1 <- terra::extract(b2, sa1, mean)
  out <- cbind(st_drop_geometry(sa1[,1]), b_sa1)
  setDT(out)
  
  out2 <- melt(out, id.vars = c(names(out)[1], "ID"))
  out2$measure <- var_i
  sa1_out[[yy]] <- out2
}

sa1_out2 <- rbindlist(sa1_out)
sa1_out2
## check a day
sa1_out2[substr(sa1_out2$variable, 6, 11) == ".01.09"
         & SA1_MAIN16 == 60101100101 ]


outdat <- sa1_out2
str(outdat)

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
unique(outdat_wide2$SA1_7DIG16 )

#### show_a_time_series_plot for a single SA1 in launceston ####

sa1_todo <- 6103815
sa1_toplot <- outdat_wide2[SA1_7DIG16 == sa1_todo]

# show the timeseries
dir.create("figures_and_tables")
png("figures_and_tables/do_extract_abs_sa1_launceston.png", width = 1000, height = 700)
with(sa1_toplot, plot(date, tmax, type = "b", ylim = c(0,40)))
title(paste0("time series tmax for sa1", sa1_todo))
dev.off()

#### show a map of the 2nd ####

sa1_tomap <- outdat_wide2[date == as.Date("2001-01-02")]
sa1_map <- cbind(sa1, sa1_tomap)

png("figures_and_tables/do_map_abs_sa1_tmax_tas_20010102.png", width = 700, height = 700)
plot(sa1_map["tmax"])
legend("bottomright", legend = "2 Jan 2001")
dev.off()


#### show_the_whole_map ####

var_i = "tmax"
b <- raster::brick(gsub("agcd_v1-0-1_tmax_mean_r005_daily_2020.nc", 
                        paste0("agcd_v1-0-1_tmax_mean_r005_daily_",yy,".nc"), infile), 
                   varname = var_i)
b2 <- b[[which(getZ(b) >= as.Date("2001-01-02") & getZ(b) < as.Date("2001-01-03"))]]
png("figures_and_tables/do_map_abs_sa1_tmax_pred_national_20010102.png", width = 700, height = 700)
plot(b2)
dev.off()

## close connection to climate grids
nc_close(r_nc)

## store_output grid and shapefile for GIS display
dir.create("data_derived")
writeRaster(b2, "data_derived/tmax_20010102.tif")
st_write(sa1_map, "data_derived/tmax_20010102_abs_sa1_tas.gpkg", driver = "gpkg")
## open these in QGIS and produce a map with a scale bar and legend

