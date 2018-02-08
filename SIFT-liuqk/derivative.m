function derivative = derivative(coordinate, arguments, images)

% DERIVATIVE: this function returns the one order or second partial derivative.
%
% -- input:
%
%    'coordinate': 1 x 4 vector,, the coordinate of extreme points, (x, y, 
%       octave, sublevel), where 'x' and 'y' are collum and row. We should 
%       that the (x, y)  is the coordinate of this extreme point in the 
%       'octave'-th octave.
%
%    'arguments': 1 x 2 vector, denoting the argument that the derivative
%        respect to. Let the number '1', '2', '3' denote the arguments 'x',
%        'y', 'sigma'. If one element of 'arguments' is '0', the derivative 
%        is one order, otherwise the derivative is two order. For example, 
%        'arguments' can be [1 0], [2 0], [3 0] to compute corresponding 
%        one order derivatives, [1 2] ([2 1]), [1 3] ([3 1]), [2 3] ([3 2]),
%        [1 1], [2 2] or [3 3] to compute 2 order derivatives.
%
%    'images': a cell with each element is also a cell (this sub-cell
%        contains all DoG images in corresponding octave).
%
% -- output:
%
%    'derivative': derivative with respect to the 'arguments'.

arguments = sort(arguments);

img_scale = 1/(255*48);
derivative_scale = 1;%img_scale * 0.5;
second_derivative_scale = 1;%img_scale;
cross_derivative_scale = 1;%img_scale * 0.25;


switch arguments(1)
    case 0
        switch arguments(2)
            case 1 % dx
                image_tmp = images{coordinate(3)}{coordinate(4)};
                derivative = (image_tmp(coordinate(2),coordinate(1) + 1) - image_tmp(coordinate(2),coordinate(1) -1))/2;
                derivative = derivative * derivative_scale;
            case 2 % dy
                image_tmp = images{coordinate(3)}{coordinate(4)};
                derivative = (image_tmp(coordinate(2) + 1,coordinate(1)) - image_tmp(coordinate(2) - 1, coordinate(1)))/2;
                derivative = derivative * derivative_scale;
            case 3 % d sigma
                image_tmp_pre = images{coordinate(3)}{coordinate(4) - 1};
                image_tmp_next = images{coordinate(3)}{coordinate(4) + 1};
                derivative = (image_tmp_next(coordinate(2),coordinate(1)) - image_tmp_pre(coordinate(2),coordinate(1)))/2;
                derivative = derivative * derivative_scale;
            otherwise
                error('Illeagle input!');
        end
    case 1
        switch arguments(2)
            case 1 % dxx
                image_tmp = images{coordinate(3)}{coordinate(4)};
                derivative = image_tmp(coordinate(2),coordinate(1) + 1) - 2 * image_tmp(coordinate(2),coordinate(1)) + image_tmp(coordinate(2),coordinate(1) - 1);
                derivative = derivative * second_derivative_scale;
            case 2 % dxy
                image_tmp = images{coordinate(3)}{coordinate(4)};
                derivative = (image_tmp(coordinate(2) + 1,coordinate(1) + 1) + image_tmp(coordinate(2) - 1,coordinate(1) - 1) - image_tmp(coordinate(2) - 1,coordinate(1) + 1) - image_tmp(coordinate(2) + 1,coordinate(1) - 1))/4;
                derivative = derivative * cross_derivative_scale;
            case 3 % dx sigma
                image_tmp_pre = images{coordinate(3)}{coordinate(4) - 1};
                image_tmp_next = images{coordinate(3)}{coordinate(4) + 1};
                derivative = (image_tmp_next(coordinate(2),coordinate(1) + 1) + image_tmp_pre(coordinate(2),coordinate(1) - 1) - image_tmp_next(coordinate(2),coordinate(1) - 1) - image_tmp_pre(coordinate(2),coordinate(1) + 1))/4;
                derivative = derivative * cross_derivative_scale;
            otherwise
                error('Illeagle input!');
        end
        
    case 2
        switch arguments(2)
            case 2 % dyy
                image_tmp = images{coordinate(3)}{coordinate(4)};
                derivative = image_tmp(coordinate(2) + 1,coordinate(1)) - 2 * image_tmp(coordinate(2),coordinate(1)) + image_tmp(coordinate(2) - 1,coordinate(1));
                derivative = derivative * second_derivative_scale;
            case 3 % dy sigma
                image_tmp_pre = images{coordinate(3)}{coordinate(4) - 1};
                image_tmp_next = images{coordinate(3)}{coordinate(4) + 1};
                derivative = (image_tmp_next(coordinate(2) + 1,coordinate(1)) + image_tmp_pre(coordinate(2) - 1,coordinate(1)) - image_tmp_next(coordinate(2) - 1,coordinate(1)) - image_tmp_pre(coordinate(2) + 1,coordinate(1)))/4;
                derivative = derivative * cross_derivative_scale;
            otherwise
                error('Illeagle input!');
        end
        
    case 3
        switch arguments(2)
            case 3 % d sigma sigma
                image_tmp_pre = images{coordinate(3)}{coordinate(4) - 1};
                image_tmp_next = images{coordinate(3)}{coordinate(4) + 1};
                image_tmp = images{coordinate(3)}{coordinate(4)};
                derivative = image_tmp_next(coordinate(2),coordinate(1)) - 2 * image_tmp(coordinate(2),coordinate(1)) + image_tmp_pre(coordinate(2),coordinate(1));
                derivative = derivative * second_derivative_scale;
            otherwise
                error('Illeagle input!');
        end
        
    otherwise
        error('Illeagle inputs! ');
        
end

end