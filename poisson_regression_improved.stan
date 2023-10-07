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
  matrix[R, D] W;
  vector<lower=0>[N] sigma;
  vector[R] mu;
  matrix[D, N] z;
  matrix[R, N] x;
  vector<lower=0>[D] alpha;
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
  alpha ~ gamma(1, 10);
  mu ~ normal(0, 1);
  to_vector(beta) ~ normal(0, 1);
  sigma ~ inv_gamma(1, 1);
  for (k in 1:D) {
    W[,k] ~ normal(0, alpha[k]);
  }
  to_vector(x) ~ normal(to_vector(W * z + rep_matrix(mu, N) + beta * beh' + rep_matrix(phi, R)'), to_vector(rep_matrix(sigma, R)'));
  for (s in 1:N) {
    z[,s] ~ normal(0, 1);
    count[s] ~ poisson((lambda[,s] + b[s]) .* volume);
  }
}

