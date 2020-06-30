clc; clear all; close all;
addpath(genpath('filters'));
addpath(genpath('metrics'));
addpath(genpath('pic'));
%% Загрузка изображений 
image = mat2gray(rgb2gray(imread('fig2.png')));
 %% Параметры фильтра
var_type = 'k_and_delta_t'; %%k_and_delta_t; t
g_type = 1;
%% Наложение шума
distribution = 'Rayleigh_correlated'; %normal; Rayleigh; Rayleigh_correlated
    switch distribution
        case 'normal' 
            E = 0.3566; %%Нормальное распределение
            D = 0.0201; 
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


%% Исследование параметров
switch var_type
    case 'k_and_delta_t'
        t_const = 26;
        k_var = 0.1:0.1:1; 
        delta_t_var = 0:0.01:0.25; 
        
        ssim_var = zeros([length(k_var), length(delta_t_var)]);

    switch distribution
        case 'normal' 
            D = 0.0201; 
            mat_filename = strcat('research results\anisotrop_g',num2str(g_type),'_',...
                distribution,'_',num2str(D),'_k_delt_at_t_',num2str(t_const),'.mat');
            plot_filename = strcat('graphics\anisotrop_g',num2str(g_type),'_',...
                distribution,'_',num2str(D),'_k_delt_at_t_',num2str(t_const),'.png');
        case 'Rayleigh'
            sigma = 0.2707; %%Рэлей
            mat_filename = strcat('research results\anisotrop_g',num2str(g_type),'_',...
                distribution,'_',num2str(sigma),'_k_delt_at_t_',num2str(t_const),'.mat');
            plot_filename = strcat('graphics\anisotrop_g',num2str(g_type),'_',...
                distribution,'_',num2str(sigma),'_k_delt_at_t_',num2str(t_const),'.png');
        case 'Rayleigh_correlated'
            sigma = 0.2707; %%Рэлей
            mat_filename = strcat('research results\anisotrop_g',num2str(g_type),'_',...
                distribution,'_',num2str(sigma),'_k_delt_at_t_',num2str(t_const),'.mat');
            plot_filename = strcat('graphics\anisotrop_g',num2str(g_type),'_',...
                distribution,'_',num2str(sigma),'_k_delt_at_t_',num2str(t_const),'.png');
    end
                
        for i = 1:length(k_var)
            disp('i = '); disp(i);
            for j = 1:length(delta_t_var)
               anisotrop_gfilt_img = anisotropic_diffusion(image_noise, t_const, delta_t_var(j), k_var(i), g_type);
                ssim_var(i,j) = ssim(anisotrop_gfilt_img, image_correct);

                disp('j = '); disp(j);
            end
        end
        
    case 't'
        t_var = 1:1:50;
        k_const = 0.1; 
        delta_t_const = 0.25; 

        ssim_var = zeros([1, length(t_var)]);

    switch distribution
        case 'normal' 
            D = 0.0201; 
            mat_filename = strcat('research results\anisotrop_gg',num2str(g_type),'_',...
                distribution,'_',num2str(D),'_t_at_k_', num2str(k_const),'_delt_', num2str(delta_t_const),'.mat');
            plot_filename = strcat('graphics\anisotrop_g',num2str(g_type),'_',...
                distribution,'_',num2str(D),'_t_at_k_', num2str(k_const),'_delt_', num2str(delta_t_const),'.png');
        case 'Rayleigh'
            sigma = 0.2707; %%Рэлей
            mat_filename = strcat('research results\anisotrop_g',num2str(g_type),'_',...
                distribution,'_',num2str(sigma),'_t_at_k_', num2str(k_const),'_delt_', num2str(delta_t_const),'.mat');
            plot_filename = strcat('graphics\anisotrop_g',num2str(g_type),'_',...
                distribution,'_',num2str(sigma),'_t_at_k_', num2str(k_const),'_delt_', num2str(delta_t_const),'.png');
        case 'Rayleigh_correlated'
            sigma = 0.2707; %%Рэлей
            mat_filename = strcat('research results\anisotrop_g',num2str(g_type),'_',...
                distribution,'_',num2str(sigma),'_t_at_k_', num2str(k_const),'_delt_', num2str(delta_t_const),'.mat');
            plot_filename = strcat('graphics\anisotrop_g',num2str(g_type),'_',...
                distribution,'_',num2str(sigma),'_t_at_k_', num2str(k_const),'_delt_', num2str(delta_t_const),'.png');
    end
        
        for i = 1:length(t_var)
            disp('i = '); disp(i);
            anisotrop_gfilt_img = anisotropic_diffusion(image_noise, t_var(i), delta_t_const, k_const, g_type);            
            ssim_var(i) = ssim(anisotrop_gfilt_img, image_correct);
        end        
end



%% Поиск оптимальных значений параметров 
close all;
switch var_type
    case 'k_and_delta_t'
        [ssim_r, ssim_c] = find(ssim_var == max(max(ssim_var)));
        ssim_param = [max(max(ssim_var)) delta_t_var(ssim_c)]; 
        save(mat_filename);
    case 't'
        ssim_param = [max(ssim_var) t_var(ssim_var == max(ssim_var))];
        save(mat_filename);
end

 %% Построение графиков
 close all;
switch var_type
    case 'k_and_delta_t'
        anisotrop_gSSIM_fig = figure('Name', 'ssim');
        plotting_two_var(k_var, delta_t_var, ssim_var, ssim_param)
        xlabel('\Deltat'); ylabel('SSIM');
        title('При t = ' + string(t_const))
        axis([0 0.3 0.6 1])
        print(anisotrop_gSSIM_fig, plot_filename,'-dpng','-r500');  
    case 't'
        anisotrop_gSSIM_fig = figure('Name', 'SSIM');
        plotting_one_var(t_var, ssim_var, ssim_param)
        xlabel('t'); ylabel('SSIM');
        axis([0 50 0.8 1])
        legend('Максимальное значение метрики');
        title('При k = ' + string(k_const) + ' и \Deltat = ' + string(delta_t_const))
        print(anisotrop_gSSIM_fig, plot_filename,'-dpng','-r500');  
end

        
        
function plotting_two_var(k_var, delata_t_var, metric_matrix, metric_param)
    color_line = hsv(2*(length(k_var) + 1));
    for k = 1:length(k_var)
        plot(delata_t_var,metric_matrix(k,:),'.-', 'color', color_line(2*k,:),'LineWidth', 1.5, 'MarkerSize', 8)
        hold on;
        legend_names{k} = ['k = ' num2str(k_var(k))]; 
    end
    ax = gca; ax.FontSize = 12;
    grid on;
    stem(metric_param(1,2),metric_param(1,1), '*','color', color_line(end,:),'LineWidth',1.5)
    legend_names = [legend_names 'Максимальное значение метрики'];
    legend(legend_names)       
    legend('Location', 'bestoutside')
end

function plotting_one_var(t_var, metric_var, metric_param)
    stem(metric_param(1,2),metric_param(1,1), 'r*','LineWidth',1.5)
    hold on
    plot(t_var,metric_var,'.-k','LineWidth',1.5, 'MarkerSize', 15)
    grid on;            
end