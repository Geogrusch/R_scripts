#### SAGA in R (TWI calculation example)
#### two packages available: RSAGA and Rsagacmd
#### RSAGA is not maintained anymore (after 6.3.0)
#### Rsagacmd resilient against SAGA version changes
####https://cran.microsoft.com/snapshot/2020-07-19/web/packages/Rsagacmd/Rsagacmd.pdf
#### install  Rsagacmd package
library(Rsagacmd)


####  set directory to data folder
setwd("D:\\EAGLE\\Geoanalysis\\SAGA\\DGM_30m_Mt.St.Helens_SRTM")

#### path to Saga cmd and tools 
path <- "D:\\EAGLE\\Geoanalysis\\SAGA\\saga-8.1.1_x64\\saga-8.1.1_x64"

#### check out the Rsagacmd tools and set directories

ls("package:Rsagacmd")

saga <- saga_gis()

#### preprocessing the DEM
print(saga$ta_preprocessor$fill_sinks_wang_liu)

saga$ta_preprocessor$fill_sinks_wang_liu(elev = "DGM_30m_Mt.St.Helens_SRTM.sgrd", 
                                         filled = "MtStHelens_filled.sgrd")

#### calculation of inputs for TWI (Slope and total catchment area)
print(saga$ta_morphometry$slope_aspect_curvature)

saga$ta_morphometry$slope_aspect_curvature(elevation = "MtStHelens_filled.sgrd", 
                                           slope = "MtStHelens_slope.sgrd", 
                                           method= 7)

print(saga$ta_hydrology$flow_accumulation_recursive)

saga$ta_hydrology$flow_accumulation_recursive(elevation = "MtStHelens_filled.sgrd", 
                                              flow = "flowaccumulation.sgrd", 
                                              method = "Multiple Flow Direction")

#### TWI calculation
print(saga$ta_hydrology$topographic_wetness_index_twi)

TWI <- saga$ta_hydrology$topographic_wetness_index_twi(slope = "slope_new.sgrd",
                                                area= "flowaccumulation.sgrd",
                                                twi= "TWI_Helens.sgrd",
                                                conv = 1,
                                                method = 1)


#### additionally utilizing RSAGA package for raster transformation (via RGDAL)
#### setting up the environment for SAGA 

library(raster)
library(RSAGA)

#### setup SAGA environment

env <-rsaga.env(path=path, modules=path)

#### raster conversion to ascii because saga native .sgrd extension can't be visualized in R
#### conversion may take a while 
#### output is by default named like the input

rsaga.sgrd.to.esri(in.sgrds = "TWI_Helens.sgrd", env=env)

TWI <- raster("TWI_Helens.asc")
plot(TWI)

