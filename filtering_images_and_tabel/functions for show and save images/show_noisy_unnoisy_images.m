function show_noisy_unnoisy_images(image, image_noise, distribution)

figure('Name', 'Image without noise');
imshow(padarray(image,[1,1],0)); title('Незашумленное изображение');

figure('Name', 'Image with noise');
imshow(padarray(image_noise,[1,1],0));

switch distribution
    case 'normal'
        D = 0.0201;
        title('Изображение со спекл-шумом с нормальным распределением, \sigma^2 = ' + string(D));
    case 'Rayleigh'
        sigma = 0.2707; 
        title('Изображение со спекл-шумом с распределением Рэлея, \sigma = ' + string(sigma));
    case 'uniform'
        title('Изображение со спекл-шумом с равномерным распределением, \sigma^2 = ' + string(var));
    case 'Rayleigh_correlated'
        title('Изображение с пространственно-коррелированным спекл-шумом с распределением Рэлея');
    case 'Rayleigh_uncorrelated'
        title('Изображение с пространственно-некоррелированным спекл-шумом с распределением Рэлея');
end  
           
end