do_variables <- function(
    infile=config$infile
){
  #### variables ####
  r_nc <- ncdf4::nc_open(infile)
  r_nc
  varlist <- names(r_nc[['var']])
  varlist
  # exclude lon, lat, time and crs
  varlist <- varlist[5:length(varlist)]
  ## there is only one variable in this climate grids repository 
  return(varlist)
}
