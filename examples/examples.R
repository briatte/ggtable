# test file
source("../ggtable.R")

data(happy, package = "GGally")
happy = subset(happy, year == 2006)

# required packages
library(ggplot2)

# one-way tables

ggtable(happy$marital, weights = happy$wtssall)
ggsave("example1.png", width = 11.69, height = 8.27)

ggtable(happy$marital, weights = happy$wtssall, percent = TRUE, order = TRUE)
ggsave("example2.png", width = 11.69, height = 8.27)

ggtable(happy$marital, weights = happy$wtssall, percent = TRUE, label = TRUE, append = "%")
ggsave("example3.png", width = 11.69, height = 8.27)

# two-way tables

ggtable(happy$marital, happy$sex, weights = happy$wtssall)
ggsave("example4.png", width = 11.69, height = 8.27)

ggtable(happy$sex, happy$marital, weights = happy$wtssall)
ggsave("example5.png", width = 11.69, height = 8.27)

ggtable(happy$sex, happy$marital, weights = happy$wtssall, percent = TRUE)
ggsave("example6.png", width = 11.69, height = 8.27)

# using options

ggtable(happy$degree, happy$health, weights = happy$wtssall, percent = TRUE,
          label = TRUE, name = "", palette = "PRGn") +
    labs(y = NULL, x = NULL, title = "Health status, by education level") +
    theme_bw(16) +
    theme(legend.position = "top", axis.ticks = element_blank())
ggsave("example7.png", width = 11.69, height = 8.27)
