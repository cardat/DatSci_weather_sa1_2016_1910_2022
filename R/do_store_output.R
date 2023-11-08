do_store_output <- function(
  dat_pop_weighted
  ,
  outfile = file.path(config$dat_derived_dir, "perth_abs_gcc16_weather_1990_2022_v20231109.csv")
){
if(!dir.exists(dirname(outfile))) dir.create(dirname(outfile))
fwrite(dat_pop_weighted,outfile)
}
