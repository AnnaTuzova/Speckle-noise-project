clc;clear;close all;
addpath(genpath('filters'));
addpath(genpath('metrics'));   
addpath(genpath('filtering_images_and_tabel'));
addpath(genpath('pic'));
addpath(genpath('real images for testing filter'));

%% Загрузка изображений 
% image_noise = mat2gray((imread('radar_img.png')));
image_noise = [];
image = mat2gray(rgb2gray(imread('fig2.png')));
% image_noise = mat2gray(imread('C:\Data\NIR\Работа\SpeckleNoise_matlab\pic\NoFFT_Result_SAR.png'));
% CNN_image = mat2gray(rgb2gray(imread('D:\NIR\Работа\SpeckleNoise_matlab\pic\images after CNN\CNN_filt_img_ray_0.2707.png')));
%% Выбор настроек
distribution = 'Rayleigh'; %normal; Rayleigh; Rayleigh_correlated; 
type_of_plotting_and_save = 'no'; %%no - ничего не строить и не сохранять, 
%%only_plot - только построение
%%plot_and_save - построить и сохранить 
study_image_area = 'full_image'; %% full_image - исследуется изображение целиком
%%параметры только для тестового изображения fig2: fig2_small;
%%fig2_big; fig2_board
%%параметры для тестового изображения fig3: fig3_board_with_small_obj
title_type = 0; %%1; 0 - писать названия графиков или нет 
%% Наложение спекл-шума на изображение
if (isempty(image_noise))
    switch distribution
        case 'normal' 
            E = 0.3566; %%Нормальное распределение
            image_noise = add_speckle(image, distribution); 
            image_correct = image.*(1 + E);
            image_correct = max(min(image_correct,1),0);
        case 'Rayleigh'
            sigma = 0.2707; %%Рэлей
            image_noise = add_speckle(image, distribution); 
            image_correct = image.*(1 + sqrt(pi/2)*sigma);
            image_correct = max(min(image_correct,1),0);
        case 'Rayleigh_correlated'
            sigma = 0.2707; %%Рэлей
            image_noise = add_speckle(image, distribution);     
            image_correct = image.*(1 + sqrt(pi/2)*sigma);
            image_correct = max(min(image_correct,1),0);
    end
    
    switch type_of_plotting_and_save
        case 'plot_and_save'
            show_and_save_noisy_unnoisy_images(image, image_noise, distribution, title_type);
        case 'only_plot'
            show_noisy_unnoisy_images(image, image_noise, distribution);
    end      
end

%% Выбор области изображения, которое будет нарисовано и сохранено и для
%%него будут посчитаны метрики. Выбираем по столбцам и строкам. Для целого
%%изображения: (1:size(image,1),1:size(image,2))

%%Для тестового изображения fig2. Можно выделить локальные области.
%%идексы мелких объектов: (300:500,1:200);
%%индексы границы: (1:500,200:300);
%%индексы большого объекта: (200:400,300:500);        
switch study_image_area
    case 'full_image'       
        row_ind = 1:size(image,1); 
        col_ind = 1:size(image,2); 
    case 'fig2_small'
        row_ind = 300:500; 
        col_ind = 1:200; 
        name_of_object = 'small_obj';
        switch type_of_plotting_and_save
            case 'plot_and_save'
                show_and_save_obj_fig2_fig3(row_ind, col_ind, image, image_noise, distribution, name_of_object, title_type);
            case 'only_plot'
                show_obj_fig2_fig3(row_ind, col_ind, image, image_noise, distribution, name_of_object);
        end      
        
    case 'fig2_big'
        row_ind = 200:400; 
        col_ind = 300:500; 
        name_of_object = 'big_obj';
        switch type_of_plotting_and_save
            case 'plot_and_save'
                show_and_save_obj_fig2_fig3(row_ind, col_ind, image, image_noise, distribution, name_of_object, title_type);
            case 'only_plot'
                show_obj_fig2_fig3(row_ind, col_ind, image, image_noise, distribution, name_of_object);
        end  
    case 'fig3_board_with_small_obj'
        row_ind = 1:200; 
        col_ind = 200:300; 
        name_of_object = 'border_with_smal_obj';
         switch type_of_plotting_and_save
            case 'plot_and_save'
                show_and_save_obj_fig2_fig3(row_ind, col_ind, image, image_noise, distribution, name_of_object, title_type);
            case 'only_plot'
                show_obj_fig2_fig3(row_ind, col_ind, image, image_noise, distribution, name_of_object);
        end 
    case 'fig2_board'
        row_ind = 1:200; 
        col_ind = 150:350; 
        name_of_object = 'border';
        switch type_of_plotting_and_save
            case 'plot_and_save'
                show_and_save_obj_fig2_fig3(row_ind, col_ind, image, image_noise, distribution, name_of_object, title_type);
            case 'only_plot'
                show_obj_fig2_fig3(row_ind, col_ind, image, image_noise, distribution, name_of_object);
        end        
    
