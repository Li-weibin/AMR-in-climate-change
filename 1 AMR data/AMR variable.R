install.packages(c("dplyr", "car", "ggplot2", "ggsci", "scales", "patchwork"))

library(dplyr)
library(car)
library(ggplot2)
library(ggsci)
library(scales)
library(patchwork)

# load data ----
AMR <- read.csv("AMR_rawdata.csv")

# functions ----
# Geometric mean
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
# Find the mode number
find_mode <- function(x){
  u <- unique(na.omit(x))
  tab <- tabulate(match(x, u))
  return(u[tab == max(tab)][1])
}

# Aggregate AMR ----
AMR <- 
  AMR %>% 
  mutate(
    R_not0 = case_when(
      R == 0 ~ min(R[R>0]),
      TRUE ~ R),
    .by = AMR
  ) %>% 
  mutate(
    R_geomean = mean_geo(R_not0),
    isolates_total = sum(isolates),
    source_total = find_mode(source),
    .by = c(country, year)
  ) %>% 
  select(-R_not0) %>% 
  # Logit transformation
  mutate(
    R_geomean_logit = logit(R_geomean, adjust = min(R_geomean[R_geomean>0])),
    IncomeGroup = factor(IncomeGroup, 
                         levels = c("High-income", "Upper-middle-income", 
                                    "Lower-middle-income", "Low-income")),
    year_5 = cut(year, c(1999, seq(2004, 2019, 5), 2022))
  )

# Visualization ----
# Aggregate AMR
agg_plot <-
  AMR %>% 
  select(-3:-6) %>% 
  unique() %>% 
  ggplot(aes(x = year, y = R_geomean*100)) +
  geom_boxplot(aes(group = year_5), width = 1, colour = "grey70", outliers = F) +
  geom_jitter(aes(colour = IncomeGroup, size = isolates_total, shape = source_total), 
              width = 0.3, alpha = 0.35) +
  geom_smooth(aes(colour = IncomeGroup), method = "lm", se = F, key_glyph = "abline") +
  scale_x_continuous(breaks = seq(2000, 2020, 2)) +
  scale_size_continuous(name = "Isolates",
                        range = c(1, 5),
                        transform = "log10",
                        breaks = trans_breaks("log10", function(x) 10^x),
                        labels = trans_format("log10", math_format(10^.x))) +
  scale_shape_discrete(name = "Data sources",
                       breaks = c("EARS-Net", "GLASS", "CAESAR", "Others")) +
  scale_colour_d3(name = "Income groups",
                  breaks = c("High-income", "Low-income",
                             "Upper-middle-income", "Lower-middle-income")) +
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

# Six AMR profiles
AMR_plot <- 
  ggplot(AMR, aes(x = year, y = R*100)) +
  geom_jitter(aes(colour = IncomeGroup, size = isolates, shape = source), 
              width = 0.4, alpha = 0.2) +
  geom_smooth(aes(colour = IncomeGroup), method = "lm", se = F, linewidth = 0.8) +
  scale_size_continuous(range = c(0.7, 3),
                        trans = log10_trans(),
                        breaks = trans_breaks("log10", function(x) 10^x),
                        labels = trans_format("log10", math_format(10^.x))) +
  scale_color_d3() +
  scale_y_sqrt(labels = comma) +
  scale_x_continuous(breaks = seq(2000, 2020, 5)) +
  facet_wrap(AMR ~ ., scale = "free", nrow = 2) +
  # ggtitle("(B) Antimicrobial resistance of different profiles (%)") +
  labs(x = "", y = "Antimicrobial resistance of different profiles (%)") +
  theme_classic() +
  theme(
    plot.title = element_text(size = 15),
    legend.position = "none",
    strip.text = element_text(size = 16),
    axis.title = element_text(size = 16),
    panel.background = element_blank(),
    axis.line.y = element_line(arrow = arrow(length = unit(0.25, "cm"), angle = 20)),
    text = element_text(family = "serif")
  )

# patchwork
layout <- "
AAAA
AAAA
AAAA
AAAA
AAAA
BBBB
BBBB
"
ggsave("AMR_year.png", height = 12, width = 9, dpi = 500,
       plot = agg_plot / AMR_plot + 
         plot_annotation(tag_levels = 'A') & 
         theme(plot.tag = element_text(size = 25, face = "bold")))
