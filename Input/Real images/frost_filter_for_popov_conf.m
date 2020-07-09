clc;clear;close all;
addpath(genpath('..\'));
%% Тестирование фильтра Фроста на реальных изображениях для доклада на конференцию Попова
num_of_image = 5;
distribution = 'Rayleigh';
win_size = [11,11];
damp_fact = 3;
border = round((win_size-1)/2);

mse_no_filt = zeros(1,num_of_image);
ssim_no_filt = zeros(1,num_of_image);

mse_var = zeros(1,num_of_image);
ssim_var = zeros(1,num_of_image);

for k = 1:num_of_image
  %%загрузка изображений
  jpg_filename = strcat(num2str(k), '.png');
  image_grayscale = mat2gray(rgb2gray(imread(jpg_filename)));
  image_with_border = padarray(image_grayscale,border,1);
  
  image_noise = add_speckle(image_grayscale, distribution); 
  filt_image = Frost_filter(win_size,image_noise,damp_fact);
  
  %%метрики
  mse_no_filt(k) = MSE(image_grayscale, image_noise);
  ssim_no_filt(k) = ssim(image_grayscale, image_noise);
  
  mse_var(k) = MSE(image_with_border, filt_image);
  ssim_var(k) = ssim(filt_image, image_with_border);
  
  %%Изображение в ЧБ
  image_grayscale_filename = strcat('E:\ATuzova\Работа\SpeckleNoise_matlab\real images for testing filter\',...
      num2str(k), '_gray.png');
  imwrite(image_grayscale,image_grayscale_filename)
  
  %%Изображение с шумом
  image_noise_filename = strcat('E:\ATuzova\Работа\SpeckleNoise_matlab\real images for testing filter\',...
      num2str(k), '_noise.png');
  imwrite(image_noise,image_noise_filename)
  
  %%Изображение после фильтра
  filt_image_filename = strcat('E:\ATuzova\Работа\SpeckleNoise_matlab\real images for testing filter\',...
      num2str(k), '_filter_', num2str(damp_fact),'_', num2str(win_size(1)),'x', num2str(win_size(2)),'.png');
  imwrite(filt_image,filt_image_filename)
  
  disp(k)
end

%% Таблица
row_names = arrayfun(@num2str,1:num_of_image,'uni',0);
table_metric = table([mse_no_filt'],[mse_var'],[ssim_no_filt'],[ssim_var'],...
        'VariableNames',{'MSE_without_filt','MSE','SSIM_without_filt','SSIM'})
table_metric.Properties.RowNames = row_names
  
