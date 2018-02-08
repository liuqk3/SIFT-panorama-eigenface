function face_mtr = faces2matrix(face_path)
% FACES2MATRIX: this function organizes faces into a matrix.
%
% -- input:
%    faces_path: a cell, each element in it is a string (path) for some
%        faces.
%    sz: 1x 2 vector, all face images will be resized to sz.
%
% -- output:
%    face_mtr: a matrix, each row in it is a resized image. We should note
%        that all rows in a image stitched together will produce a row
%        vector in face_mtr.
%
sz = [50, 50];
face_mtr = [];

faces = dir([face_path, '*tga']);
num_faces = length(faces);
face_mtr_tmp = zeros(num_faces, sz(1)*sz(2));
% figure();
for i = 1:num_faces
    face_name = [face_path faces(i).name];
    face_tmp = tga_read_image(face_name);
    face_tmp = rgb2gray(face_tmp);
    face_tmp = imresize(face_tmp, sz);
    %face_tmp = face_tmp';
    face_mtr_tmp(i,:) = face_tmp(:)';
end
face_mtr = [face_mtr; face_mtr_tmp];



end