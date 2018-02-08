function [X_c, mu] = centerlize_data(X)
% CENTERLIZE_DATA: this functioin minus X by its mean value.
%
% -- input:
%    X: a matrix, the data need to be processed.
% -- output:
%    X_c: a matrix, the centerlized data.
%    mu: the mean value of input data X.

mu = mean(X, 1);
X_c = bsxfun(@minus, X, mu);

end