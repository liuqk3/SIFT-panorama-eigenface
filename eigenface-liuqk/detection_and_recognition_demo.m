clear;
close all;
addpath('./util');
data_type = 'smiling';
face_p = ['./data/class_images/' data_type '_cropped/'];
face_mtr = faces2matrix(face_p);
[~, show_face_origin] = display_images(face_mtr);

if ~ exist(['./results/' data_type])
   mkdir(['./results/' data_type]); 
end

imwrite(show_face_origin, ['./results/' data_type '/origin_face.jpg']);

%% compute and show eigneface
[face_mtr_norm, dataset_mu] = centerlize_data(face_mtr);% normalize the images
[eigenfaces, ~, engivalue] = pca(face_mtr_norm);
[~, show_face_eig] = display_images(abs(eigenfaces)');
imwrite(show_face_eig, [ './results/' data_type '/eigenface.jpg']);

%% project a face image into the face space
face_project = face_mtr_norm * eigenfaces;
face_rec = face_project * eigenfaces';
face_rec = bsxfun(@plus, face_rec, dataset_mu);
[~, show_face_rec] = display_images(face_rec);
imwrite(show_face_rec, ['./results/' data_type '/face_rec.jpg']);

%%  face detection
im_path =  ['./data/class_images/group/' data_type '/'];
ims = dir([im_path, '*tga']);
for im_index = 1:1%length(ims)
    
    fprintf('----------- Processing %dth images-----------\n',im_index);
    
    im_name = [im_path, ims(im_index).name];
    im_tmp = tga_read_image(im_name);
    [face_coordinates, distance_detect, recognition] = detection(im_tmp, face_mtr, eigenfaces);
      
    imwrite(im_tmp, ['./results/' data_type '/' num2str(im_index) '.jpg']);
    save(['./results/' data_type '/' num2str(im_index) '_face_coordinates.mat'],'face_coordinates');
    save(['./results/' data_type '/' num2str(im_index) '_distance_detect.mat'],'distance_detect');
    save(['./results/' data_type '/' num2str(im_index) '_recognition.mat'],'recognition');
end