end
%% Параметры фильтров
switch distribution
    case 'normal'
        win_size_med = [15,15];
        win_size_Lee = [9,9];
        win_size_Frost = [11,11];
        win_size_Kuan = [13,13];
        win_size_MAP = [11,11];
        win_size_bilat = [17,17];
        
        damp_fact_Frost = 25; %%фильтр Фроста
        Kuan_fact = -0.1; %%фильтр Куана
        sig_d = 1; %%билатериальный фильтр
        sig_r = 1;
        
        %%анизотропная диффузия
        t_g1 = 10;
        k_g1 = 0.9;
        delta_t_g1 = 0.25;

        t_g2 = 10;
        k_g2 = 0.9;
        delta_t_g2 = 0.25;              

    case 'Rayleigh'      
        win_size_med = [15,15];
        win_size_Lee = [9,9];
        win_size_Frost = [13,13];
        win_size_Kuan = [15,15];
        win_size_MAP = [11,11];
        win_size_bilat = [15,15];

        damp_fact_Frost = 14;
        Kuan_fact = -0.1;
        sig_d = 5;
        sig_r = 1;    

        %%анизотропная диффузия
        t_g1 = 10;
        k_g1 = 0.9;
        delta_t_g1 = 0.25;

        t_g2 = 10;
        k_g2 = 0.9;
        delta_t_g2 = 0.25;          
              
        
    case 'Rayleigh_correlated'
        win_size_med = [17,17];
        win_size_Lee = [9,9];
        win_size_Frost = [13,13];
        win_size_Kuan = [11,11];
        win_size_MAP = [11,11];
        win_size_bilat = [7,7];
        
        damp_fact_Frost = 9;
        Kuan_fact = 0.1;
        sig_d = 70;
        sig_r = 1; 
        
        %%анизотропная диффузия
        t_g1 = 10;
        k_g1 = 0.9;
        delta_t_g1 = 0.25;

        t_g2 = 10;
        k_g2 = 0.9;
        delta_t_g2 = 0.25;          

end     

%% Фильтрация
ENL_win = [25,25];
%%ENL 
[~, ENL_med] = ENL(image_noise, ENL_win);
%%Медианная фильтрация
med_filt_img = median_filter(win_size_med,image_noise);
med_filt_img = med_filt_img(row_ind,col_ind);

%%Фильтр Ли
Lee_filt_img = Lee_filter(win_size_Lee, image_noise);
Lee_filt_img = Lee_filt_img(row_ind,col_ind);

%%Фильтр Фроста
Frost_filt_img = Frost_filter(win_size_Frost,image_noise,damp_fact_Frost);
Frost_filt_img = Frost_filt_img(row_ind,col_ind);

%%Фильтр Куана
Kuan_filt_img = Kuan_filter(win_size_Kuan, image_noise, ENL_med, Kuan_fact);
Kuan_filt_img = Kuan_filt_img(row_ind,col_ind);

