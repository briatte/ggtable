# test file
source("ggtable.R")

# install.packages("questionr")
library(questionr)
data(hdv2003)

# required packages
library(ggplot2)
library(plyr)

## one-way
freq(x <- recode.na(hdv2003$relig, "NSP ou NVPR|Rejet"))

ggtable(x)
ggsave("examples/example1.png", width = 11.69, height = 8.27)

ggtable(x, order = FALSE)
ggsave("examples/example2.png", width = 11.69, height = 8.27)

ggtable(x, percent = TRUE, label = TRUE, append = " %")
ggsave("examples/example3.png", width = 11.69, height = 8.27)

## two-way
freq(y <- hdv2003$sexe)

ggtable(x, y)
ggsave("examples/example4.png", width = 11.69, height = 8.27)

ggtable(x, y, percent = TRUE)
ggsave("examples/example5.png", width = 11.69, height = 8.27)

ggtable(y, x, order = c("Homme", "Femme"))
ggsave("examples/example6.png", width = 11.69, height = 8.27)

ggtable(y, x, order = c("Homme", "Femme"), horizontal = FALSE, percent = TRUE, position = "dodge", legend.position = "bottom")
ggsave("examples/example7.png", width = 11.69, height = 8.27)

ggtable(hdv2003$nivetud, x, percent = TRUE, palette = "RdGy") + 
  theme_bw(12) +
  theme(legend.position = "top", axis.ticks = element_blank())
ggsave("examples/example8.png", width = 11.69, height = 8.27)
