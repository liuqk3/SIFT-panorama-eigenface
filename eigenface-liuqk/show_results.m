close all;
clear;

data_type = 'nonsmiling';

num_images = 7;
for im_index = 1:num_images
    im_path = ['./results/' data_type '/' num2str(im_index) '.jpg'];
    im_tmp = imread(im_path);
    figure();
    imshow(im_tmp);
    
    load(['./results/' data_type '/' num2str(im_index) '_face_coordinates.mat']);
    load(['./results/' data_type '/' num2str(im_index) '_recognition.mat']);
    load(['./results/' data_type '/' num2str(im_index) '_distance_detect.mat']);
    
    [face_coordinates, recognition,distance_detect] = filter_face(face_coordinates, recognition,distance_detect);
    
    for i = 1:min(3, size(face_coordinates,1))
        hold on;
        %color = rand(1,3);
        color = 'green';
        rectangle('Position',face_coordinates(i,:),'edgecolor',color);
        text(face_coordinates(i,1) - 5,face_coordinates(i,2) - 5,num2str(recognition(i,1)),'color',color);
    end
end