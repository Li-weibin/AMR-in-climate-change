install.packages(c("reshape2", "dplyr", "ggplot2", "ggsci"))

library(reshape2)
library(dplyr)
library(ggplot2)
library(ggsci)

# load data ----
AMR_covariable <- read.csv("Covariant_rawdata.csv")
variable_label <- read.csv("Covariant_label.csv")

# Visualization ----
variables_plot <- 
  AMR_covariable %>%
  melt(id.vars = c("country", "year", "IncomeGroup")) %>% 
  mutate(
    variable = factor(variable, 
                      levels = unique(variable_label$variable),
                      labels = unique(variable_label$label))
  ) %>% 
  ggplot(aes(x = year, y = value)) +
  geom_vline(xintercept = 2020, linetype = "dotted") +
  geom_line(aes(colour = IncomeGroup), 
            stat = "summary", fun = "mean", key_glyph = "timeseries") +
  facet_wrap( ~ variable, scales = "free", ncol = 4, 
             labeller = label_wrap_gen(width = 30)) +
  scale_colour_d3(name="Income groups", 
                  labels=c("High-income", "Low-income",
                           "Upper-middle-income", "Lower-middle-income"), 
                  breaks=c("H", "UM", "LM", "L")) +
  labs(x = "", y = "") +
  theme_classic() +
  theme(
    legend.position = "inside",
    legend.position.inside = c(0.7, 0.03),
    legend.text = element_text(size = 18),
    legend.title = element_text(size = 20),
    legend.background = element_blank(),
    panel.spacing.x = unit(0, "cm"),
    axis.text = element_text(size = 10),
    axis.title = element_text(size = 15),
    axis.line.y = element_line(arrow = arrow(length = unit(0.15, "cm"), angle = 20)),
    strip.text = element_text(size = 13),
    text = element_text(family = "serif")
  ) +
  guides(
    color = guide_legend(
      title.position = "top",
      override.aes = list(alpha = 1), nrow = 2)
  )

# Save image ----
ggsave("Variable_trend.png", plot = variables_plot,
       width = 12, height = 20, dpi = 500)
