library(targets)
library(tarchetypes)

tar_source()


tar_option_set(
  packages = c(
    "ncdf4",
    "data.table",
    "terra",
    "sf",
    "raster"),
  error = "continue"
  # for parallel, specify which targets are to be run on workers with 
  # deployment = "worker" in appropriate tar_target, otherwise run on main
  # , deployment = "main"
)

# Load config.yaml
config <- yaml::read_yaml("config.yaml")

list(
# #### check_variables ####
# tar_target(
#   check_variables,
#   do_variables(
#     infile=config$infile
#     )
# )
# ,
####  load_ABS_SA1 ####
tar_target(
  load_ABS_SA1,
  do_load_ABS_SA1(
    indir_sa1=file.path(config$rootdir, config$indir_sa1)
    , 
    infile_sa1=config$infile_sa1
    ,
    subset_to_region = config$subset_to_region
    )
)
,
####  load_and_extract ####
tar_target(
  load_and_extract,
  do_load_and_extract(
    infile = config$infile
    ,
    sa1 = load_ABS_SA1
    , 
    var_i = config$var_i
    ,
    yy_min = config$yy_min
    , 
    yy_max = config$yy_max
    , 
    variables = config$var_i
    ,
    use_cloud_cardat = T
    ,
    tidy_up = T
    )
)
,
#### dat_sa1_pop ####
tar_target(
  dat_sa1_pop,
  load_pops(
    indir = file.path(config$rootdir,
                      config$popdir),
    infile = config$popfile
  )
)
,
#### pop_w_means ####
tar_target(
  dat_pop_weighted,
  do_pop_w_means(
    infile_pop = dat_sa1_pop
    ,
    infile_exposure = load_and_extract
    ,
    by_spatial_unit = config$by_spatial_unit
  )
)
,
####  show_a_time_series_plot ####
tar_target(
  show_a_time_series_plot,
  do_show_a_time_series_plot(dat_pop_weighted)
)
#,
# #### qc_perth ####
# tar_target(
#   qc_perth,
#   do_qc_against_obs(
#     infile = "data_provided/BoM_oberservations/data_provided/IDCJAC0010_009225_1800/IDCJAC0010_009225_1800_Data.csv"
#   )
# )
#,
# ####  show_the_whole_map ####
# tar_target(
#   show_the_whole_map,
#   do_show_the_whole_map(
#     load_and_extract
#     ,
#     sa1 = load_ABS_SA1
#     )
# )
 ,
 ####  store_output ####
 tar_target(
   store_output,
   do_store_output(
     dat_pop_weighted
     ,
     outfile = file.path(config$dat_derived_dir, "perth_abs_gcc16_weather_1990_2022_v20231109.csv")
    )
 )
)
