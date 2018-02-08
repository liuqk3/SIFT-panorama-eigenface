function sift_match(image1, image2)
% SIFT_MATCH: this function match tow images based on sift features.
%
% -- input:
%
%    'image1': a structure, which has three domains, image, keypoints and
%        drescriptor. It denotes the first image to be matched.
%
%    'image2': a structure, which has three domains, image, keypoints and
%        drescriptor. It denotes the second image to be matched.

num_points1 = size(image1.descriptor,1);
num_points2 = size(image2.descriptor,1);
distance = zeros(num_points1,num_points2);
matched_points = [];
fprintf(' Matching ...\n');
for i = 1:num_points1
    descriptor_tmp1 = image1.descriptor(i,:);
    dist = (repmat(descriptor_tmp1,num_points2,1) - image2.descriptor);
    dist = sqrt(sum(dist.^2, 2)); % collum vector
    distance(i,:) = dist';
    [distance_sort, index] = sort(distance(i,:));
    if distance_sort(1)/distance_sort(2) < 0.64
        matched_points = [matched_points;[i, index(1)]];
    end
end
fprintf(' Among these two pictures, %d keypoints are matched.\n', size(matched_points,1));

im1_size = size(image1.image);
im2_size = size(image2.image);
if length(im2_size) == 3
    image_stitch = zeros([ max(im1_size(1),im2_size(1)), im1_size(2)+im2_size(2),3]);
    image_stitch(1:im1_size(1),1:im1_size(2),:) = image1.image;
    image_stitch(1:im2_size(1),im1_size(2)+1:im1_size(2)+ im2_size(2),:) = image2.image;

else
    image_stitch = zeros([ max(im1_size(1),im2_size(1)), im1_size(2)+im2_size(2)]);
    image_stitch(1:im1_size(1),1:im1_size(2)) = image1.image;
    image_stitch(1:im2_size(1),im1_size(2)+1:im1_size(2)+ im2_size(2)) = image2.image;
end

figure();
imshow(uint8(image_stitch));
for i = 1:size(matched_points,1)
    hold all;
    
    point1_coordinate = image1.keypoints(matched_points(i,1),1:2);
    point2_coordinate = image2.keypoints(matched_points(i,2),1:2) + [im1_size(2) 0];
    color = rand(1,3);
    plot([point1_coordinate(1), point2_coordinate(1)],[point1_coordinate(2), point2_coordinate(2)],'Color',color);
    
    
%     point1_coordinate = image1.keypoints(matched_points(i,1),1:2);
%     point2_coordinate = image2.keypoints(matched_points(i,2),1:2) + im1_size(2:-1:1);
%     color = rand(1,3);
%     plot([point1_coordinate(1), point2_coordinate(1)],[point1_coordinate(2), point2_coordinate(2)],'Color',color);
end


end