%%Gamma MAP
gamma_MAP_filt_img = Gamma_MAP_filter(win_size_MAP, image_noise, ENL_med);
gamma_MAP_filt_img = gamma_MAP_filt_img(row_ind,col_ind);

%%bilateral_filter 
bilateral_filt_img = bilateral_filter(win_size_bilat, image_noise, sig_d, sig_r);
bilateral_filt_img = bilateral_filt_img(row_ind,col_ind);

%%Анизотропная диффузия
anisotropic_diffusion_filt_img_g1 = anisotropic_diffusion(image_noise, t_g1, delta_t_g1, k_g1, 1);
anisotropic_diffusion_filt_img_g1 = anisotropic_diffusion_filt_img_g1(row_ind,col_ind);

anisotropic_diffusion_filt_img_g2 = anisotropic_diffusion(image_noise, t_g2, delta_t_g2, k_g2, 2);
anisotropic_diffusion_filt_img_g2 = anisotropic_diffusion_filt_img_g2(row_ind,col_ind);
%% Построение и сохранение рисунков
switch type_of_plotting_and_save
    case 'no'
        disp('Warning: images are not displayed or saved');
    case 'only_plot'
        %%median filter
        med_fig = figure('Name', 'Median Filter');
        imshow(padarray(med_filt_img,[1,1],0));
        title('Медианный фильтр, ' + string(win_size_med(1)) + '\times' + string(win_size_med(2)));
        
        %%Lee filter
        Lee_fig = figure('Name', 'Lee Filter');
        imshow(padarray(Lee_filt_img,[1,1],0));
        title('Фильтр Ли, ' + string(win_size_Lee(1)) + '\times' + string(win_size_Lee(2)));
        
        %%Frost filter
        Frost_fig = figure('Name', 'Frost Filter');
        imshow(padarray(Frost_filt_img,[1,1],0));
        title('Фильтр Фроста при D = ' + string(damp_fact_Frost) + ', ' + string(win_size_Frost(1)) + '\times' + string(win_size_Frost(2)));
       
        %%Kuan filter
        Kuan_fig = figure('Name', 'Kuan Filter');
        imshow(padarray(Kuan_filt_img,[1,1],0));
        title('Фильтр Куана при A = ' + string(Kuan_fact)+ ', ' + string(win_size_Kuan(1)) + '\times' + string(win_size_Kuan(2)));
        
        %%MAP filter
        MAP_fig = figure('Name', 'MAP Filter');
        imshow(padarray(gamma_MAP_filt_img,[1,1],0));
        title('MAP фильтр, ' + string(win_size_MAP(1)) + '\times' + string(win_size_MAP(2)));
        
        %%bilaterial filter
        bilat_fig = figure('Name', 'Bilaterial Filter');
        imshow(padarray(bilateral_filt_img,[1,1],0));
        title('Билатеральный фильтр при \sigma_r^2 = ' + string(sig_r) +...
           ' и \sigma_d^2 = ' + string(sig_d) + ', ' + string(win_size_bilat(1)) + '\times' + string(win_size_bilat(2)));
        
       %%anisotropic diffusion
        anisotrop_g1_fig = figure('Name', 'Anisotrop Diffusion Filter with exp g(x)');
        imshow(padarray(anisotropic_diffusion_filt_img_g1,[1,1],0));
        title('Анизотропная диффузия при экспоненциальной g(x), t = ' + string(t_g1) + ', k = ' + string(k_g1) + ', \Deltat = ' + string(delta_t_g1));
        
        anisotrop_g2_fig = figure('Name', 'Anisotrop Diffusion Filter with quadratic g(x)');
        imshow(padarray(anisotropic_diffusion_filt_img_g2,[1,1],0));
        title('Анизотропная диффузия при квадратичной g(x), t = ' + string(t_g2) + ', k = ' + string(k_g2) + ', \Deltat = ' + string(delta_t_g2));
       
    case 'plot_and_save'
        %%median filter
        med_fig = figure('Name', 'Median Filter');
        imshow(padarray(med_filt_img,[1,1],0));
        if (title_type == 1)
            set(gcf, 'Units', 'Normalized', 'OuterPosition', [0, 0.04, 1, 0.96]);
            title('Медианный фильтр, ' + string(win_size_med(1)) + '\times' + string(win_size_med(2)));
        end
        med_filename = strcat('filtering_images_and_tabel\2_',distribution,'_',...
            '_median_filter_', string(win_size_med(1)),'x',string(win_size_med(2)),...
            '_area_',study_image_area,'.png');
        print(med_fig, med_filename,'-dpng','-r500');  
        
        %%Lee filter
        Lee_fig = figure('Name', 'Lee Filter');
        imshow(padarray(Lee_filt_img,[1,1],0));
        if (title_type == 1)
            set(gcf, 'Units', 'Normalized', 'OuterPosition', [0, 0.04, 1, 0.96]);
            title('Фильтр Ли, ' + string(win_size_Lee(1)) + '\times' + string(win_size_Lee(2)));
        end
        Lee_filename = strcat('filtering_images_and_tabel\3_',distribution,'_',...
            '_Lee_filter_', string(win_size_Lee(1)),'x',string(win_size_Lee(2)),...
            '_area_',study_image_area,'.png');
        print(Lee_fig, Lee_filename,'-dpng','-r500');  
        
        %%Frost filter
        Frost_fig = figure('Name', 'Frost Filter');
        imshow(padarray(Frost_filt_img,[1,1],0));
        if (title_type == 1)
            set(gcf, 'Units', 'Normalized', 'OuterPosition', [0, 0.04, 1, 0.96]);
            title('Фильтр Фроста при D = ' + string(damp_fact_Frost) + ', ' + string(win_size_Frost(1)) + '\times' + string(win_size_Frost(2)));
        end
        Frost_filename = strcat('filtering_images_and_tabel\4_',distribution,'_',...
            '_Frost_filter_with_D_',string(damp_fact_Frost),'_', string(win_size_Frost(1)),'x',string(win_size_Frost(2)),...
            '_area_',study_image_area,'.png');
        print(Frost_fig, Frost_filename,'-dpng','-r500');  
        
        %%Kuan filter
        Kuan_fig = figure('Name', 'Kuan Filter');
        imshow(padarray(Kuan_filt_img,[1,1],0));
        if (title_type == 1)
            set(gcf, 'Units', 'Normalized', 'OuterPosition', [0, 0.04, 1, 0.96]);
            title('Фильтр Куана при A = ' + string(Kuan_fact)+ ', ' + string(win_size_Kuan(1)) + '\times' + string(win_size_Kuan(2)));
        end
        Kuan_filename = strcat('filtering_images_and_tabel\5_',distribution,'_',...
            '_Kuan_filter_with_A_',string(Kuan_fact),'_', string(win_size_Kuan(1)),'x',string(win_size_Kuan(2)),...
            '_area_',study_image_area,'.png');
        print(Kuan_fig, Kuan_filename,'-dpng','-r500');  
        
        %%bilaterial filter
        bilat_fig = figure('Name', 'Bilaterial Filter');
        imshow(padarray(bilateral_filt_img,[1,1],0));
        if (title_type == 1)
            set(gcf, 'Units', 'Normalized', 'OuterPosition', [0, 0.04, 1, 0.96]);
            title('Билатеральный фильтр при \sigma_r^2 = ' + string(sig_r) +...
           ' и \sigma_d^2 = ' + string(sig_d) + ', ' + string(win_size_bilat(1)) + '\times' + string(win_size_bilat(2)));
        end
        bilat_filename = strcat('filtering_images_and_tabel\6_',distribution,'_',...
            '_bilat_filter_with_sigma_r_',string(sig_r),'_and_sigma_d_',string(sig_d),...
            '_',string(win_size_bilat(1)),'x',string(win_size_bilat(2)),...
            '_area_',study_image_area,'.png');
        print(bilat_fig, bilat_filename,'-dpng','-r500');  
        
        %%MAP filter
        MAP_fig = figure('Name', 'MAP Filter');
        imshow(padarray(gamma_MAP_filt_img,[1,1],0));
        if (title_type == 1)
            set(gcf, 'Units', 'Normalized', 'OuterPosition', [0, 0.04, 1, 0.96]);
            title('MAP фильтр, ' + string(win_size_MAP(1)) + '\times' + string(win_size_MAP(2)));
        end
        MAP_filename = strcat('filtering_images_and_tabel\7_',distribution,'_',...
            '_MAP_filter_', string(win_size_MAP(1)),'x',string(win_size_MAP(2)),...
            '_area_',study_image_area,'.png');
        print(MAP_fig, MAP_filename,'-dpng','-r500'); 
        
        %%anisotropic diffusion
        anisotrop_g1_fig = figure('Name', 'Anisotrop Diffusion Filter with exp g(x)');
        imshow(padarray(anisotropic_diffusion_filt_img_g1,[1,1],0));
        if (title_type == 1)
            set(gcf, 'Units', 'Normalized', 'OuterPosition', [0, 0.04, 1, 0.96]);
            title('Анизотропная диффузия при экспоненциальной g(x), t = ' + string(t) + ', k = ' + string(k) + ', \Deltat = ' + string(delta_t));
        end
        anisotrop_g1_filename = strcat('filtering_images_and_tabel\8_',distribution,'_',...
            '_anisotrop_filter_with_g_1_t_',string(t_g1),...
            '_k_',string(k_g1),'_delta_t_',string(delta_t_g1),...
            '_area_',study_image_area,'.png');
        print(anisotrop_g1_fig, anisotrop_g1_filename,'-dpng','-r500');  
        
        anisotrop_g2_fig = figure('Name', 'Anisotrop Diffusion Filter with quadratic g(x)');
        imshow(padarray(anisotropic_diffusion_filt_img_g2,[1,1],0));
        if (title_type == 1)
            set(gcf, 'Units', 'Normalized', 'OuterPosition', [0, 0.04, 1, 0.96]);
            title('Анизотропная диффузия при квадратичной g(x), t = ' + string(t) + ', k = ' + string(k) + ', \Deltat = ' + string(delta_t));
        end
        anisotrop_g2_filename = strcat('filtering_images_and_tabel\9_',distribution,'_',...
            '_anisotrop_filter_with_g_2_t_',string(t_g2),...
            '_k_',string(k_g2),'_delta_t_',string(delta_t_g2),...
            '_area_',study_image_area,'.png');
        print(anisotrop_g2_fig, anisotrop_g2_filename,'-dpng','-r500');  
