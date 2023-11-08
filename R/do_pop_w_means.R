#' Title do_pop_w_means
#'
#' @param indat 
#' @param by_spatial_unit 
#'
#' @return
#' @examples
# tar_load(dat_sa1_pop)
# tar_load(load_and_extract)
# by_spatial_unit = "gcc_code16"
do_pop_w_means <- function(
    infile_pop = dat_sa1_pop
    ,
    infile_exposure = load_and_extract
    ,
    by_spatial_unit = "gcc_code16"
){
  #infile_pop
  names(infile_exposure) <- tolower(names(infile_exposure))
  indat <- merge(infile_exposure, infile_pop, by = "sa1_7dig16")
  #names(indat)
  setDF(indat)
  indat2 <- indat[,c(by_spatial_unit, "sa1_7dig16", "pop", "date", "precip", 
                     "tmax", "tmin", "vapourpres_h09", "vapourpres_h15")]
  setDT(indat2)
  indat_long <- melt(indat2, 
                     id.var = c(by_spatial_unit, "sa1_7dig16", "pop", "date"))
  # str(indat_long)
  indat_long$pop <- as.numeric(indat_long$pop)
  indat_long_out <- indat_long[,
                           .(pwav = sum(pop * value, na.rm = T) / sum(pop, na.rm = T)),
                           by = c(by_spatial_unit,"variable", "date")
  ]
  indat_long_out2 <- dcast(indat_long_out, gcc_code16 + date ~ variable, value.var = "pwav")
  return(indat_long_out2)
}
