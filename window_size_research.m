clc; clear all; close all;
addpath(genpath('filters'));
addpath(genpath('metrics'));
addpath(genpath('pic'));
%% Параметры фильтров
damp_fact_frost = 8.5;
fact_kuan = 0.1;
sig_d_bil = 19;
sig_r_bil = 1;

%% Загрузка изображений 
image = mat2gray(rgb2gray(imread('fig2.png')));
%% Наложение шума
distribution = 'Rayleigh'; %normal; Rayleigh; Rayleigh_correlated
    switch distribution
        case 'normal' 
            E = 0.3566; %%Нормальное распределение
            D = 0.0201; 
            image_noise = add_speckle(image, distribution); 
            image_correct = image.*(1 + E);
            image_correct = max(min(image_correct,1),0);
            mat_filename = strcat('research results\window_',distribution,'_',num2str(D),'.mat');
            plot_filename = strcat('graphics\window_',distribution,'_',num2str(D),'.png');
        case 'Rayleigh'
            sigma = 0.2707; %%Рэлей
            image_noise = add_speckle(image, distribution); 
            image_correct = image.*(1 + sqrt(pi/2)*sigma);
            image_correct = max(min(image_correct,1),0);
            mat_filename = strcat('research results\window_',distribution,'_',num2str(sigma),'.mat');
            plot_filename = strcat('graphics\window_',distribution,'_',num2str(sigma),'.png');
        case 'Rayleigh_correlated'
            sigma = 0.2707; %%Рэлей
            image_noise = add_speckle(image, distribution); 
            image_correct = image.*(1 + sqrt(pi/2)*sigma);
            image_correct = max(min(image_correct,1),0);
            mat_filename = strcat('research results\window_',distribution,'_',num2str(sigma),'.mat');
            plot_filename = strcat('graphics\window_',distribution,'_',num2str(sigma),'.png');
    end

%% Исследование размера окна
ENL_win = [25,25];
[~, ENL_med] = ENL(image_noise, ENL_win);
win_var = 3:2:40;
ssim_median = [];ssim_Lee = [];ssim_Frost = [];ssim_Kuan = [];ssim_gamma_MAP = [];ssim_bilateral = [];

for i = win_var
    win_size = [i,i]; 
    %%filtering
    med_filt_img = median_filter(win_size,image_noise);
    Lee_filt_img = Lee_filter(win_size, image_noise);
    Frost_filt_img = Frost_filter(win_size,image_noise,damp_fact_frost);
    Kuan_filt_img = Kuan_filter(win_size, image_noise, ENL_med, fact_kuan);
    gamma_MAP_filt_img = Gamma_MAP_filter(win_size, image_noise, ENL_med);
    bilateral_filt_img = bilateral_filter(win_size, image_noise, sig_d_bil, sig_r_bil);
    %%metrics
    ssim_median = [ssim_median ssim(med_filt_img,image_correct)];
    ssim_Lee = [ssim_Lee ssim(Lee_filt_img,image_correct)];
    ssim_Frost = [ssim_Frost ssim(Frost_filt_img,image_correct)];
    ssim_Kuan = [ssim_Kuan ssim(Kuan_filt_img,image_correct)];
    ssim_gamma_MAP = [ssim_gamma_MAP ssim(gamma_MAP_filt_img,image_correct)];
    ssim_bilateral = [ssim_bilateral ssim(bilateral_filt_img,image_correct)];
   
    disp(i)
end

%% оптимальные значения
ssim_median_param = [max(ssim_median) win_var(ssim_median == max(ssim_median))];
ssim_Lee_param = [max(ssim_Lee) win_var(ssim_Lee == max(ssim_Lee))];
ssim_Frost_param = [max(ssim_Frost) win_var(ssim_Frost == max(ssim_Frost))];
ssim_Kuan_param = [max(ssim_Kuan) win_var(ssim_Kuan == max(ssim_Kuan))];
ssim_gamma_MAP_param = [max(ssim_gamma_MAP) win_var(ssim_gamma_MAP == max(ssim_gamma_MAP))];
ssim_bilateral_param = [max(ssim_bilateral) win_var(ssim_bilateral == max(ssim_bilateral))];

save(mat_filename);
%% Построение графиков
window_SSIM_fig = figure('Name', 'SSIM');
% plotting(win_var,ssim_median, ssim_Lee, ssim_Frost, ssim_Kuan, ssim_gamma_MAP,ssim_bilateral,...
%  ssim_median_param, ssim_Lee_param, ssim_Frost_param, ssim_Kuan_param, ssim_gamma_MAP_param, ssim_bilateral_param)

% print(window_SSIM_fig, plot_filename,'-dpng','-r500');  

% function plotting(win_var,met_median, met_Lee, met_Frost, met_Kuan, met_gamma_MAP,met_window,...
%  met_median_param, met_Lee_param, met_Frost_param, met_Kuan_param, met_gamma_MAP_param, met_bilateral_param)
    
%     color_line = hsv(14);
%     plot(win_var,met_median,'.-', 'color', color_line(1,:), 'LineWidth', 1.5, 'MarkerSize', 8)
    
%     plot(win_var,met_Lee,'.-', 'color', color_line(3,:), 'LineWidth', 1.5, 'MarkerSize', 8)
    
%     plot(win_var,met_Kuan,'.-', 'color', color_line(7,:), 'LineWidth', 1.5, 'MarkerSize', 8)
%     plot(win_var,met_gamma_MAP,'.-', 'color', color_line(9,:), 'LineWidth', 1.5, 'MarkerSize', 8)
%     plot(win_var,met_window,'.-', 'color', color_line(11,:), 'LineWidth', 1.5, 'MarkerSize', 8)
    %%оптимальные значения
%     plot(met_median_param(2), met_median_param(1), '*','color', color_line(14,:))
%     plot(met_Lee_param(2), met_Lee_param(1), '*','color', color_line(14,:))
    stem(ssim_Frost_param(2), ssim_Frost_param(1), '*r','LineWidth',1.5)
    hold on
    plot(win_var,ssim_Frost,'.-k', 'LineWidth', 1.5, 'MarkerSize', 15)
    text(ssim_Frost_param(2),ssim_Frost_param(1), ['(' num2str(ssim_Frost_param(2)) '; ' num2str(ssim_Frost_param(1)) ')'])
%     plot(met_Kuan_param(2), met_Kuan_param(1), '*','color', color_line(14,:))
%     plot(met_gamma_MAP_param(2), met_gamma_MAP_param(1), '*','color', color_line(14,:))
%     plot(met_bilateral_param(2), met_bilateral_param(1), '*','color', color_line(14,:))
    grid on; xlabel('Window side size'); 
%     ax = gca; ax.FontSize = 12;
%     legend('медианный фильтр','фильтр Ли','фильтр Фроста','фильтр Куана','MAP фильтр','билатериальный фильтр','оптимальные значения метрики')
legend('Maximum metric value')
ylabel('SSIM');
axis([0 40 0.9 1])
% end