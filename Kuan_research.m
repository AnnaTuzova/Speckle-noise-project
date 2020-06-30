clc; clear all; close all;
addpath(genpath('filters'));
addpath(genpath('metrics'));
addpath(genpath('pic'));
%% Загрузка изображений 
image = mat2gray(rgb2gray(imread('fig2.png')));

%% Параметры фильтра
win_size = [11,11]; % Size of window 

%% Наложение шума
distribution = 'Rayleigh_correlated'; %normal; Rayleigh; Rayleigh_correlated
    switch distribution
        case 'normal' 
            E = 0.3566; %%Нормальное распределение
            D = 0.0201; 
            image_noise = add_speckle(image, distribution); 
            image_correct = image.*(1 + E);
            image_correct = max(min(image_correct,1),0);
            mat_filename = strcat('research results\kuan_',distribution,'_',...
                num2str(D),'_',num2str(win_size(1)),'x',num2str(win_size(2)),'.mat');
            plot_filename = strcat('graphics\kuan_',distribution,'_',...
                num2str(D),'_',num2str(win_size(1)),'x',num2str(win_size(2)),'.png');
        case 'Rayleigh'
            sigma = 0.2707; %%Рэлей
            image_noise = add_speckle(image, distribution); 
            image_correct = image.*(1 + sqrt(pi/2)*sigma);
            image_correct = max(min(image_correct,1),0);
            mat_filename = strcat('research results\kuan_',distribution,'_',...
                num2str(sigma),'_',num2str(win_size(1)),'x',num2str(win_size(2)),'.mat');
            plot_filename = strcat('graphics\kuan_',distribution,'_',...
                num2str(sigma),'_',num2str(win_size(1)),'x',num2str(win_size(2)),'.png');
        case 'Rayleigh_correlated'
            sigma = 0.2707; %%Рэлей
            image_noise = add_speckle(image, distribution); 
            image_correct = image.*(1 + sqrt(pi/2)*sigma);
            image_correct = max(min(image_correct,1),0);
            mat_filename = strcat('research results\kuan_',distribution,'_',...
                num2str(sigma),'_',num2str(win_size(1)),'x',num2str(win_size(2)),'.mat');
            plot_filename = strcat('graphics\kuan_',distribution,'_',...
                num2str(sigma),'_',num2str(win_size(1)),'x',num2str(win_size(2)),'.png');
    end

%% Исследование коэффициента fact и выбора ENL для фильтра Куана 
ENL_win = [25,25];
%%ENL 
[~, ENL_med] = ENL(image_noise, ENL_win);
fact_var = -0.9:0.2:5;

ssim_kuan_medEML = zeros([1, length(fact_var)]);

for i = 1:length(fact_var)
    filt_image_kuan_ENLmed = Kuan_filter(win_size, image_noise, ENL_med, fact_var(i));
    
    ssim_kuan_medEML(i) = ssim(filt_image_kuan_ENLmed,image_correct);   
    disp(i)
end

%% Поиск минимальных значений параметра фильтра Куана
%%ssim
ssim_param = [max(ssim_kuan_medEML) fact_var(ssim_kuan_medEML == max(ssim_kuan_medEML))];
save(mat_filename);

%% Построение графиков параметров фильтра Куана
kuan_SSIM_fig = figure('Name', 'ssim');
stem(ssim_param(1,2),ssim_param(1,1), 'r*','LineWidth',1.5)
hold on
plot(fact_var,ssim_kuan_medEML,'.-k','LineWidth',1.5, 'MarkerSize', 15)
xlabel('A'); ylabel('SSIM'); grid on;
% axis([-5 35 0.035 0.055])
legend('Максимальное значение метрики');
print(kuan_SSIM_fig, plot_filename,'-dpng','-r500');  

 