clear;
close all;
addpath('./SIFT-liuqk');
imagesID = 1;% 1£¬2 or 3
data_path = ['./data/images' num2str(imagesID) '/'];
images = dir([data_path '*JPG']);
images_projection = {};% used to store the cylinder projected images successively
shift = [];% used to store the shift between neighbouring cylinder projected images

%% compute the cylinder projected images and the shift between neighbouring images
for i =length(images):-1:1%length(images)-2
    image_path = [data_path images(i).name];
    if i == length(images)
        [~, image_pro] = cylinder_projection(image_path, imagesID);
        images_projection = [images_projection,{image_pro}];
        % extract SIFT feature
        image_sift = sift_panorama(image_pro);
        image_sift_pre = image_sift;
    else
        [~, image_pro] = cylinder_projection(image_path, imagesID);
        images_projection = [images_projection,{image_pro}];
        % extract SIFT feature
        image_sift = sift_panorama(image_pro);
        
        % match
        show_matched_results = 0;
        [matches, distance] = sift_match_panorama(image_sift_pre, image_sift, show_matched_results);
        
        % obtain the shift of neighbouring pairs using RANSAC
        [x_shift, y_shift] = ransac_for_shift(matches, image_sift_pre, image_sift);
        shift = [shift; [x_shift, y_shift]];
        
        image_sift_pre = image_sift;
    end
end

result_path = ['./results/result' num2str(imagesID)];
if ~exist(result_path)
    mkdir(result_path);
end
    
save([result_path '/images_projection.mat'],'images_projection');
save([result_path '/shift.mat'],'shift');

%% correct drift
shift = correct_drift(images_projection, shift);

%% stitch images
for image_pro_index = length(images_projection):-1:1%length(images_projection)-1%1
    if image_pro_index == length(images_projection)
        stitch_image = images_projection{image_pro_index};
    else
        image_pro_pre = images_projection{image_pro_index};
        shift_tmp = shift(image_pro_index,:);
        stitch_image = stitch_images(image_pro_pre,stitch_image,shift_tmp);
    end
end
imwrite(stitch_image,[result_path '/stitch_image.JPG']);
figure();
imshow(stitch_image);

%% crope
crop_stitch_image = stitch_image(70:(size(stitch_image,1) - 60),:,:);
imwrite(crop_stitch_image,[result_path '/stitch_image_cropped.JPG']);
figure();
imshow(crop_stitch_image);

