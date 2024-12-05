# Geometric mean ----
mean_geo <- function(vector, na.rm = T, adjust = T){
  if(sum(!is.na(vector)) == 0){
    return(NA)
  }else if(max(vector, na.rm = T) == 0){
    return(0)
  }else if(adjust){
    vector[which(vector == 0)] <- min(vector[vector != 0], na.rm = T)
  }
  return(ifelse(sum(!is.na(vector)) == 0, NA, prod(vector, na.rm = na.rm)^(1/sum(!is.na(vector)))))
} 

# Aggregate AMR ----
AMR <- read.csv("AMR_rawdata.csv")
for(i in c("3GCREC", "3GCRKP", "CRAB", "CREC", "CRKP", "CRPA")){
  AMR[,paste0(i, "_geomean")] <- AMR[i]
  AMR[AMR[,paste0(i, "_geomean")] %in% 0, paste0(i, "_geomean")] <- min(AMR[AMR[i]>0, i], na.rm = T)
} 
AMR$R_geomean <- sapply(1:nrow(AMR), function(i) mean_geo(as.numeric(AMR[i, paste0(c("3GCREC", "3GCRKP", "CRAB", "CREC", "CRKP", "CRPA"), "_geomean")])))

# Logit transformation ----
AMR$R_geomean_logit <- car::logit(AMR$R_geomean, adjust = min(AMR[AMR$R_geomean>0, "R_geomean"]))

# Visualization ----
library(ggplot2)
library(ggsci)
library(scales)
ggplot(AMR, aes(x = year, y = R_geomean*100)) +
  geom_boxplot(aes(group = year_5), width = 1, colour = "grey70", outliers = F) +
  geom_jitter(aes(colour = IncomeGroup, size = isolates, shape = source), width = 0.3, alpha = 0.35) +
  geom_smooth(aes(colour = IncomeGroup), method = "lm", se = F, key_glyph = "abline") +
  scale_x_continuous(breaks = seq(2000, 2020, 2)) +
  scale_size_continuous(name = "Isolates",
                        range = c(1, 5),
                        transform = "log10",
                        breaks = trans_breaks("log10", function(x) 10^x),
                        labels = trans_format("log10", math_format(10^.x))) +
  scale_shape_discrete(name="Data sources", 
                       breaks=c("EARS-Net", "GLASS", "CAESAR", "Others")) +
  scale_colour_d3(name="Income groups", 
                  labels=c("High-income", "Low-income",
                           "Upper-middle-income", "Lower-middle-income"), 
                  breaks=c("H", "UM", "LM", "L")) +
  scale_y_sqrt(labels = scales::comma) +
  labs(x = "", y = "Averge prevalence of antimicrobial resistance (%)") +
  theme_classic() +
  theme(
    plot.title = element_text(size = 15),
    legend.position = "inside",
    legend.position.inside = c(0.25, 0.73),
    legend.text = element_text(size = 13),
    legend.title = element_text(size = 15),
    legend.background = element_blank(),
    strip.background = element_rect(fill = "grey90"),
    panel.background = element_blank(),
    axis.title = element_text(size = 16),
    axis.text = element_text(size = 10),
    axis.text.x = element_text(size = 10, angle = 0),
    axis.line.y = element_line(arrow = arrow(length = unit(0.25, "cm"), angle = 20)),
    text = element_text(family = "serif")
  ) + 
  guides(
    color = guide_legend(override.aes = list(alpha = 1, shape = NA), order = 2, nrow = 2),
    shape = guide_legend(override.aes = list(alpha = 1, colour = "Black", size = 4), order = 3, nrow = 2),
    size = guide_legend(override.aes = list(alpha = 1, colour = "Black"), order = 1, 
                        title.position = "top", direction = "horizontal")
  )
