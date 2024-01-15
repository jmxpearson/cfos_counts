data {
  int<lower=0> N; // number of subjects 
  int<lower=0> R;  // number of regions
  int<lower=0> D;  // number of latent dimensions
  int<lower=0> P;  // number of regressors
  int<lower=0> count[N, R];
  vector<lower=0>[R] volume;
  matrix[N, P] beh;
}

// The parameters accepted by the model. Our model
// accepts two parameters 'mu' and 'sigma'.
parameters {
  real<lower=0> sigma;
  vector[R] mu;
  matrix[R, N] x;
  matrix[R, P] beta;
  vector<lower=0>[N] b;
  vector[N] phi;
}

transformed parameters {
  matrix<lower=0>[R, N] lambda; 
  
  lambda = exp(x);
}

// The model to be estimated. We model the output
// 'y' to be normally distributed with mean 'mu'
// and standard deviation 'sigma'.
model {
  mu ~ normal(0, 1);
  to_vector(beta) ~ double_exponential(0, 1); // normal(0, 1);
  b ~ gamma(1, 1);
  phi ~ normal(0, 1); 
  sigma ~ inv_gamma(1, 1);
  to_vector(x) ~ normal(to_vector(rep_matrix(mu, N) + beta * beh' + rep_matrix(phi, R)'), sigma);
  for (s in 1:N) {
    count[s] ~ poisson((lambda[,s] + b[s]) .* volume);
  }
}