end

%% 1D срезы
plotting_slices = 0; %% 1; 0

if (plotting_slices == 1)
    slice_selection = 0.55; %% В какой части изображения мы хотим срез
    image_local = image(row_ind,col_ind);
    sigma = 0.2707; 
    image_local_correct = image_local.*(1 + sqrt(pi/2)*sigma);
    image_local_correct = max(min(image_local_correct,1),0);
    image_local_noise = image_noise(row_ind,col_ind);
    indices = 1:1:size(image_local,2);
    slice_row = round(size(image_local,1)*slice_selection);
    up_coeff = 0.1;
    
	d1_slice = figure('Name', '1D clices');
    set(gcf, 'Units', 'Normalized', 'OuterPosition', [0, 0.04, 1, 0.96]);
    subplot(1,2,1)
    imshow(padarray(image_local_correct,[1,1],0))
    hold on
    plot(indices,slice_row.*ones(length(indices)),'-r','LineWidth',2)
    title('Изображение без шума с обозначением линии среза')
    subplot(1,2,2)
% % %     color_line = hsv(10*5);
    plot(indices,image_local_correct(slice_row,:),'-k','LineWidth', 2)
    hold on
    plot(indices,image_local_noise(slice_row,:),'-c','LineWidth', 0.6)
    plot(indices,med_filt_img(slice_row,:)+ up_coeff,'.-r')
    plot(indices,Lee_filt_img(slice_row,:) + up_coeff*2,'.-','color', [0.93, 0.69, 0.13])
    plot(indices,Frost_filt_img(slice_row,:)+ up_coeff*3,'.-','color', [0, 0.5, 0])
    plot(indices,Kuan_filt_img(slice_row,:)+ up_coeff*4,'.-b')
    plot(indices,gamma_MAP_filt_img(slice_row,:)+ up_coeff*5,'.-m')
    plot(indices,bilateral_filt_img(slice_row,:)+ up_coeff*6,'.-','color', [0, 0.5, 0.5])
    plot(indices,anisotropic_diffusion_filt_img_g1(slice_row,:)+ up_coeff*7,'.-g')
    plot(indices,anisotropic_diffusion_filt_img_g2(slice_row,:)+ up_coeff*8,'.-', 'color', [0.6, 0.2, 0])
    
    grid on; xlabel('Индексы пикселей вдоль cреза'); ylabel('Значения интенсивности пикселей вдоль среза');
