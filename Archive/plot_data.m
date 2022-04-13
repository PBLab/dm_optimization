function plot_data(img,current_fitness_val,img_num)
%function updates the current and best image displayed in the gui
%

global best_image 
global highest_fit_val

if img_num == 1
    setappdata(0,'highest_fit_val',-inf) ;
    setappdata(0,'best_image', img);
end

%decleare here persistent parameters
highest_fit_val =  getappdata(0,'highest_fit_val') ;
best_image = getappdata(0,'best_image');

%% store best score
if current_fitness_val>highest_fit_val
    setappdata(0,'highest_fit_val',current_fitness_val) ;
    setappdata(0,'best_image', img);
end

%get handle to plot (called axes_image_data)
%current image
h2_img = getappdata(0,'axes_image_data');
imagesc(h2_img,img)
axis(h2_img,'image')
colorbar(h2_img,'horizontal')
%best
h2_img = getappdata(0,'axes_image_best');
imagesc(h2_img,best_image)
axis(h2_img,'image')
colorbar(h2_img,'horizontal')
%diff
h2_img = getappdata(0,'axes_image_diff');
imagesc(h2_img,best_image-img)
axis(h2_img,'image')
colorbar(h2_img,'horizontal')
