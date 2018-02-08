
function kernel =  gaussian_kernel(sigma)

% GAUSSIAN_KERNEL: this function returns a Gaussian kernel produced with 
%    the standard devation 'sigma'.
%
% -- input:
%
%    'sigma': scalar, the standard devation.
%
% -- output:
%
%    'kernel': 2-D matrix, the Gaussian kernel produced with 'sigma'.

size_of_kernel = floor(6/2 * sigma) * 2 + 1; % This is an odd number.
range = [1:size_of_kernel] - (size_of_kernel + 1)/2;
[x, y] = meshgrid(range);
kernel = 1/(2*pi*sigma^2) * exp(-(x.^2 + y.^2)/(2*sigma^2));
end