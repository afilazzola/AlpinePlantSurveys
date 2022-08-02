library(tidyverse)

gps <- read.csv("data//Coordinates.csv", header = TRUE, stringsAsFactors = FALSE)
sedum <- read.csv("data//sedum.csv")

## All combinations of quadrats
allQuadrats <- expand.grid(Meadow = unique(gps$Meadow), Quadrat = 1:5,  Subquadrat = 1:4) %>%
    filter(! (Meadow == "Y" & Quadrat > 3))

allQuadratsGPS <- gps %>% rename(Quadrat = Rep) %>%
    full_join(allQuadrats) %>%
    full_join(sedum)

write.csv(allQuadratsGPS, "SedumSurvey2022.csv")