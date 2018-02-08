function [image_original, image_pro] = cylinder_projection(image_path, imagesID)
% CYLINDER_PROJECTION: this function project an image to cylinder surface.
%
% -- input:
%    image_path: the path of the image that need to be projected.
%    imagesID: the id of images that used for 360 panorama
%
% -- output:
%    image_original: the image read from 'image_path'.
%    image_pro£ºthe projected image.

%image_path = './data/images1/100NIKON-DSCN0008_DSCN0008.JPG';

image_original = imread(image_path);
if imagesID == 1
    image_original = imrotate(image_original,90);% for images1 in data
end
image_size = size(image_original);
im_w = image_size(2);
im_h = image_size(1);

pad = 2;% pad the original image to obtain a better projected image.
if length(size(image_original)) == 3
    image_pad = zeros(im_h+2*pad, im_w+2*pad,3);% RGB image
else
    image_pad = zeros(im_h+2*pad, im_w+2*pad); % gray image
end
image_pad(pad+1:pad+im_h, pad+1:pad+im_w,:) = image_original;

image_info = imfinfo(image_path);
image_focal_length = image_info.DigitalCamera.FocalLength;

if imagesID == 1
    Wccd = 4.8;% images1
elseif imagesID == 2
    Wccd = 6.4; % images2
elseif imagesID == 3
    Wccd = 3.690; % images3
end

cylinder_r = im_h * image_focal_length / Wccd;
theta = 2*atan(im_w/(2*cylinder_r));

im_w_pro = round(2 * cylinder_r*sin(theta/2));
im_h_pro = im_h;

if length(size(image_original)) == 3
    image_pro = zeros([im_h_pro, im_w_pro, 3]);
else
    image_pro = zeros([im_h_pro, im_w_pro]);
end

for collum = 1:im_w_pro
    for row = 1:im_h_pro
        x = im_w/2 + cylinder_r * tan(asin((collum - cylinder_r*sin(theta/2))/cylinder_r));
        y = im_h/2 + (row - im_h_pro/2)* sqrt(cylinder_r^2 + (im_w/2 - x)^2)/cylinder_r;
        
        %                 if x >= 1 && x <= im_w && y >= 1 && y <= im_h
        %                     image_pro(row,collum,:) = image_original(round(y),round(x),:);
        %                 end
        
        % bilinear interpolation
        if x >= 0 && x <= im_w+1 && y >= 0 && y <= im_h+1
            if mod(x,1) == 0 || mod(y,1) == 0
                if mod(x,1) == 0 && mod(y,1)==0
                    image_pro(row,collum,:) = image_pad(y,x,:);
                elseif mod(x,1) == 0 && mod(y,1)~=0
                    y1 = floor(y);
                    y2 = ceil(y);
                    pixel1 = image_pad(y1+pad,x+pad,:) * (y2-y) /(y2-y1);
                    pixel2 = image_pad(y2+pad,x+pad,:) * (y-y1) /(y2-y1);
                    image_pro(row,collum,:) = pixel1+ pixel2;
                elseif mod(x,1) ~= 0 && mod(y,1)==0
                    x1 = floor(x);
                    x2 = ceil(x);
                    pixel1 = image_pad(y+pad,x1+pad,:) * (x2-x) /(x2-x1);
                    pixel2 = image_pad(y+pad,x2+pad,:) * (x-x1) /(x2-x1);
                    image_pro(row,collum,:) = pixel1+ pixel2;
                end
            else
                x1 = floor(x);
                x2 = ceil(x);
                y1 = floor(y);
                y2 = ceil(y);
                pixel11 = image_pad(y1+pad,x1+pad,:) * ((x2 -x)*(y2-y)) / ((x2-x1)*(y2-y1));
                pixel21 = image_pad(y1+pad,x2+pad,:) * ((x -x1)*(y2-y)) / ((x2-x1)*(y2-y1));
                pixel12 = image_pad(y2+pad,x1+pad,:) * ((x2 -x)*(y-y1)) / ((x2-x1)*(y2-y1));
                pixel22 = image_pad(y2+pad,x2+pad,:) * ((x -x1)*(y-y1)) / ((x2-x1)*(y2-y1));
                image_pro(row,collum,:) = pixel11+ pixel21 + pixel12 + pixel22;
            end
        end
    end
end
image_pro = uint8(image_pro);
% imshow(image_pro);
% imwrite(image_pro,'./results/figure/2.2_middle.JPG')
end