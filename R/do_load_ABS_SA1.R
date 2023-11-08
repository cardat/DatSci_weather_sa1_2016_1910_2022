do_load_ABS_SA1 <- function(
  indir_sa1=file.path(config$rootdir, config$indir_sa1)
  , 
  infile_sa1=config$infile_sa1
  ,
  subset_to_region = "GCC_CODE16 == '5GPER'"
){
  sa1 <- st_read(file.path(indir_sa1, infile_sa1))
  names(sa1)
  txt <- paste0("sa1v2 <- sa1[sa1$",subset_to_region,",]")
  eval(parse(text = txt))
  #plot(st_geometry(sa1v2))
  return(sa1v2)
}