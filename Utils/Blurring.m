%Blurring the image and see the different fitness values I can get from
%that

load('image_try.mat','image_try');
fitness_0 = fitnessFun(image_try);
figure
image(image_try);

fitness_g1 = fitnessFun(imgaussfilt(image_try,10));
figure
image(imgaussfilt(image_try,10));

fitness_g2 = fitnessFun(imgaussfilt(image_try,1));
figure
image(imgaussfilt(image_try,1));


 