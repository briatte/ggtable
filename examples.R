# test file
require(ggplot2)
# install_github("questionr", "briatte")
require(questionr)
# source("/Users/fr/Documents/Code/R/questionr/R/recode.r")
data(hdv2003)
require(plyr)
# source('~/Documents/Code/R/ggtable/ggtable.R')

## one-way
freq(x <- recode.na(hdv2003$relig, "NSP ou NVPR|Rejet"))

ggtable(x)
ggsave("example1.png", width = 11.69, height = 8.27)
ggtable(x, order = FALSE)
ggsave("example2.png", width = 11.69, height = 8.27)
ggtable(x, percent = TRUE, label = TRUE, append = " %")
ggsave("example3.png", width = 11.69, height = 8.27)

## two-way
freq(y <- hdv2003$sexe)

ggtable(x, y)
ggsave("example4.png", width = 11.69, height = 8.27)
ggtable(x, y, percent = TRUE)
ggsave("example5.png", width = 11.69, height = 8.27)
ggtable(y, x, order = c("Homme", "Femme"))
ggsave("example6.png", width = 11.69, height = 8.27)

ggtable(y, x, order = c("Homme", "Femme"), horizontal = FALSE, percent = TRUE, position = "dodge", legend.position = "bottom")
ggsave("example7.png", width = 11.69, height = 8.27)

ggtable(hdv2003$nivetud, x, percent = TRUE, palette = "RdGy") + 
  theme_bw(12) +
  theme(legend.position = "top", axis.ticks = element_blank())
ggsave("example8.png", width = 11.69, height = 8.27)
