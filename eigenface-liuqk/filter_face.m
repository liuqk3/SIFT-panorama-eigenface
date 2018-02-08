function  [face_coor_f, face_reco_f,dist_detect_f] = filter_face(face_coordinates, recognition,dist_detect)
% FILTER_FACE: this funtion choose one of the rois that matched to the same
% face accoding to their match distance. And the roi has the closest
% distance will be chosen.

% -- iutput:
%    face_coordinates: a N x 4 matrix, and each row in it is the coordinate
%        and size of a detected face. (x, y, width, height), where the
%        (x,y) is the coordinate of the top left corner.
%    dist_detect: N x 1 matrix, the distance between the croped roi 
%        (rectangle of interesting) and its reconstruct 'face'.
%    recognition: N x 2 matrix, each row in it is the match face in dataset
%        and the corresponding distance.
%
% -- output:
%    face_coor_f: a N x 4 matrix, and each row in it is the coordinate
%        and size of a detected face. (x, y, width, height), where the
%        (x,y) is the coordinate of the top left corner. And it is the
%        filtered version of 'face_coordinates'.
%    dist_detect_f: N x 1 matrix, the distance between the croped roi 
%        (rectangle of interesting) and its reconstruct 'face'. And it is
%        the filtered version of 'dist_detect'.
%    face_reco_f: N x 2 matrix, each row in it is the match face in dataset
%        and the corresponding distance. And it is the filtered version of
%        'recognition'.
%
% Please refer to function 'detection.m' for more information.

face_coor_f = [];
face_reco_f = [];
dist_detect_f = [];
reco_label = unique(recognition(:,1));
for i = 1:length(reco_label)
   index = find(recognition(:,1) == reco_label(i)); 
   
   face_coor_tmp = face_coordinates(index,:);
   face_reco_tmp = recognition(index,:);
   dist_detect_tmp = dist_detect(index,:);
   
   reco_dist_tmp = recognition(index,2);
   
   index = find(reco_dist_tmp == min(reco_dist_tmp));
   face_coor_f = [face_coor_f;face_coor_tmp(index,:)];
   face_reco_f = [face_reco_f;face_reco_tmp(index,:)];
   dist_detect_f = [dist_detect_f;dist_detect_tmp(index,:)];
end

%sort the faces according to their recognition distance
[~, index] = sort(face_reco_f(:,2));
face_coor_f = face_coor_f(index,:);
face_reco_f = face_reco_f(index,:);
dist_detect_f = dist_detect_f(index,:);
end