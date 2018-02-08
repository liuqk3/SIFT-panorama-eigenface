function modified_coordinates = accurate_keypoint_location(coordinates, DoG_images, max_iterations)

%  ACCURATE_KEYPOINT_LOCATION: this function return the modified coordinates 
% of key points, in the mean time, it performs the elimination of edge 
% response.
%
% -- input:
%    'coordinates': a N x 4 matrix, each row is one coordinates of extreme
%        points, (x, y, octave, sublevel). We should that the (x, y) is the 
%        coordinate of this extreme point in the 'octave'-th octave.
%    'DoG_image': the DoG images
%
%    'max_iterations': the maximum iterations
%
% -- output
%
%    'modified_coordinates': a N x 4 matrix, each row is one coordinates of
%        extreme points, (x, y, octave, sublevel). We should that the (x, y)
%        is the coordinate of this extreme point in the 'octave'-th octave.

fprintf(' Accuratting keypoint location...\n');
stable_threshold = 0.05;% used to remove unstable points
edge_threshold = 6;% used for eliminating edge response
modified_coordinates = [];
for point = 1:size(coordinates,1)
    coordinate_tmp = coordinates(point,:);
    for iteration = 1:max_iterations
        dx = derivative(coordinate_tmp, [0 1], DoG_images);
        dy = derivative(coordinate_tmp, [0 2], DoG_images);
        dsigma = derivative(coordinate_tmp, [0 3], DoG_images);
        one_order_derivative = [dx, dy, dsigma]';
        
        dxx = derivative(coordinate_tmp, [1 1], DoG_images);
        dxy = derivative(coordinate_tmp, [1 2], DoG_images);
        dxsigma = derivative(coordinate_tmp, [1 3], DoG_images);
        dyy = derivative(coordinate_tmp, [2 2], DoG_images);
        dysigma = derivative(coordinate_tmp, [2 3], DoG_images);
        dsigmasigma = derivative(coordinate_tmp, [3 3], DoG_images);
        two_order_derivative = [dxx, dxy, dxsigma; dxy, dyy, dysigma; dxsigma, dysigma, dsigmasigma];
        Hessian = [dxx,dxy; dxy, dyy];
        
        shift = [0, 0, 0]';% [x, y, sigma]'
        % if the two order derivative matrixis reversible
        if det(two_order_derivative) ~= 0
            shift = - two_order_derivative^(-1) * one_order_derivative;
        end
        D = DoG_images{coordinate_tmp(1,3)}{coordinate_tmp(1,4)}(coordinate_tmp(1,2),coordinate_tmp(1,1));
        D_hat = D + 0.5 * one_order_derivative' * shift;
        
        if abs(D_hat) > stable_threshold % remove unstable points
            image_size = size(DoG_images{coordinate_tmp(1,3)}{1,1});% (heigth,width), used for juding whether a point locates in the image or not.
            if max(shift) <= 0.5 && min(shift) >= -0.5
                coordinate_tmp(1,1) = coordinate_tmp(1,1) + shift(1);
                coordinate_tmp(1,2) = coordinate_tmp(1,2) + shift(2);
                coordinate_tmp(1,4) = coordinate_tmp(1,4) + shift(3);
                % if the extreme point locates in the image and scale space, try to keep it
                if (coordinate_tmp(1,1) > 1 && coordinate_tmp(1,1) < image_size(2) -1) && (coordinate_tmp(1,2) > 1 && coordinate_tmp(1,2) < image_size(1) -1)
                    if det(Hessian) > 0 && (trace(Hessian)^2) / det(Hessian) < (edge_threshold + 1)^2 / edge_threshold % eliminating edge response
                        modified_coordinates = [modified_coordinates; coordinate_tmp];
                    end
                end
                break; % stop the iteration
            else
                shift(shift >= -0.5 & shift <= 0.5) = 0;
                shift(shift > 0.5) = 1;
                shift(shift < -0.5) = -1;
                coordinate_tmp(1,1) = coordinate_tmp(1,1) + shift(1);
                coordinate_tmp(1,2) = coordinate_tmp(1,2) + shift(2);
                coordinate_tmp(1,4) = coordinate_tmp(1,4) + shift(3);
                % if the adjusted extreme point is out of the image and scale space, delete it
                if (coordinate_tmp(1,1) < 2 || coordinate_tmp(1,1) > image_size(2) -1) || (coordinate_tmp(1,2) < 2 || coordinate_tmp(1,2) > image_size(1) -1) || (coordinate_tmp(1,4) < 2 || coordinate_tmp(1,4) > size(DoG_images{1},2) - 1)
                    break; % stop the iteration
                end
            end
        end
    end % end  iterations
end

end