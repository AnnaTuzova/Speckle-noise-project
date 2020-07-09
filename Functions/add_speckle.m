function noise_img = add_speckle(img, distribution)
%%Параметры определены из тестовых равномерных областей. 
%%См. файл testing_ENL и папку параметры распределения спекл-шума для равномерных участков
    E = 0.3566; %%Нормальное распределение
    D = 0.0201; 
    sigma = 0.2707; %%Рэлей
 
    %%коррелированный и некоррелированный шум Рэлея (см. сообщения)
    uncor_gauss = randn(size(img,1), size(img,2));  %matrix with Normally distributed random elements having zero mean and variance one
    LPF = [1 1 1; 1 1 1; 1 1 1];  % spatial low pass filter LPF
    corr_gauss = filter2(LPF, uncor_gauss);
    
    switch distribution
        case 'Normal'
           noise_img = img + normrnd(E,D,[size(img,1),size(img,2)]).*img;
        case 'Rayleigh'
           noise_img = img + raylrnd(sigma.*ones(size(img,1),size(img,2))).*img;
        case 'CorrelatedRayleigh'
           noise_img = img + ray_noise(corr_gauss, size(img,1), size(img,2), sigma).*img; 
        case 'UncorrelatedRayleigh'
           noise_img = img + ray_noise(uncor_gauss, size(img,1), size(img,2)).*img; 
    end
    
    noise_img = max(min(noise_img,1),0);
end

%correlated rayleigh noise
function result = ray_noise(gauss_distrib, xsize, ysize, sigma)
    gauss_distrib = gauss_distrib(:);
    ray_distrib = random('rayleigh',sigma,1,xsize*ysize);  
    
    [gauss_sorted, gauss_sorted_ind] = sort(gauss_distrib);
    [ray_sorted, ray_sorted_ind] = sort(ray_distrib);
    gauss_distrib(gauss_sorted_ind) = ray_distrib(ray_sorted_ind);
    
    result = reshape(gauss_distrib, ysize, xsize);
end
