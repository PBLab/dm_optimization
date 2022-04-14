function plot_fitness(img_nums, fitness_vals)
%PLOT_FITNESS Summary of this function goes here
%   Detailed explanation goes here

%% plot
axes_fitness = getappdata(0,'axes_fitness');
stem(axes_fitness,img_nums,fitness_vals)

%prepare axis image
% setappdata(0,'axes_image_data',handles.axes_image_data);
% setappdata(0,'axes_image_best',handles.axes_image_best);
% setappdata(0,'axes_image_diff',handles.axes_image_diff);

end

