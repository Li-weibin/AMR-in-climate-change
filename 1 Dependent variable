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
for(i in c("3GCREC", "3GCRKP", "CRAB", "CREC", "CRKP", "CRPA")){
  AMR[,paste0(i, "_geomean")] <- AMR[i]
  AMR[AMR[,paste0(i, "_geomean")] %in% 0, paste0(i, "_geomean")] <- min(AMR[AMR[i]>0, i], na.rm = T)
} 
for(i in colnames(AMR)[3:8]) AMR[,paste0(i, "_logit")] <- car::logit(AMR[i], adjust = min(AMR[AMR[i]>0, i], na.rm = T))
AMR$R_geomean <- sapply(1:nrow(AMR), function(i) mean_geo(as.numeric(AMR[i, paste0(c("3GCREC", "3GCRKP", "CRAB", "CREC", "CRKP", "CRPA"), "_geomean")])))

# Logit transformation ----
AMR$R_geomean_logit <- car::logit(AMR$R_geomean, adjust = min(AMR[AMR$R_geomean>0, "R_geomean"]))
