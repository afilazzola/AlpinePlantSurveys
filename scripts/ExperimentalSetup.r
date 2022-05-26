library(sf)
library(raster)

sf::sf_use_s2(FALSE)
## load data
meadows <- st_read(dsn="data//meadows", layer="meadowOutline")

## select target meadows
subsetMeadow <- meadows[meadows$meadow %in% c("Z", "G", "F", "K", "L", "O", "P"),]

pointsOut <- lapply(subsetMeadow$meadow, function(i) {
tempPoints <- st_sample(subsetMeadow[subsetMeadow$meadow == i,], size = 10)
tempPoints
})

allSurveyPoints <- do.call(c, pointsOut)

st_write(allSurveyPoints, "allSurveyPoints.shp") # write to file
