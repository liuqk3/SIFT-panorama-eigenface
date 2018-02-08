function extreme_points_coordinates = detect_extreme_point(DoG_images, sublevels, octaves, sigma)

% DETECT_EXTREME_POINT: This function return the DoG images.
%
% -- input:
%
%    'DoG_images': the DoG iamges.
%
%    'sublevels': scalar, the number of layers in each octave.
%
%    'octaves': saclar, the number of octaves.
%
%    'sigma':scalar, the standard devation of the firts layer in the given
%        'octave'.
%
% -- output:
%
%    'coordinates': a N x 4 matrix, each row is one coordinates of extreme
%        points, (x, y, octave, sublevel). We should note that the (x, y) is the 
%        coordinate of this extreme point in the 'octave'-th octave.

T = 90; %t
extreme_points_coordinates = [];
for o = 1:octaves
    fprintf(' Dectecting extreme points in %d / %d octave...\n',o, octaves);
    for s = 1 + 1:sublevels + 2 - 1
        image_size = size(DoG_images{o}{s});
        for row = 1 + 1:image_size(1) - 1
            for collum = 1 + 1:image_size(2) - 1
                cubic = zeros([3, 3, 3]);
                cubic(:,:,1) = DoG_images{o}{s-1}(row-1:row+1,collum-1:collum+1);
                cubic(:,:,2) = DoG_images{o}{s}(row-1:row+1,collum-1:collum+1);
                cubic(:,:,3) = DoG_images{o}{s+1}(row-1:row+1,collum-1:collum+1);
                
                if max(max(max(cubic))) == cubic(2,2,2) || min(min(min(cubic))) == cubic(2,2,2)% find extreme points
                    if abs(cubic(2,2,2)) > 0.5*T/s; % threshold suppression
                        %one_point_coordinate = floor([row, collum] .* 2^(o));
                        one_point_coordinate = [collum, row, o, s];
                        extreme_points_coordinates = [extreme_points_coordinates; one_point_coordinate];
                    end
                    
                end
            end
        end
    end
end


end