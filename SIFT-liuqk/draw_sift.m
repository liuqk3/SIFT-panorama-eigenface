function draw_sift(image, keypoints, angle_interval, show_sift_type)
% DRAW_SIFT: This function plots SIFT keypoints on the detected image.
%
% -- iput:
%
%    'image': detected iamge.
%
%    'keypoints': a N x 4 matrix with one row corresponding to a keypoint.
%        and each row has four elements (x, y, angle, magnitude). The
%        'magnitude' is normalized.
%
%    'angle_interval': the interval to divide 2*pi, which is used to
%        compute the main angle of keypoints.
%
%    'show_sift_type': string, it can be '+', '*', 'o', 'arrow' and so on,
%        which determin the label to show the keypoint.
%
figure();
imshow(image);
for point =1:size(keypoints,1)
    hold all;
    one_keypoint = keypoints(point,:);
    if strcmp(show_sift_type,'arrow')
        angle = one_keypoint(3)*angle_interval;
        dx = one_keypoint(4) * cos(angle) /20;% * 50;
        dy = one_keypoint(4) * sin(angle) /20;% * 50;
        end_point_x = one_keypoint(1)+round(dx);
        end_point_y = one_keypoint(2)+round(dy);
        
        % plot the line
        plot([one_keypoint(1), end_point_x], [one_keypoint(2), end_point_y],'Color','cyan','LineWidth',2);
        
        %plot the arrow
        angle1 = pi + angle - pi/6;
        angle2 = pi + angle + pi/6;
        arrow_edge_length = 6;
        arrow_point1_x = end_point_x + arrow_edge_length * cos(angle1);
        arrow_point1_y = end_point_y + arrow_edge_length * sin(angle1);
        arrow_point2_x = end_point_x + arrow_edge_length * cos(angle2);
        arrow_point2_y = end_point_y + arrow_edge_length * sin(angle2);
        plot([arrow_point1_x, end_point_x], [arrow_point1_y, end_point_y],'Color','cyan','LineWidth',2);
        plot([arrow_point2_x, end_point_x], [arrow_point2_y, end_point_y],'Color','cyan','LineWidth',2);
    else%if strcmp(show_sift_type,'+')
        plot(round(one_keypoint(1)),round(one_keypoint(2)),show_sift_type, 'Color','Cyan','markersize',6);
    end
end

end