function DoG_images = dog_images(GkC_images, sublevels, octaves, sigma)

% DOG_IMAGES: This function return the DoG images.
%
% -- input:
%
%    'GkC_images': the iamges that convoluted with Gaussian kernels.
%
%    'sublevels': scalar, the number of layers in each octave.
%
%    'octaves': saclar, the number of octaves.
%
%    'sigma':scalar, the standard devation of the firts layer in the given
%            'octave'.
% -- output:
%
%    'DoG_images'; a cell with each element is also a cell (this sub-cell 
%        contains all DoG images in corresponding octave).

DoG_images = {};
for o = 1:octaves
    one_octave_DoG_images = {};
    one_octave_GkC_images = GkC_images{o};
    for s = 1:sublevels + 2
        fprintf(' Computing %d / %d DoG image in octave %d / %d... \n',s, sublevels + 2, o, octaves);
        DoG_image_tmp = (one_octave_GkC_images{s + 1} - one_octave_GkC_images{s});
        %sigma_level = sigma*2^(s-1);
        DoG_image_tmp = DoG_image_tmp / (2^(1/sublevels) -1);
        one_octave_DoG_images = [one_octave_DoG_images, {DoG_image_tmp}];

%         % show DoG images
%         DoG_image_tmp = DoG_image_tmp - mean(mean(DoG_image_tmp));
%         DoG_image_tmp = DoG_image_tmp / (max(max(DoG_image_tmp)) - min(min(DoG_image_tmp))); %normalize the image
%         figure();
%         imshow(DoG_image_tmp,'Colormap',jet(255));
        
 
    end
    DoG_images = [DoG_images, {one_octave_DoG_images}];
end

end