function conv_image = convolution(image, kernel)

% CONVOLUTION: This function compute the convolution of a image and a kernel 
% with stride equals to 1, and the image is first padded to keep the size 
% of convolved image unchaged. 
%
% -- input:
%
%    'image': the image need to be convolved, color or gray.
%
%    'kernel': concolution kernel, 2-D, that is single cahnel.
%
% -- output:
%
%    'conv_image': the convolved image, has the same size with 'image'.

image_size = size(image); %(height, width, channel)
if length(image_size) == 2 % if 'image' is a gray image, set it a single image.
    image_size = [image_size, 1];
end
kernel_size = size(kernel);

stride = 1;

pad_size = floor( (image_size(1:2)*(stride-1) + kernel_size - stride)/2);

% pad the image
ys = 1:2*pad_size(1) + image_size(1);%height
xs = 1:2*pad_size(2) + image_size(2);%width
ys(ys<pad_size(1)+1) = pad_size(1)+1;
xs(xs<pad_size(2)+1) = pad_size(2)+1;
ys(ys>pad_size(1) + image_size(1)) = pad_size(1) + image_size(1);
xs(xs>pad_size(2) + image_size(2)) = pad_size(2) + image_size(2);

padded_image = zeros([image_size(1:2) + 2*pad_size, image_size(3)]);
padded_image(pad_size(1) + 1: pad_size(1) + image_size(1),pad_size(2) + 1: pad_size(2) + image_size(2),:) = image;
padded_image = padded_image(ys,xs,:);

% make sure the channels of kernel and image are the same
for i = 1:image_size(3)
    multi_channel_kernel(:,:,i) = kernel;
end
conv_image = zeros(image_size);
for row = 1:stride:image_size(1)
   for collum = 1:stride:image_size(2)
      patch = padded_image((row-1)*stride+1:(row-1)*stride + kernel_size(1),(collum-1)*stride+1:(collum-1)*stride + kernel_size(2),:);
      conv_image(row, collum,:) = sum(sum(patch.*multi_channel_kernel));
   end
end
% figure();
% imshow(image);
% figure();
% imshow(uint8(padded_image));
% figure();
% imshow(uint8(conv_image));
% size(image)
% size(conv_image)

end