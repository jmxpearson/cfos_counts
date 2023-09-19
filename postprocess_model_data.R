library(tidyverse)
library(ggplot2)

load('data/model_output.rdata')

regions <- dat %>% select(name) %>% distinct()
beta_df <- fit_summary %>% filter(str_detect(variable, "beta")) %>%
  mutate(region=rep(regions$name, each=2)) %>%
  mutate(behavior=factor(str_sub(variable, -2, -2), labels=c("NDLPr", "Lever press"))) %>%
  mutate(signif=(0 < `2.5%`) | (0 > `97.5%`)) %>%
  filter(signif) #%>%
  #fct_reorder(variable, mean)
  #arrange(desc(mean), decreasing=TRUE)
  

p <- ggplot(beta_df, aes(fct_reorder(region, mean), mean))
p + geom_pointrange(aes(ymin=`2.5%`, ymax=`97.5%`)) + 
  coord_flip() + 
  facet_grid(cols = vars(behavior)) +
  labs(x = "Region", y="Regression coefficient")
ggsave('plots/reg_coeffs.pdf', width=11, height=28, units="in")
