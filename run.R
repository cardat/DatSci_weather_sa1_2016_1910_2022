library(targets)
tar_source()
load_packages(pkg = c("ncdf4","data.table","terra", "sf", "yaml", "raster", "exactextractr", "tarchetypes"), do_it = T, force_install = F)
tar_visnetwork(targets_only = T)
# for very dense pipelines use this layout
# library(visNetwork)
# visIgraphLayout(tar_visnetwork(targets_only = T), layout = 'layout.kamada.kawai', physics = T)
# Load config.yaml
config <- yaml::read_yaml("config.yaml")
# tar_make()
# 
# # useful
# tar_invalidate()
# tar_objects()
# tar_load_everything()