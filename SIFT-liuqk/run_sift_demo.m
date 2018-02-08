clear;
close all;
show_sift = 1;
show_sift_type = '+';%'arrow','o','*';

% read images
image1 = imread('./pictures/candida1.jpg');
image2 = imread('./pictures/candida2.jpg');

% detect keypoints and generate descriptor
image1_sift = sift(image1,show_sift, show_sift_type);
image2_sift = sift(image2,show_sift, show_sift_type);

% match
sift_match(image1_sift, image2_sift);





