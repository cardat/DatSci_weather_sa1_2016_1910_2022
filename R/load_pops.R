#' Load population csv from 2016 ABS CENSUS data
#'
#' @param indir The directory where the input file is located (check the config.yaml)
#' @param infile The name of the input file (check infile definition in the target dat_mrg_shp_pop)
#'
#' @return
#' @export
#'
#' @examples
#' #' load_pops(indir = "/path/to/directory", infile = "my_csv_file.csv")
#' config <- yaml::read_yaml("config.yaml")

load_pops <- function(
    indir = file.path(config$rootdir,
                      config$popdir)
    ,
    infile = config$popfile
){
  csv_file <- file.path(
    config$rootdir,
    config$popdir,
    infile
  )
  sa1_pop <- data.table::fread(
    csv_file,
    colClasses = list(
      character = c("SA1_7DIGITCODE_2016",
                    "Tot_P_P")
    )
  )
  sa1_pop <- sa1_pop[, .(sa1_7dig16 = SA1_7DIGITCODE_2016, pop = Tot_P_P )]
  return(sa1_pop)
}