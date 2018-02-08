function [keypoints, descriptor] = generate_descriptor(coordinates, GkC_images, sigma,sublevels, angle_interval_keypoint, angle_interval_descriptor)
%
% GENERATE_DESCRIPTOR This function compute the discriptor of keypoints.
%
% -- input:
%
%    'coordinates': a N x 4 matrix, each row is one coordinates of extreme
%        points, (x, y, octave, sublevel). We should that the (x, y) is the
%        coordinate of this extreme point in the 'octave'-th octave.
%
%    'GkC_images'; a cell with each element is also a cell (this sub-cell
%        contains all GkC images in corresponding octave).
%
%    'sigma': scalar, the standard devation of the firts layer in the given
%        'octave'.
%
%    'angle_interval_keypoint': the interval to divide 2*pi, which is used
%        to compute the main angle of descriptor.
%
%     'angle_interval_descriptor': the interval to divide 2*pi, so in each
%        (seed) will be 2*pi/angle_interval histograms, which is used to
%        generate descriptor.
%
% -- output:
%
%    'keypoints': a N x 4 matrix with one row corresponding to a keypoint.
%        and each row has four elements (x, y, angle, magnitude). The
%        'magnitude' is normalized. (x, y) is the coordinate in the original 
%        image.
%
%    'descriptor': a N x D matrix, where D is determined by the input. Each
%        row in descriptor is a descriptor of a keypoint. And 'descriptor'
%        is normalized.

