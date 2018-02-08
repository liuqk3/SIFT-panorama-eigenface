function result = sift_panorama(image)

% SIFT_PANORAMA: this function return the SIFT features of the image.
%
% -- input:
%    image: the image need to be processed.
%
% -- output:
%    result: structure which has three domains, image, keypoints and
%        drescriptor.

% if the image is RGB image, chage it into gray iamge.
if length(size(image)) == 3
    image_gray = rgb2gray(image);
else
    image_gray = image;
end

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

coordinates = accurate_keypoint_location(coordinates,DoG_images, max_iterations);
fprintf(' After accurate keypoints location and edge response elimination, there are %d keypoints.\n', size(coordinates,1));

angle_interval_descriptor = 2*pi/8; %the interval to divide 2*pi, which is used to generate descriptor
angle_interval_keypoint = 2*pi/36; %the interval to divide 2*pi, which is used to compute the main ngle of keypoints
[keypoints, descriptor] = generate_descriptor(coordinates, GkC_images, sigma, sublevels, angle_interval_keypoint, angle_interval_descriptor);

result.image = image;
result.keypoints = keypoints;
result.descriptor = descriptor;

end