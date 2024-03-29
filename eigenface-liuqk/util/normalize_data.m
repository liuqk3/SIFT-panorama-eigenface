function [X_norm, mu, sigma] = normalize_data(X)
%NORMALIZEFEATURES Normalizes the features in X 
%   [X_norm, mu, sigma] = normalizeFeatures(X) returns a normalized version 
%   of X where the mean value of each feature is 0 and the standard deviation
%   is 1.

%X = (double(X))';
mu = mean(X);
X_norm = bsxfun(@minus, X, mu);

sigma = std(X_norm);
X_norm = bsxfun(@rdivide, X_norm, sigma);

%X_norm = X_norm';
end
