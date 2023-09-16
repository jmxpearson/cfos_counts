library(tidyverse)
library(readxl)
library(data.tree)

# load some data
dat <- read_excel('data/data.xlsx', range='All Samples!A2:Y1683')
dat <- dat %>% rename("volume"="volume (mm^3)")

# mildly tricky: make the tree corresponding to the region ontology;
# since the rows are in sorted order of parents -> children, we can do this 
# straightforwardly with a loop
onto <- Node$new('-2')
for (i in 1:nrow(dat)) {
  par_id <- dat[i, "parent_structure_id"]
  curr_id <- dat[i, "id"]
  FindNode(onto, par_id)$AddChild(curr_id)
}

# now, extract all the leaf nodes
leaves <- as.data.frame(onto$Get('name', filterFun = isLeaf))
names(leaves) <- c("id")
leaves$id <- as.double(leaves$id)

#...and take only those data
dat <- dat %>% inner_join(leaves)

# tidy
dat <- dat %>% pivot_longer(starts_with("Morris_"), names_to="subject", values_to="count")

# get group info
groups <- read_excel('data/data.xlsx', range='All Samples!G1:Y2') %>% 
  pivot_longer(cols=everything(), names_to="group", values_to="subject") %>%
  mutate(group = gsub("\\.{3}[[:digit:]]+", "", group))

# add group info
dat <- dat %>% left_join(groups)

# write out
dat %>% write_delim('data/clean_dat.csv', delim=',')
