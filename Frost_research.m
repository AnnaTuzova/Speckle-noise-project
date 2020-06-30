clc; clear all; close all;
addpath(genpath('filters'));
addpath(genpath('metrics'));
addpath(genpath('pic'));
%% Загрузка изображений 
image = mat2gray(rgb2gray(imread('fig2.png')));
%% Параметры фильтра
win_size = [13,13]; % Size of window 

%% Наложение шума
distribution = 'Rayleigh_correlated'; %normal; Rayleigh; Rayleigh_correlated
    switch distribution
        case 'normal' 
            E = 0.3566; %%Нормальное распределение
            D = 0.0201; 
            image_noise = add_speckle(image, distribution); 
            image_correct = image.*(1 + E);
            image_correct = max(min(image_correct,1),0);
            mat_filename = strcat('research results\frost_',distribution,'_',...
                num2str(D),'_',num2str(win_size(1)),'x',num2str(win_size(2)),'.mat');
            plot_filename = strcat('graphics\frost_',distribution,'_',...
                num2str(D),'_',num2str(win_size(1)),'x',num2str(win_size(2)),'.png');
        case 'Rayleigh'
            sigma = 0.2707; %%Рэлей
            image_noise = add_speckle(image, distribution); 
            image_correct = image.*(1 + sqrt(pi/2)*sigma);
            image_correct = max(min(image_correct,1),0);
            mat_filename = strcat('research results\frost_',distribution,'_',...
                num2str(sigma),'_',num2str(win_size(1)),'x',num2str(win_size(2)),'.mat');
            plot_filename = strcat('graphics\frost_',distribution,'_',...
                num2str(sigma),'_',num2str(win_size(1)),'x',num2str(win_size(2)),'.png');
        case 'Rayleigh_correlated'
            sigma = 0.2707; %%Рэлей
            image_noise = add_speckle(image, distribution); 
            image_correct = image.*(1 + sqrt(pi/2)*sigma);
            image_correct = max(min(image_correct,1),0);
            mat_filename = strcat('research results\frost_',distribution,'_',...
                num2str(sigma),'_',num2str(win_size(1)),'x',num2str(win_size(2)),'.mat');
            plot_filename = strcat('graphics\frost_',distribution,'_',...
                num2str(sigma),'_',num2str(win_size(1)),'x',num2str(win_size(2)),'.png');
    end

%% Исследование параметра фильтра Фроста
damp_fact_var = 0:0.5:25;
ssim_frost_var = zeros([1, length(damp_fact_var)]);

for i = 1:length(damp_fact_var)
    filt_image_frost = Frost_filter(win_size,image_noise,damp_fact_var(i));
  
    ssim_frost_var(i) = ssim(filt_image_frost, image_correct);
    disp(i)
end

%% Поиск минимальных значений параметра фильтра Фроста
ssim_param = [max(ssim_frost_var) damp_fact_var(ssim_frost_var == max(ssim_frost_var))];
save(mat_filename);
%% Построение графиков параметров фильтра Фроста
frost_SSIM_fig = figure('Name', 'ssim');
stem(ssim_param(1,2),ssim_param(1,1), 'r*','LineWidth',1.5)
text(ssim_param(1,2),ssim_param(1,1), ['(' num2str(ssim_param(1,2)) '; ' num2str(ssim_param(1,1)) ')'])
hold on
plot(damp_fact_var,ssim_frost_var,'.-k','LineWidth',1.5, 'MarkerSize', 15)
xlabel('D'); ylabel('SSIM'); grid on;
axis([0 25 0.94 1])
legend('Maximum metric value');
print(frost_SSIM_fig, plot_filename,'-dpng','-r500');  
