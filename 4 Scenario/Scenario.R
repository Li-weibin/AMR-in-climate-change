install.packages(c("dplyr", "ggplot2", "ggrepel", "ggsci", "pacthwork"))

library(dplyr)
library(ggplot2)
library(ggrepel)
library(ggsci)
library(patchwork)

# load data ----
PredictValue <- readRDS("scenarios.rds")
PredictValue_SDG <- readRDS("scenarios_SDGs.rds")

# Aggregate AMR in different SSPs and socioeconomic scenarios ----
R_change <-
  ggplot(data = PredictValue, aes(x = year)) +
  geom_ribbon(aes(ymin = low*100, ymax = high*100, fill = ssp), alpha = 0.1) +
  geom_line(aes(y = mean_7*100, colour = ssp), stat = "summary", fun = "mean", key_glyph = "timeseries") +
  geom_text(aes(x = 2020.1, y = mean*100, label = sprintf("%.01f", after_stat(y))), 
            data = PredictValue[PredictValue$year == 2020,],
            stat = "summary", fun = "mean", hjust = 0, vjust = -1,
            colour = "grey20", family = "serif") +
  geom_text_repel(aes(x = 2048, y = mean_7*100, label = sprintf("%.01f", after_stat(y)), colour = ssp), 
                  data = PredictValue[PredictValue$year == 2047,],
                  stat = "summary", fun = "mean", key_glyph = "timeseries", 
                  force = 5, min.segment.length = 100,
                  direction = "y", hjust = 0, family = "serif") +
  facet_grid(IncomeGroup ~ scenario, scale = "free_y",
             labeller = label_wrap_gen(width = 28)) +
  labs(x = "", y = "Average prevalence of antimicrobial resistance (%)") +
  scale_colour_brewer(name="Shared socioeconomic pathways",
                      labels=c("SSP1-2.6", "SSP2-4.5", "SSP3-7.0", "SSP5-8.5"),
                      breaks=c("ssp126", "ssp245", "ssp370", "ssp585"),
                      palette = "Set1") +
  scale_fill_brewer(name="Shared socioeconomic pathways",
                    labels=c("SSP1-2.6", "SSP2-4.5", "SSP3-7.0", "SSP5-8.5"),
                    breaks=c("ssp126", "ssp245", "ssp370", "ssp585"),
                    palette = "Set1") +
  scale_x_continuous(breaks = seq(2020, 2050, 10)) +
  scale_y_continuous(expand = c(0, 0)) +
  theme_classic() +
  theme(
    plot.title = element_text(size = 18),
    legend.position = c(0.5, -0.08),
    legend.text = element_text(size = 13),
    legend.title = element_text(size = 15),
    legend.direction = "horizontal",
    legend.background = element_blank(),
    strip.text.x = element_text(size = 13),
    strip.text.y.right = element_text(size = 10),
    plot.margin = margin(t = 5, r = 5, b = 20, l = 5),
    axis.text = element_text(size = 9),
    axis.ticks.x = element_blank(),
    axis.title = element_text(size = 15),
    axis.line.y = element_line(arrow = arrow(length = unit(0.15, "cm"), angle = 20)),
    text = element_text(family = "serif")
  ) +
  coord_cartesian(xlim = c(2020, 2052))


# Aggregate AMR in different SDGs ----
# difference value (2050 - 2020)
data_diff <- 
  PredictValue_SDG %>% 
  summarise(
    IncomeGroup = unique(IncomeGroup[year %in% 2050]), 
    diff = mean[year %in% 2050] - mean[year %in% 2020],
    .by = c(ssp, AMC, SDGs, ABENAME)) %>% 
  mutate(
    IncomeGroup = factor(IncomeGroup, levels = c("H", "UM", "LM", "L")),
    SDGs = factor(SDGs, levels = c("baseline", "CHERate", "WASHIndex", 
                                   "ImmIndex", "OutPocketRate")))

# Visualization
R_singleSDG <-
  ggplot(data_diff, aes(x = IncomeGroup, y = diff*100, fill = SDGs)) +
  geom_bar(stat = "summary", fun = "mean", colour = "black", 
           position = position_dodge(width = 0.9)) +
  geom_hline(yintercept = 0, linetype = "dashed") +
  scale_fill_npg(name = "Specific interventions for\nsustainable development",
                 labels = c("Baseline", "Health expenditure\nover 5% of GDP", 
                            "100% WASH\naccessibility",
                            "100% immunisation\ncoverage",
                            "Out-of-pocket costs less than\n20% of health expenditure")) +
  scale_x_discrete(labels = c("High", "Upper-middle", "Lower-middle", "Low")) +
  facet_wrap(~factor(AMC, levels = c("AMC_baseline", "AMC_gov"),
                     labels = c("Baseline", "50% reduction in antimicrobials")), 
             nrow = 1) +
  labs(x = "Income group", y = "Difference between 2020 and 2050 (%)") +
  theme_classic() +
  theme(
    legend.position = "inside",
    legend.position.inside = c(0.48, -0.35),
    legend.text = element_text(size = 13),
    legend.title.position = "left",
    legend.title = element_text(size = 15,),
    legend.direction = "horizontal",
    legend.background = element_blank(),
    strip.text = element_text(size = 15),
    axis.text = element_text(size = 10),
    axis.title = element_text(size = 15),
    text = element_text(family = "serif")
  ) +
  guides(
    fill = guide_legend(nrow = 2)
  )

# patchwork ----
layout <- "
AAAA
AAAA
AAAA
AAAA
BBBB
BBBB
"
ggsave("Scenario.png", height = 12, width = 9, dpi = 500,
       plot = R_change / R_singleSDG +
         plot_layout(design = layout) +
         plot_annotation(tag_levels = 'A') & 
         theme(plot.tag = element_text(size = 25, face = "bold"),
               plot.margin = margin(t = 5, r = 5, b = 35, l = 5)))
