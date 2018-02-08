function result = sift(image, show_sift, show_sift_type)

% SIFT: this function return the SIFT features of the image.
%
% -- input:
%
%    'image': the image need to be processed.
%
%    'show_sift': integer or boolean, to determin whther to show the
%        detected keypoints.
% 
%    'show_sift_type': string, it can be '+', '*', 'o', 'arrow' and so on,
%        which determin the label to show the keypoint.
%
% -- output:
%
%    'result': structure which has three domains, image, keypoints and
%        drescriptor.

% if the image is RGB image, chage it into gray iamge.
if length(size(image)) == 3
    image_gray = rgb2gray(image);
else
    image_gray = image;
end

%normalize the image
%image_gray = image_gray - mean(mean(image_gray));
image_gray = image_gray / (max(max(image_gray)) - min(min(image_gray)));

sigma = sqrt(1.6);
sublevels = 3;
image_size = size(image_gray);
octaves = floor(log2(min(image_size))) - 3;
max_iterations = 5;

GkC_images = gkc_images(image, sublevels, octaves, sigma);
DoG_images = dog_images(GkC_images, sublevels, octaves, sigma);
coordinates = detect_extreme_point(DoG_images, sublevels, octaves, sigma);
fprintf(' There are %d extreme points.\n', size(coordinates,1));

% figure();
% imshow(image);
% for i = 1:size(coordinates,1)
%     hold all;
%     coordinate = coordinates(i,1:2) * 2^(coordinates(i,3) - 1);
%     plot(coordinate(1),coordinate(2),show_sift_type, 'Color','Cyan','markersize',6);
% end
% title('befor accurate keypoint location');



coordinates = accurate_keypoint_location(coordinates,DoG_images, max_iterations);
fprintf(' After accurate keypoints location and edge response elimination, there are %d keypoints.\n', size(coordinates,1));

angle_interval_descriptor = 2*pi/8; %the interval to divide 2*pi, which is used to generate descriptor
angle_interval_keypoint = 2*pi/36; %the interval to divide 2*pi, which is used to compute the main ngle of keypoints
[keypoints, descriptor] = generate_descriptor(coordinates, GkC_images, sigma, sublevels, angle_interval_keypoint, angle_interval_descriptor);

if show_sift
    draw_sift(image, keypoints, angle_interval_keypoint,show_sift_type);
end

result.image = image;
result.keypoints = keypoints;
result.descriptor = descriptor;

end