library(tidyverse)

coords <- read.csv("data//LTERCoordinates.csv")
IDs <- read.csv("data//PlantIDs2022.csv")
survey <- read.csv("data//RawPlantSurvey2022.csv")


## Revise species names
head(IDs)
for(i in 1:nrow(IDs)) {
  if (IDs[i, "Species"] == "sp." | IDs[i, "Species"] == "spp.") {
   IDs[i,"speciesName"] <-  IDs[i,"Genus"]
  } else {
    IDs[i,"speciesName"] <- paste0(substring(IDs[i,"Genus"], 1, 1), ".", IDs[i,"Species"])
  }
}

surveyIDs <- IDs %>% 
    select(Species = Shorthand, speciesName) %>% 
    full_join(survey) %>% 
    select(-Species) %>% 
    full_join(coords)


surveyIDsWide <- surveyIDs %>% spread(speciesName, PercentCover, fill = 0)

write.csv(surveyIDsWide, "data//ProcessedPlantData2022.csv", row.names = F)



### EDA

library(vegan)

plantComp <- surveyIDsWide %>% 
    group_by(Meadow, Quadrat) %>% 
    summarize_at(vars(A.angustifolia:Trifolium), .funs = mean)

resp <- plantComp %>% ungroup() %>%  select(A.angustifolia:Trifolium)
respTrans <- decostand(resp, method = "hellinger")
row.names(respTrans) <- paste0(plantComp$Meadow, plantComp$Quadrat)

pca1 <- rda(respTrans, scale = T)

## Plot ordination
adjustedSpeciesScores <- scores(pca1, display = "species")*3

pdf("Ord2022.pdf", useDingbats = F, width = 8, height = 8)
par(mar = c(4.5, 4.5, 0.5, 0.5)) 
plot(pca1, type = "n", xlab = "PC1 (13.5%)", ylab= "PC2 (8.8%)", cex.axis = 1.3, cex.lab = 1.5)
text(pca1, display = "sites",  cex = 0.8, col = "darkblue")
text(adjustedSpeciesScores, label = row.names(adjustedSpeciesScores),  cex = 0.8, col = "#EB9100")
dev.off()