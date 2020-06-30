function show_and_save_noisy_unnoisy_images(image, image_noise, distribution, title_type)

img_fig = figure('Name', 'Image without noise');
imshow(padarray(image,[1,1],0)); 
if (title_type == 1)
    title('Незашумленное изображение');
    set(gcf, 'Units', 'Normalized', 'OuterPosition', [0, 0.04, 1, 0.96]);
end
img_filename = strcat('filtering_images_and_tabel\','0_imgage_without_noise.png');
print(img_fig, img_filename,'-dpng','-r500');  

noise_fig = figure('Name', 'Image with noise');
imshow(padarray(image_noise,[1,1],0));
if (title_type == 1)
    set(gcf, 'Units', 'Normalized', 'OuterPosition', [0, 0.04, 1, 0.96]);
end

switch distribution
    case 'normal'
        D = 0.0201;
        if (title_type == 1)
            title('Изображение со спекл-шумом с нормальным распределением, \sigma^2 = ' + string(D));
        end
        noise_filename = strcat('filtering_images_and_tabel\','1_noise_img_with_',...
            distribution,'_dist_',string(D),'.png');
    case 'Rayleigh'
        sigma = 0.2707; 
        if (title_type == 1)
            title('Изображение со спекл-шумом с распределением Рэлея, \sigma = ' + string(sigma));
        end    
        noise_filename = strcat('filtering_images_and_tabel\','1_noise_img_with_',...
            distribution,'_dist_',string(sigma),'.png');
    case 'Rayleigh_correlated'
        if (title_type == 1)
            title('Изображение с пространственно-коррелированным спекл-шумом с распределением Рэлея');
        end
        noise_filename = strcat('filtering_images_and_tabel\','1_noise_img_with_',...
            distribution,'_dist.png');
    case 'Rayleigh_uncorrelated'
        if (title_type == 1)
            title('Изображение с пространственно-некоррелированным спекл-шумом с распределением Рэлея');
        end
        noise_filename = strcat('filtering_images_and_tabel\','1_noise_img_with_',...
            distribution,'_dist.png');
end  

print(noise_fig, noise_filename,'-dpng','-r500');  
            
end