%     title('1D срезы изображений после фильтрации')
    % xlabel('Pixel indices along the slice'); ylabel('Pixel intensity values along the slice'); 
    % legend('Noise free image','Noise image', 'Image after Frost filter');
    legend('Незашумленное изображение','Изображение с шумом','Медианный фильтр', 'Фильтр Ли', 'Фильтр Фроста','Фильтр Куана', 'MAP фильтр', 'Билатериальный фильтр',...
        'Фильтр анизотр. диффузии при эксп. g(x)','Фильтр анизотр. диффузии при квадр. g(x)')
    legend('Location', 'best')
    axis([0 length(col_ind) -0.1 (1 + up_coeff*10)])
    
    d1_slice_filename = strcat('filtering_images_and_tabel\10_1d_slice_',...
        distribution,'_area_',study_image_area,'.png');
    print(d1_slice, d1_slice_filename,'-dpng','-r500');  
end

%% SSIM 
image = image(row_ind,col_ind);
image_noise = image_noise(row_ind,col_ind);
image_correct = image_correct(row_ind,col_ind);

ssim_no_filt = ssim(image_noise,image_correct);

ssim_median = ssim(med_filt_img,image_correct);
ssim_Lee = ssim(Lee_filt_img,image_correct);
ssim_Frost = ssim(Frost_filt_img,image_correct);
ssim_Kuan = ssim(Kuan_filt_img,image_correct);
ssim_gamma_MAP = ssim(gamma_MAP_filt_img,image_correct);
ssim_bilateral = ssim(bilateral_filt_img,image_correct);
ssim_anisotrop_g1 = ssim(anisotropic_diffusion_filt_img_g1,image_correct);
ssim_anisotrop_g2 = ssim(anisotropic_diffusion_filt_img_g2,image_correct);

%% таблица метрик
table_metric = table({'No filter';'median';'Lee';'Frost';'Kuan';'bilateral';'gamma_MAP';'anisotropic diffusion exp g';'anisotropic diffusion quad g'},...
    [ssim_no_filt;ssim_median;ssim_Lee;ssim_Frost;ssim_Kuan;ssim_bilateral;ssim_gamma_MAP;ssim_anisotrop_g1;ssim_anisotrop_g2])
table_metric.Properties.VariableNames = {'Filters' 'SSIM'}
table_name = strcat('filtering_images_and_tabel\',distribution,'_area_',study_image_area,'metric_table.csv');
writetable(table_metric,table_name);
