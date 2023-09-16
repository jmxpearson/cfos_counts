library(tidyverse)
library(rstan)

dat <- read_delim('data/clean_dat.csv')

count <- dat %>% select(id, subject, count) %>%
  pivot_wider(names_from=id, values_from=count) %>%
  select(!subject) %>% as.matrix()

volume <- dat %>% select(id, volume) %>% distinct() %>% select(volume) %>%
  pull(volume)

N <- length(unique(dat$subject))
R <- length(unique(dat$id))
D <- 5

rstan_options(auto_write = TRUE)
options(mc.cores = parallel::detectCores())

# run some stan
nchains <- 2
stan_dat <- list(N=N, R=R, D=D, count=count, volume=volume)
pars <- c('mu', 'lambda', 'W', 'alpha', 'sigma')
iter <- 2000
thin <- 1
stan_seed <- 12345

# fit <- stan(file = 'poisson_prob_pca.stan', data=stan_dat, pars=pars, iter=iter, 
#             chains=nchains, thin=thin, seed=stan_seed)

model <- stan_model(file = 'poisson_prob_pca.stan')
fit <- optimizing(model, data=stan_dat, seed=stan_seed)

pars <- as.data.frame(fit$par) %>% rownames_to_column()
names(pars) <- c("var", "val")
mu <- pars %>% filter(str_detect(var, "mu"))

W <- pars %>% filter(str_detect(var, "W"))
W <- as.matrix(W$val) 
dim(W) <- c(R, D)
