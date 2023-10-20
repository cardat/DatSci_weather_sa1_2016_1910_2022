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
library(raster)
library(ncdf4)
library(exactextractr)
library(sf)
library(data.table)

#### input ####
infile <- "https://dapds00.nci.org.au/thredds/dodsC/zv2/agcd/v1-0-1/tmax/mean/r005/01day/agcd_v1-0-1_tmax_mean_r005_daily_2022.nc"
#infile <- "https://dap.tern.org.au/thredds/dodsC/Historical_Extreme_Weather_Events_Australia/AWAP_Year/uncompressed/Un_AWAP_2020.nc"

#### variables ####
r_nc <- ncdf4::nc_open(infile)
r_nc
varlist <- names(r_nc[['var']])
# exclude lon, lat, time and crs
varlist <- varlist[5:length(varlist)]
varlist
## there is only one variable in this climate grids repository 
#var_i <- "Temp_max"
#var_i <- "tmax"

#### load ABS SA1 for TAS ####
indir_sa1 <- "data_provided/ABS_Census_2016/abs_sa1_2016_data_provided"
## dir(indir_sa1)
infile_sa1 <- "SA1_2016_TAS.shp"
sa1 <- st_read(file.path(indir_sa1, infile_sa1))

#### load and extract for study period ####

study_period <- list(mindate="2020-01-01", maxdate ="2020-01-31")

## raster data for each var
print(var_i)
b <- raster::brick(infile)#, varname = var_i)
##b
b2 <- b[[which(getZ(b) >= as.Date(study_period[["mindate"]]) & getZ(b) <= as.Date(study_period[["maxdate"]]))]]
b_sa1 <- exact_extract(brick(b2), sa1, progress = FALSE) 
## ignoring warning about CRS for now
b_sa1 <- rbindlist(b_sa1, idcol = "rowid")
##b_sa1
## make long format from wide
b_sa1_long <- melt(b_sa1, id.var = c("rowid", "coverage_fraction"))
## check a day
## b_sa1_long[variable == "X2020.01.19"]
b_sa1_out <- b_sa1_long[,
                        .(value = sum(value * coverage_fraction, na.rm = T) / sum(coverage_fraction, na.rm = T)),
                        by = .(rowid, variable)
]
## checks for one day
# b_sa1_out2 <- b_sa1_out[variable == "X2020.01.19"]
# sa1_map <- cbind(sa1, b_sa1_out2)
# plot(sa1_map["value"])
names(b_sa1_out) <- c("rowid", "date", "value")
b_sa1_out$variable <- var_i
outdat <- b_sa1_out


## tidy up the dates
outdat$date <- gsub("X","",outdat$date)
outdat$date <- as.Date(gsub("\\.","-",outdat$date))

outdat_wide <- dcast(outdat, rowid + date ~ variable, value.var = "value")

## get sa1 codes
sa1_df <- st_drop_geometry(sa1)
sa1_df$rowid <- 1:nrow(sa1_df)
setDT(sa1_df)

outdat_wide2 <- merge(sa1_df[,.(rowid, SA1_7DIG16, SA4_NAME16, GCC_NAME16)], outdat_wide, by = "rowid")
unique(outdat_wide2$SA4_NAME16)

#### show a time series plot for a single SA1 in launceston ####

sa1_todo <- 6103815
sa1_toplot <- outdat_wide2[SA1_7DIG16 == sa1_todo]

# show the timeseries
dir.create("figures_and_tables")
png("figures_and_tables/do_extract_abs_sa1_launceston.png", width = 1000, height = 700)
with(sa1_toplot, plot(date, tmax, type = "b", ylim = c(0,40)))
title(paste0("time series tmax for sa1", sa1_todo))
dev.off()

#### show a map of the 22nd ####

sa1_tomap <- outdat_wide2[date == as.Date("2020-01-22")]
sa1_map <- cbind(sa1, sa1_tomap)

png("figures_and_tables/do_map_abs_sa1_tmax_tas_20200122.png", width = 700, height = 700)
plot(sa1_map["tmax"])
legend("bottomright", legend = "22 Jan 2016")
dev.off()


#### show the whole map ####

var_i = "tmax"
b <- raster::brick(infile, varname = var_i)
b2 <- b[[which(getZ(b) >= as.Date("2020-01-22") & getZ(b) < as.Date("2020-01-23"))]]
png("figures_and_tables/do_map_abs_sa1_tmax_pred_national_20200122.png", width = 700, height = 700)
plot(b2)
dev.off()

## close connection to climate grids
nc_close(r_nc)

## store grid and shapefile for GIS display
dir.create("data_derived")
writeRaster(b2, "data_derived/tmax_20200122.tif")
st_write(sa1_map, "data_derived/tmax_20200122_abs_sa1_tas.gpkg", driver = "gpkg")
## open these in QGIS and produce a map with a scale bar and legend

