function [x_shift, y_shift] = ransac_for_shift(matches, image_sift_pre, image_sift)
% RANSAC_FOR_SHIFT: this function comput the shift of neighbouring images.
%
% -- input: 
%    image_sift_pre: a structure with 3 domains: 'image', 'keypoints',
%        'descriptor'. 'keypoints' is N x 6 matrix, 'descriptor' is a N x 
%        128 matrix, and they are the keypoints and descriptor of 'image', 
%        please refer to function sift_panorama for more information. The 
%        'image' is the image need to be sitiched in the left.
%    image_sift: a structure with 3 domains: 'image', 'keypoints',
%        'descriptor'. 'keypoints' is N x 6 matrix, 'descriptor' is a N x 
%        128 matrix, and they are the keypoints and descriptor of 'image', 
%        please refer to function sift_panorama for more information. The 
%        'image' is the image need to be sitiched in the right.
%    matches: N x 2 matrix, return by function sift_match_panorama, and
%        each row in it is the index of matched keypoints in image1.
%        keypoints and image2.keypoints. For example, the i-th row (m,n) 
%        denotes the i-th matched keypoints, and it means that m-th 
%        keypoint in image_sift_pre.keypoints is matched with n-th
%        keypoint in image_sift.keypoints. Please refer to function
%        sift_match_panorama for more infromation.
%
% --output:
%    x_shift: the shift between two images in x axis.
%    y_shift: the shift between two images in y axis.

% RANSAC
image_size_pre = size(image_sift_pre.image);
number_of_matches = size(matches,1);
max_inliers = 0;
best_matches = [];% the matched points that generate the best model
threshold_ransac = 8;
max_iterations = 400;
for iteration = 1:max_iterations
    % choose some matched points randomly to generate the model
    random_matches_index = randperm(number_of_matches,ceil(0.15*number_of_matches));
    random_matches = matches(random_matches_index,:);
    x1_points = image_sift_pre.keypoints(random_matches(:,1),1);
    y1_points = image_sift_pre.keypoints(random_matches(:,1),2);
    x2_points = image_sift.keypoints(random_matches(:,2),1) + image_size_pre(2);
    y2_points = image_sift.keypoints(random_matches(:,2),2);
    
    x_shift = round(mean(x2_points - x1_points));
    y_shift = round(mean(y2_points - y1_points));
    
    inliers = 0; % to counter the inliers that meet the model
    for matched_point = 1: number_of_matches
        point1 = image_sift_pre.keypoints(matched_point,1:2);% (x,y) of matched point in image1
        point2 = image_sift.keypoints(matched_point,1:2) + [image_size_pre(2), 0];% (x,y) of matched point in image2
        point2_shift = point2 - [x_shift, y_shift];
        error = point2_shift - point1;
        if error(1) < threshold_ransac && error(2) < threshold_ransac
            inliers = inliers + 1;
            %matches_ransac = [matches_ransac; matches(matched_point,:)];
        end
    end
    % if we fined a better model
    if inliers >= max_inliers
        max_inliers = inliers;
        best_matches = random_matches;
    end
    % if the model meet our requirement, the break the for loop
    if inliers > floor(0.6 * number_of_matches)
        fprintf(' A model is found by RANSAC.\n');
        break;
    elseif iteration == max_iterations
        fprintf(' No model is found by RANSAC.\n');
    end
end

x1_points = image_sift_pre.keypoints(best_matches(:,1),1);
y1_points = image_sift_pre.keypoints(best_matches(:,1),2);
x2_points = image_sift.keypoints(best_matches(:,2),1) + image_size_pre(2);
y2_points = image_sift.keypoints(best_matches(:,2),2);

x_shift = mean(x2_points - x1_points);
y_shift = mean(y2_points - y1_points);

end