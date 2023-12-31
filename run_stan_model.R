library(tidyverse)
library(rstan)

dat <- read_delim('data/clean_dat.csv') 

subsample_data <- FALSE
subsample_frac <- 0.1
set.seed(99876)

count <- dat %>% select(id, subject, count) %>%
  pivot_wider(names_from=id, values_from=count) %>%
  select(!subject) %>% as.matrix()

volume <- dat %>% select(id, volume) %>% distinct() %>% select(volume) %>%
  pull(volume)

beh <- dat %>% select(subject, A, B) %>% 
  mutate_at(c("A", "B"), function(x) (x - mean(x, na.rm=TRUE))/sd(x, na.rm=TRUE)) %>%
  replace_na(list(A=0, B=0)) %>% distinct() %>%
  select(A, B)


if (subsample_data) {
  regions <- runif(length(volume)) < subsample_frac
  count <- count[,regions]
  volume <- volume[regions]
}

N <- dim(count)[1]
R <- dim(count)[2]
D <- 5
P <- 2

rstan_options(auto_write = TRUE)
options(mc.cores = parallel::detectCores())

# run some stan
nchains <- 4
stan_dat <- list(N=N, R=R, D=D, P=P, count=count, volume=volume, beh=beh)
pars <- c('mu', 'beta', 'b', 'phi', 'sigma')
iter <- 2000
thin <- 1
stan_seed <- 12345

file <- 'poisson_regression_improved_nofactor.stan'
fit <- stan(file = file, data=stan_dat, pars=pars, iter=iter,
            chains=nchains, thin=thin, seed=stan_seed)

fit_summary <- as.data.frame(summary(fit)$summary) %>% 
  rownames_to_column(var='variable')

# W <- fit_summary %>% filter(str_detect(variable, "W")) %>% select(mean) %>%
#   as.matrix()
# dim(W) <- c(D, R)
# W <- t(W)

mu <- fit_summary %>% filter(str_detect(variable, "mu")) %>% select(mean)
beta <- fit_summary %>% filter(str_detect(variable, "beta")) %>% select(mean) %>% t()
dim(beta) <- c(P, R)
beta <- t(beta)

save.image('data/model_output.rdata')
