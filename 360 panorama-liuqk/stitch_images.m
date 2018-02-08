function stitch_image = stitch_images(image_pre, image, shift)
% STITCH_IMAGES: this function stitch two images together.
%
% -- input:
%    image_pre: the image that need to be stitched on the left, RGB or
%        gray.
%    image:the image need to be stitched on the right, RGB or gray.
%    shift: the shift between 'image_pre' and 'image'.
%
% -- output:
%    stitch_image: the image that stitched based on 'image_pre' and
%        'image'.

image_size_pre = size(image_pre);
image_size = size(image);
x_shift = round(shift(1));
y_shift = round(shift(2));

stitch_image_w = image_size_pre(2) + image_size(2) - x_shift;
% if y_shift >= 0
% 
%     stitch_image_h = max(image_size_pre(1) + y_shift, image_size(1));
% else
%     stitch_image_h = max(image_size(1) - y_shift, image_size_pre(1));
% end
stitch_image_h = max(image_size(1) - min(0, y_shift), image_size_pre(1) + max(0, y_shift));

if length(image_size_pre) == 3
    stitch_image1 = zeros(stitch_image_h,stitch_image_w,3);
else
    stitch_image1 = zeros(stitch_image_h,stitch_image_w);
end

stitch_image2 = stitch_image1;

% we first handle the regions that are not overlapped.
x_range = 1:image_size_pre(2);
y_range = (1:image_size_pre(1)) + max(0,y_shift);
stitch_image1(y_range, x_range,:) = image_pre;
x_range = (1:image_size(2)) + image_size_pre(2) - x_shift;
y_range = (1:image_size(1)) - min(0,y_shift);
stitch_image2(y_range, x_range,:) = image;

% then handle the reagion that is overlaped
weight1 = ones(size(stitch_image1));
weight2 = ones(size(stitch_image2));
overlap_weight = 1:x_shift;
overlap_weight = overlap_weight ./ x_shift;
overlap_weight = repmat(overlap_weight,stitch_image_h,1,size(stitch_image1,3));

overlap_collum = image_size_pre(2) - x_shift + 1:image_size_pre(2);
weight1(:,overlap_collum,:) = 1 - overlap_weight;
weight2(:,overlap_collum,:) = overlap_weight;

stitch_image = weight1 .* stitch_image1 + weight2 .* stitch_image2;

stitch_image = uint8(stitch_image);

end
