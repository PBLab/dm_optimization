function [ img_normed ] = normalize_image( img )
%NORMALIZE_IMAGE Takes an integer \ negative image, and returns a new image
%in the range of [0, 1]
img_min = img - min(img(:));
img_normed = img_min / (max(img_min(:)));


end

