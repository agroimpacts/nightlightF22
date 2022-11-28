from osgeo import gdal
import os

##imgdir = 'D:/Boston/'
##imgfiles = [f'{imgdir}{img}' for img in os.listdir(imgdir) if ".h5" in img]

outfolder = "D:/Boston/geotiffs/"
imgfile = "D:/Boston/VNP46A3.A2012001.h10v04.001.2021124111521.h5"


#Get File Name Prefix
imagepre = os.path.basename(imgfile)[:-3]
#print(imagepre)

file_ext = "_BBOX.tif"

## Open HDF file
hdflayer = gdal.Open(imgfile, gdal.GA_ReadOnly)

#print (hdflayer.GetSubDatasets())

# Open raster layer
#hdflayer.GetSubDatasets()[0][0] - for first layer
#hdflayer.GetSubDatasets()[1][0] - for second layer ...etc
subhdflayer = hdflayer.GetSubDatasets()[0][0]
rlayer = gdal.Open(subhdflayer, gdal.GA_ReadOnly)
#outputName = rlayer.GetMetadata_Dict()['long_name']

#Subset the Long Name
outname = os.path.basename(subhdflayer[92:])
outname = imagepre + file_ext
# print(outname)

outfile = os.path.join(outfolder, outname)

#collect bounding box coordinates
horiz_tile = int(rlayer.GetMetadata_Dict()["HorizontalTileNumber"])
vert_tile = int(rlayer.GetMetadata_Dict()["VerticalTileNumber"])

westbound = (10*horiz_tile) - 180
northbound = 90-(10*vert_tile)
eastbound = westbound + 10
southbound = northbound - 10

EPSG = "-a_srs EPSG:4326" #WGS84

transl_opt_text = (
    EPSG+" -a_ullr " + str(westbound) + " " + \
    str(northbound) + " " + str(eastbound) + " " + str(southbound)
)

transl_opts = gdal.TranslateOptions(gdal.ParseCommandLine(transl_opt_text))
gdal.Translate(outfile, rlayer, options=transl_opts)


for file in imgfiles:
    print(file)
    translate_hdf5(file, imgdir)