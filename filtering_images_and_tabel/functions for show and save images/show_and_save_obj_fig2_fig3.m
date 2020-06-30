function show_and_save_obj_fig2_fig3(row_ind, col_ind, image, image_noise, distribution, name_of_object, title_type)
D = 0.0201; sigma = 0.2707; 
%%without noise
fig_obj_without_noise = figure('Name', 'Objects wihout noise');
imshow(padarray(image(row_ind,col_ind),[1,1],0)); 
if (title_type == 1)
    set(gcf, 'Units', 'Normalized', 'OuterPosition', [0, 0.04, 1, 0.96]);
end

switch name_of_object
    case 'small_obj'
        if (title_type == 1)
            title('Маленькие объекты без наложения шума');
        end
        fig_obj_without_noise_filename = strcat('filtering_images_and_tabel\',...
        '0_fig2_small_objects_without_noise.png');
    case 'big_obj'
        if (title_type == 1)
            title('Большой объект без наложения шума');
        end
        fig_obj_without_noise_filename = strcat('filtering_images_and_tabel\','0_fig2_big_object_without_noise.png');
    case 'border'
        if (title_type == 1)
            title('Граница без наложения шума');
        end
        fig_obj_without_noise_filename = strcat('filtering_images_and_tabel\','0_fig2_board_without_noise.png');
    case 'border_with_smal_obj'
        if (title_type == 1)
            title('Граница с мелкими объектами около нее без наложения шума');
        end
        fig_obj_without_noise_filename = strcat('filtering_images_and_tabel\','0_fig3_board_with_small_obj_without_noise.png');
end

print(fig_obj_without_noise, fig_obj_without_noise_filename,'-dpng','-r500'); 

%%with noise
fig_obj_with_noise = figure('Name', 'Objects wih noise');
imshow(padarray(image_noise(row_ind,col_ind),[1,1],0)); 
if (title_type == 1)
    set(gcf, 'Units', 'Normalized', 'OuterPosition', [0, 0.04, 1, 0.96]);
end

switch name_of_object
    case 'small_obj'
        switch distribution
            case 'normal'  
                if (title_type == 1)
                    title('Маленькие объекты со спекл-шумом с нормальным распределением, \sigma^2 = ' + string(D));
                end
                fig_obj_with_noise_filename = strcat('filtering_images_and_tabel\','1_fig2_noise_small_object_with_',...
                    distribution,'_dist_',string(D),'.png');
            case 'Rayleigh'
                if (title_type == 1)
                    title('Маленькие объекты со спекл-шумом с распределением Рэлея, \sigma = ' + string(sigma));
                end
                fig_obj_with_noise_filename = strcat('filtering_images_and_tabel\','1_fig2_noise_small_objects_with_',...
                    distribution,'_dist_',string(sigma),'.png');
            case 'Rayleigh_correlated'
                if (title_type == 1)
                    title('Маленькие объекты с пространственно-коррелированным спекл-шумом с распределением Рэлея');
                end
                fig_obj_with_noise_filename = strcat('filtering_images_and_tabel\','1_fig2_noise_small_objects_with_',...
                    distribution,'_dist.png');
            case 'Rayleigh_uncorrelated'
                if (title_type == 1)
                    title('Маленькие объекты с пространственно-некоррелированным спекл-шумом с распределением Рэлея');
                end
                fig_obj_with_noise_filename = strcat('filtering_images_and_tabel\','1_fig2_noise_small_objects_with_',...
                    distribution,'_dist.png');
        end  
    case 'big_obj'
        switch distribution
            case 'normal'
                if (title_type == 1)
                    title('Больщой объект со спекл-шумом с нормальным распределением, \sigma^2 = ' + string(D));
                end
                fig_obj_with_noise_filename = strcat('filtering_images_and_tabel\','1_fig2_noise_big_object_with_',...
                    distribution,'_dist_',string(D),'.png');
            case 'Rayleigh'
                if (title_type == 1)
                    title('Больщой объект со спекл-шумом с распределением Рэлея, \sigma = ' + string(sigma));
                end
                fig_obj_with_noise_filename = strcat('filtering_images_and_tabel\','1_fig2_noise_big_object_with_',...
                    distribution,'_dist_',string(sigma),'.png');
            case 'Rayleigh_correlated'
                if (title_type == 1)
                    title('Больщой объект с пространственно-коррелированным спекл-шумом с распределением Рэлея');
                end
                fig_obj_with_noise_filename = strcat('filtering_images_and_tabel\','1_fig2_noise_big_object_with_',...
                    distribution,'_dist.png');
            case 'Rayleigh_uncorrelated'
                if (title_type == 1)
                    title('Больщой объект с пространственно-некоррелированным спекл-шумом с распределением Рэлея');
                end
                fig_obj_with_noise_filename = strcat('filtering_images_and_tabel\','1_fig2_noise_big_object_with_',...
                    distribution,'_dist.png');
        end 
    case 'border'
        switch distribution
            case 'normal'
                if (title_type == 1)
                    title('Граница со спекл-шумом с нормальным распределением, \sigma^2 = ' + string(D));
                end
                fig_obj_with_noise_filename = strcat('filtering_images_and_tabel\','1_fig2_noise_board_with_',...
                    distribution,'_dist_',string(D),'.png');
            case 'Rayleigh'
                if (title_type == 1)
                    title('Граница со спекл-шумом с распределением Рэлея, \sigma = ' + string(sigma));
                end
                fig_obj_with_noise_filename = strcat('filtering_images_and_tabel\','1_fig2_noise_board_with_',...
                    distribution,'_dist_',string(sigma),'.png');
            case 'Rayleigh_correlated'
                if (title_type == 1)
                    title('Граница с пространственно-коррелированным спекл-шумом с распределением Рэлея');
                end
                fig_obj_with_noise_filename = strcat('filtering_images_and_tabel\','1_fig2_noise_board_with_',...
                    distribution,'_dist.png');
            case 'Rayleigh_uncorrelated'
                if (title_type == 1)
                    title('Граница с пространственно-некоррелированным спекл-шумом с распределением Рэлея');
                end
                fig_obj_with_noise_filename = strcat('filtering_images_and_tabel\','1_fig2_noise_board_with_',...
                    distribution,'_dist.png');
        end    
    case 'border_with_smal_obj'
        switch distribution
            case 'normal'
                if (title_type == 1)
                    title('Граница с мелкими объектами около нее со спекл-шумом с нормальным распределением, \sigma^2 = ' + string(D));
                end
                fig_obj_with_noise_filename = strcat('filtering_images_and_tabel\','1_fig3_noise_board_with_small_obj_with_',...
                    distribution,'_dist_',string(D),'.png');
            case 'Rayleigh'
                if (title_type == 1)
                    title('Граница с мелкими объектами около нее со спекл-шумом с распределением Рэлея, \sigma = ' + string(sigma));
                end
                fig_obj_with_noise_filename = strcat('filtering_images_and_tabel\','1_fig3_noise_board_with_small_obj_with_',...
                    distribution,'_dist_',string(sigma),'.png');
            case 'Rayleigh_correlated'
                if (title_type == 1)
                    title('Граница с мелкими объектами около нее с пространственно-коррелированным спекл-шумом с распределением Рэлея');
                end
                fig_obj_with_noise_filename = strcat('filtering_images_and_tabel\','1_fig3_noise_board_with_small_obj_with_',...
                    distribution,'_dist.png');
            case 'Rayleigh_uncorrelated'
                if (title_type == 1)
                    title('Граница с мелкими объектами около нее с пространственно-некоррелированным спекл-шумом с распределением Рэлея');
                end
                fig_obj_with_noise_filename = strcat('filtering_images_and_tabel\','1_fig3_noise_board_with_small_obj_with_',...
                    distribution,'_dist.png');
        end                 
end

print(fig_obj_with_noise, fig_obj_with_noise_filename,'-dpng','-r500');  
            
end