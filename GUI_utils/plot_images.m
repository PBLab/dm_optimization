function plot_images(prev_img,curr_img)
%PLOT_IMAGES Summary of this function goes here
%   Detailed explanation goes here


axes_image_data = getappdata(0,'axes_image_data');
axes_image_best = getappdata(0,'axes_image_best');
axes_image_diff = getappdata(0,'axes_image_diff');

imagesc(axes_image_data,prev_img);
imagesc(axes_image_best,curr_img);
imagesc(axes_image_diff,prev_img-curr_img);

map = hot(256);

axis(axes_image_data,'off');
axis(axes_image_best,'off');
axis(axes_image_diff,'off');

colormap(axes_image_data,'gray')
colormap(axes_image_best,'gray')
colormap(axes_image_best,map)