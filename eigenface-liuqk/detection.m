function [face_detect_coor, dist_detect, recognition] = detection(image, dataset, eigenfaces)

% DETECTION: this function detect and recognize a face in a image.
% -- inout:
%    image: the image need to be detected, gray or RGB.
%    dataset: the face dataset. And the faces in 'image' should be
%        contained in the 'dataset'.
%    eigenface: the eigenface of 'dataset' obtained by PCA. Although we can
%        directly obtained from 'dataste', we still treat is as an input
%        argument to speed up the algorithm.
% -- output:
%    face_detect_coor: a N x 4 matrix, and each row in it is the coordinate
%        and size of a detected face. (x, y, width, height), where the
%        (x,y) is the coordinate of the top left corner.
%    dist_detect: N x 1 matrix, the distance between the croped roi (rectangle of
%        interesting) and its reconstruct 'face'.
%    recognition: N x 2 matrix, each row in it is the match face in dataset
%        and the corresponding distance.


face_detect_coor = [];
dist_detect = [];
recognition = [];
sz = [50, 50];% all roi will be resize to sz
search_window_initial = [35, 35];%[35, 35]; % the initial search window size, [width, height]
step_size = 5;% the step to tune the size of search window.
stride = 4;% search stride
thr_det = 0.24;%0.23;%0.2;%0.19; % thresehold to determin wether a roi is a face
thr_reco = 0.21;%0.23;%0.25;%0.210;%0.2;
% preprocess dataset
[dataset_centerlize, dataset_mu] = centerlize_data(dataset);
dataset_construct = dataset_centerlize * eigenfaces * eigenfaces';
% rgb image to gray image
if length(size(image)) == 3
    image =  rgb2gray(image);
end
image = double(image);
im_sz = size(image);
for i = 1:7 %search size from [10 10] to [80 80]
    search_window = search_window_initial + (i - 1) * [step_size step_size];
    fprintf(' Search window size: [%d, %d]\n', search_window(1), search_window(2));
    x = 1;
    while x+search_window(1) - 1 < im_sz(2)
        y = 1;
        while y+search_window(2) - 1 < im_sz(1)
            xs = x:x+search_window(1) - 1;
            ys = y:y+search_window(2) - 1;
            roi_origin = image(ys, xs);
            
            % PCA to determin whther this roi contain a face
            roi_resize = imresize(roi_origin, sz);
            roi_vector = roi_resize(:)';
            roi_centerlize = bsxfun(@minus, roi_vector, dataset_mu);% centerlize
            roi_project = roi_centerlize * eigenfaces;
            
            % reconstruct the roi
            recon = roi_project * eigenfaces';
            
            self_error = sum(abs(recon - roi_centerlize)) / sum(roi_vector);
            
            if self_error < thr_det% this roi contain a face
                
                % recognintion
                reco_dist = bsxfun(@minus, dataset_construct, recon);
                reco_dist = sum(abs(reco_dist),2) / sum(roi_vector);
                %reco_dist = sum(abs(reco_dist),2) / (sz(1)*sz(2));
                [reco_dist, reco_error_idx] = sort(reco_dist);

                if reco_dist(1) < thr_reco
                    fprintf('minmum recognition distance: %f \n',reco_dist(1));
                    
                    coordinate_tmp = [xs(1), ys(1), search_window(1), search_window(2)];
                    face_detect_coor = [face_detect_coor;coordinate_tmp];
                    
                    dist_detect = [dist_detect; self_error];
                    recognition = [recognition; [reco_error_idx(1),reco_dist(1)]];
                end
            end
            y = y + stride;
        end
        x = x + stride;
    end
end

% sort the patches according to their detected distance
[~, index] = sort(dist_detect);
recognition = recognition(index,:);
dist_detect = dist_detect(index,:);
face_detect_coor = face_detect_coor(index,:);

end