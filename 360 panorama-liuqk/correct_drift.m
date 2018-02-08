function shift_correct = correct_drift(images_projection, shift)
% CORRECT_DRIFT: this function cerrect the drift between the first and last
% images
%
% -- input:
%    images_projection: a cell with each element of it is a projected image
%        from the original images.
%    shift: a N x 2 matrix, and eac row in 'shift' is the shift between the
%        neighbouring images. For example, shift(i,:) is the shift of
%        images_projection{i} and images_projection{i+1}.
%
% -- output:
%    shift_correct: the corrected shift between the neighbouring images.

image_pro_pre = images_projection{end};
image_pro = images_projection{1};

image_sift_pre = sift_panorama(image_pro_pre);
image_sift = sift_panorama(image_pro);

show_matched_results = 0;
[matches, distance] = sift_match_panorama(image_sift_pre, image_sift, show_matched_results);

% obtain the shift of neighbouring pairs using RANSAC
[x_shift, y_shift] = ransac_for_shift(matches, image_sift_pre, image_sift);

% obtain the drift
shift_correct = shift;
for shift_index = size(shift,1)-1:-1:1
    one_shift = shift_correct(shift_index + 1,:);
    shift_adjust = [0, max(0, one_shift(2))];
    shift_correct(shift_index,:) = shift(shift_index,:) + shift_adjust;
end
drift = sum(shift_correct(:,2)) + y_shift;

shift_correct(:,2) = shift(:,2) + drift/length(images_projection);
end