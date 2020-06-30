clc; clear all; close all;
addpath(genpath('filters'));
addpath(genpath('metrics'));
addpath(genpath('pic'));
%% Загрузка изображений 
image = mat2gray(rgb2gray(imread('fig2.png')));
%% Параметры фильтра
win_size = [7,7]; % Size of window 
%% Наложение шума
distribution = 'Rayleigh_correlated'; %normal; Rayleigh; Rayleigh_correlated
    switch distribution
        case 'normal' 
            E = 0.3566; %%Нормальное распределение
            D = 0.0201; 
            image_noise = add_speckle(image, distribution); 
            image_correct = image.*(1 + E);
            image_correct = max(min(image_correct,1),0);
            mat_filename = strcat('research results\bilat_',distribution,'_',...
                num2str(D),'_',num2str(win_size(1)),'x',num2str(win_size(2)),'.mat');
            plot_filename = strcat('graphics\bilat_',distribution,'_',...
                num2str(D),'_',num2str(win_size(1)),'x',num2str(win_size(2)),'.png');
        case 'Rayleigh'
            sigma = 0.2707; %%Рэлей
            image_noise = add_speckle(image, distribution); 
            image_correct = image.*(1 + sqrt(pi/2)*sigma);
            image_correct = max(min(image_correct,1),0);
            mat_filename = strcat('research results\bilat_',distribution,'_',...
                num2str(sigma),'_',num2str(win_size(1)),'x',num2str(win_size(2)),'.mat');
            plot_filename = strcat('graphics\bilat_',distribution,'_',...
                num2str(sigma),'_',num2str(win_size(1)),'x',num2str(win_size(2)),'.png');
        case 'Rayleigh_correlated'
            sigma = 0.2707; %%Рэлей
            image_noise = add_speckle(image, distribution); 
            image_correct = image.*(1 + sqrt(pi/2)*sigma);
            image_correct = max(min(image_correct,1),0);
            mat_filename = strcat('research results\bilat_',distribution,'_',...
                num2str(sigma),'_',num2str(win_size(1)),'x',num2str(win_size(2)),'.mat');
            plot_filename = strcat('graphics\bilat_',distribution,'_',...
                num2str(sigma),'_',num2str(win_size(1)),'x',num2str(win_size(2)),'.png');
    end

%% Исследование параметров билатериального фильтра
sig_r = [1:2:15]; %%biger
sig_d = 1:2:70; %%smaller

ssim_bi = zeros([length(sig_r), length(sig_d)]);

for i = 1:length(sig_r)
    disp('i = '); disp(i);
    for j = 1:length(sig_d)
        filt_img = bilateral_filter(win_size, image_noise, sig_d(j), sig_r(i));
        
        ssim_bi(i,j) = ssim(filt_img, image_correct);
        disp('j = '); disp(j);
    end
end

%% Поиск оптимальных значений параметров 
[ssim_r, ssim_c] = find(ssim_bi == max(max(ssim_bi)));
ssim_param = [max(max(ssim_bi)) sig_d(ssim_c)];
save(mat_filename);
%% Построение графиков
bilat_SSIM_fig = figure('Name', 'ssim');
plotting(sig_r, sig_d, ssim_bi, ssim_param)
xlabel('\sigma_d^2'); ylabel('SSIM');
% axis([0 50 0.835 0.85])
print(bilat_SSIM_fig, plot_filename,'-dpng','-r500');  

function plotting(sig_r, sig_d, metric_matrix, metric_param)
    color_line = hsv(2*(length(sig_r) + 1));
    for k = 1:length(sig_r)
        plot(sig_d,metric_matrix(k,:),'.-', 'color', color_line(2*k,:),'LineWidth', 1.5, 'MarkerSize', 8)
        hold on;
        legend_names{k} = ['\sigma_r^2 = ' num2str(sig_r(k))]; 
    end
    ax = gca; ax.FontSize = 12;
    grid on;
    stem(metric_param(1,2),metric_param(1,1), '*','color', color_line(end,:),'LineWidth',1.5)
    legend_names = [legend_names 'Оптимальное значение метрики'];
    legend(legend_names)       
    legend('Location', 'bestoutside')
end
