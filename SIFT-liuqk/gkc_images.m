function GkC_images = gkc_images(image, sublevels, octaves, sigma)

% GKC_IMAGES: this function return the iamges convoluted with Gaussian kernels.
%
% -- input:
%
%    'image': the iamge to be processed, color or gray.
%
%    'sublevels': scalar, the number of layers in each octave.
%
%    'octaves': saclar, the number of octaves.
%
%    'sigma':scalar, the standard devation of the firts layer in the given
%        'octave'.
%
% -- output:
%
%    'GkC_images'; a cell with each element is also a cell (this sub-cell
%        contains all convoluted images in corresponding octave).

% if 'image' is a color image, transform it into gray.
if length(size(image)) == 3
    image = rgb2gray(image);
end

image_tmp = convolution(image, gaussian_kernel(0.5));

% creat Gaussian kernel Convoluted images.
GkC_images = {};
for o = 1:octaves
    one_octave_GkC_images = {};
    for s = 1:sublevels + 3
        fprintf(' Computing %d / %d GkC image in octave %d / %d... \n',s, sublevels + 3, o, octaves);
        %kernel = gaussian_kernel(sigma * 2^((s-1)/sublevels + (o-1)));
        kernel = gaussian_kernel(sigma * 2^((s-1)/sublevels));
        conv_image = convolution(image_tmp, kernel);
        one_octave_GkC_images = [one_octave_GkC_images, {conv_image}];
        %figure();
        %imshow(conv_image,'Colormap',jet(255));
    end
    GkC_images = [GkC_images, {one_octave_GkC_images}];
    %image_tmp = one_octave_GkC_images{sublevels + 1};
    image_tmp_size = size(image_tmp);
    image_tmp = imresize(image_tmp, floor(image_tmp_size/2));
end

end