d = 4; % d^2 seed point will be produced
keypoints = zeros(size(coordinates));
descriptor = zeros(size(coordinates,1),d^2 * (2*pi / angle_interval_descriptor));
fprintf(' Generating descriptors ...\n');
for point =1:size(coordinates,1)
    coordinate_tmp = round(coordinates(point,:));
    sigma_level = (sigma * 2^(coordinate_tmp(4)-1)/sublevels) * 2;
    patch_size = (6/2 * sigma_level * 2 + 1) * 3;% the patch centered at a keypoint is cropped
    %patch_size = floor( 6/2 * sigma * 2^((coordinate_tmp(4)-1)/sublevels + coordinate_tmp(3) - 1) ) * 2 + 1;
    patch_size = floor(patch_size);
    
    % make sure the patch size can be divide into d^2 subpatches to generate d^2 seed
    if mod(patch_size,d) ~= 0
        patch_size = patch_size + d - mod(patch_size, d);
    end
    sub_patch_size = patch_size/d;% used to generate seed point
    GkC_image_tmp = GkC_images{coordinate_tmp(3)}{coordinate_tmp(4)};
    image_size = size(GkC_image_tmp);%(rows, collums), that is (y,x)
    pad = 3;
    
    %% compute the main orientation and the gradient magnitude
    histogram_keypoint = zeros(1,2*pi/angle_interval_keypoint);
    [xs, ys] = meshgrid(-(patch_size+2*pad)/2:(patch_size+2*pad)/2 - 1);
    % crop the patch
    xs_crop = xs + coordinate_tmp(1);
    ys_crop = ys + coordinate_tmp(2);
    % make sure the patch is in the image, so that we can to compute the derivates of each pixels in this patch
    xs_crop(xs_crop>image_size(2)-1) = image_size(2) - 1;
    xs_crop(xs_crop<2) = 2;
    ys_crop(ys_crop>image_size(1)-1) = image_size(1) - 1;
    ys_crop(ys_crop<2) = 2;
    
    for collum = 1:patch_size
        for row = 1:patch_size
            dy = (GkC_image_tmp(ys_crop(row+pad+1,collum+pad), xs_crop(row+pad+1,collum+pad)) - GkC_image_tmp(ys_crop(row+pad-1,collum+pad), xs_crop(row+pad-1,collum+pad)))/2 * exp(-(ys(row+pad,collum+pad)^2 + xs(row+pad,collum+pad)^2)/(60*sigma_level));
            dx = (GkC_image_tmp(ys_crop(row+pad,collum+pad+1), xs_crop(row+pad,collum+pad+1)) - GkC_image_tmp(ys_crop(row+pad,collum+pad-1), xs_crop(row+pad,collum+pad-1)))/2 * exp(-(ys(row+pad,collum+pad)^2 + xs(row+pad,collum+pad)^2)/(60*sigma_level));
            
            angle = atan(dy/dx);
            if dx <= 0
                angle = angle + pi;
            end
            % obtain angle index
            if isnan(angle) % dy = 0, dx = 0
                angle = 0;
                dy = 0;
                dx = 0;
            end
            if ~isfinite(angle) % dx = 0
                dx = 0;
                if dy > 0
                    angle = pi/2;
                elseif dy < 0
                    angle = 3*pi/2;
                end
            end
            if angle < 0
                angle = angle + 2*pi;
            end
            if angle == 2*pi
                angle = 0;
            end
            angle = floor(angle/angle_interval_keypoint) + 1;
            magnitude = sqrt(dy^2 + dx^2);
            histogram_keypoint(angle) = histogram_keypoint(angle)+magnitude;
        end
    end
    %histogram_keypoint = histogram_keypoint./sqrt(sum(histogram_keypoint.^2));
    
    histogram_keypoint = smooth_histogram(histogram_keypoint,1);
    
    main_magnitude = max(histogram_keypoint);
    main_angle = find(histogram_keypoint == main_magnitude);
    
    %% generate the discriptor
    % rotate patch to the main orientation of keypoint
    angle = main_angle * angle_interval_keypoint;
    xs_r = round(xs.*cos(angle) - ys.*sin(angle));
    ys_r = round(xs.*sin(angle) + ys.*cos(angle));
    % crop the patch
    xs_r_crop = xs_r + coordinate_tmp(1);
    ys_r_crop = ys_r + coordinate_tmp(2);
    % make sure that the rotated patch is in the image, so we can calculate the derivative of each pixel in the patch
    xs_r_crop(xs_r_crop>image_size(2)-1) = image_size(2) - 1;
    xs_r_crop(xs_r_crop<2) = 2;
    ys_r_crop(ys_r_crop>image_size(1)-1) = image_size(1) - 1;
    ys_r_crop(ys_r_crop<2) = 2;
    
    one_descriptor = zeros(d^2,2*pi/angle_interval_descriptor);
    % fprintf('point = %d\n',point);
    
    for collum = 1:patch_size
        for row =  1: patch_size
            dy = (GkC_image_tmp(ys_r_crop(row+pad+1,collum+pad), xs_r_crop(row+pad+1,collum+pad)) - GkC_image_tmp(ys_r_crop(row+pad-1,collum+pad), xs_r_crop(row+pad-1,collum+pad)))/2 * exp(-(ys_r(row+pad,collum+pad)^2 + xs_r(row+pad,collum+pad)^2)/(60*sigma_level));%exp(-(ys_r(row+pad,collum+pad)^2 + xs_r(row+pad,collum+pad)^2)/(1.5*sigma^(coordinate_tmp(4)-1)));
            dx = (GkC_image_tmp(ys_r_crop(row+pad,collum+pad+1), xs_r_crop(row+pad,collum+pad+1)) - GkC_image_tmp(ys_r_crop(row+pad,collum+pad-1), xs_r_crop(row+pad,collum+pad-1)))/2 * exp(-(ys_r(row+pad,collum+pad)^2 + xs_r(row+pad,collum+pad)^2)/(60*sigma_level));% exp(-(ys_r(row+pad,collum+pad)^2 + xs_r(row+pad,collum+pad)^2)/(1.5*sigma^(coordinate_tmp(4)-1)));
            
            angle = atan(dy/dx);
            if dx <= 0
                angle = angle + pi;
            end
            % obtain angle index
            if isnan(angle) % dy = 0, dx = 0
                angle = 0;
                dy = 0;
                dx = 0;
            end
            if ~isfinite(angle) % dx = 0
                dx = 0;
                if dy > 0
                    angle = pi/2;
                elseif dy < 0
                    angle = 3*pi/2;
                end
            end
            if angle < 0
                angle = angle + 2*pi;
            end
            if angle == 2*pi
                angle = 0;
            end
            %fprintf(' angle = %f\n',angle);
            angle = floor(angle/angle_interval_descriptor) + 1;
            %fprintf('dy / dx = %f, angle = %d\n',dy/dx,angle);
            magnitude = sqrt(dy^2 + dx^2);
            % obtain seed point index
            if mod(collum,sub_patch_size) ~= 0
                if mod(row, sub_patch_size) ~= 0
                    seed_index = d * floor(row/sub_patch_size) + floor(collum/sub_patch_size)+1;
                else
                    seed_index = d * (floor(row/sub_patch_size) - 1) + floor(collum/sub_patch_size)+1;
                end
            else
                if mod(row, sub_patch_size) ~= 0
                    seed_index = d * floor(row/sub_patch_size) + floor(collum/sub_patch_size);
                else
                    seed_index = d * (floor(row/sub_patch_size) - 1) + floor(collum/sub_patch_size);
                end
            end
            %fprintf('seed_index = %d\n',seed_index);
            one_descriptor(seed_index, angle) = one_descriptor(seed_index,angle) + magnitude;
        end
    end
    
    
    one_descriptor = one_descriptor/sqrt(sum(sum(one_descriptor.^2)));% normalization
    
    for histogram_index = 1:size(one_descriptor,1)
        one_descriptor(histogram_index,:) = smooth_histogram(one_descriptor(histogram_index,:),1);
    end
    
    one_descriptor(one_descriptor > 0.2) = 0.2;
    
    %keypoints(point,:) = [round( coordinates(point,1:2)*(2^(coordinates(point,3)-1)) ), main_angle, main_magnitude];% (x,y,magnituge, angle) of keypoint
    
    keypoints(point,:) = [coordinates(point,1:2)*(2^(coordinates(point,3)-1)), main_angle, main_magnitude];% (x,y,magnituge, angle) of keypoint
    
    %keypoints(point,:) = [coordinates(point,:), main_angle, main_magnitude];% (x,y,magnituge, angle) of keypoint
    
    %resize the descriptor of a keypoint to a row vector
    one_descriptor = one_descriptor';
    one_descriptor = one_descriptor(:);
    one_descriptor = one_descriptor';
    descriptor(point,:)= one_descriptor;
    
end
end