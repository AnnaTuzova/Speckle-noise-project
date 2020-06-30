clc; clear all;
img = load('out_numpy.csv');
new_img = img.*0.5+0.5;
norm_img = (new_img-min(new_img(:)))./(max(new_img(:))-min(new_img(:)));
subplot(1,2,1)
imshow(new_img)
title('Изображение до нормализации [0,1]')
subplot(1,2,2)
imshow(norm_img)
title('Изображение после нормализации [0,1]')