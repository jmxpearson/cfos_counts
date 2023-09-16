data {
  int<lower=0> N; // number of subjects 
  int<lower=0> R;  // number of regions
  int<lower=0> D;  // number of latent dimensions
  int<lower=0> count[N, R];
  vector<lower=0>[R] volume;
}

// The parameters accepted by the model. Our model
// accepts two parameters 'mu' and 'sigma'.
parameters {
  matrix[R, D] W;
  real<lower=0> sigma;
  vector[D] mu;
  matrix[D, N] z;
  matrix[R, N] x;
  vector<lower=0>[D] alpha;
}

transformed parameters {
  matrix<lower=0>[R, N] lambda; 
  
  lambda = exp(x);
}

// The model to be estimated. We model the output
// 'y' to be normally distributed with mean 'mu'
// and standard deviation 'sigma'.
model {
  alpha ~ gamma(1, 1);
  mu ~ normal(0, 1);
  sigma ~ inv_gamma(1, 1);
  for (k in 1:D) {
    W[k] ~ normal(0, alpha[k]);
  }
  to_vector(x) ~ normal(to_vector(W * z), sigma);
  for (s in 1:N) {
    z[,s] ~ normal(mu, 1);
    count[s] ~ poisson(lambda[,s] .* volume);
  }
}

