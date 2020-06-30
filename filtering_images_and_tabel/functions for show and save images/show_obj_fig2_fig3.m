function show_obj_fig2_fig3(row_ind, col_ind, image, image_noise, distribution, name_of_object)
D = 0.0201; sigma = 0.2707; 
%%without noise
figure('Name', 'Objects wihout noise');
imshow(padarray(image(row_ind,col_ind),[1,1],0)); 

switch name_of_object
    case 'small_obj'
    	title('Маленькие объекты без наложения шума');
    case 'big_obj'
        title('Большой объект без наложения шума');
    case 'border'
        title('Граница без наложения шума');       
    case 'border_with_smal_obj'      
        title('Граница с мелкими объектами около нее без наложения шума'); 
end


%%with noise
figure('Name', 'Objects wih noise');
imshow(padarray(image_noise(row_ind,col_ind),[1,1],0)); 

switch name_of_object
    case 'small_obj'
        switch distribution
            case 'normal'  
                title('Маленькие объекты со спекл-шумом с нормальным распределением, \sigma^2 = ' + string(D));   
            case 'Rayleigh'    
                title('Маленькие объекты со спекл-шумом с распределением Рэлея, \sigma = ' + string(sigma));
            case 'Rayleigh_correlated'
                title('Маленькие объекты с пространственно-коррелированным спекл-шумом с распределением Рэлея');
            case 'Rayleigh_uncorrelated'
                title('Маленькие объекты с пространственно-некоррелированным спекл-шумом с распределением Рэлея');
        end  
    case 'big_obj'
        switch distribution
            case 'normal'
                title('Больщой объект со спекл-шумом с нормальным распределением, \sigma^2 = ' + string(D));
            case 'Rayleigh'
                title('Больщой объект со спекл-шумом с распределением Рэлея, \sigma = ' + string(sigma));
            case 'Rayleigh_correlated'
                title('Больщой объект с пространственно-коррелированным спекл-шумом с распределением Рэлея');
            case 'Rayleigh_uncorrelated'
                title('Больщой объект с пространственно-некоррелированным спекл-шумом с распределением Рэлея');
        end 
    case 'border'
        switch distribution
            case 'normal'
                title('Граница со спекл-шумом с нормальным распределением, \sigma^2 = ' + string(D));
            case 'Rayleigh'
                title('Граница со спекл-шумом с распределением Рэлея, \sigma = ' + string(sigma));
            case 'Rayleigh_correlated'
                title('Граница с пространственно-коррелированным спекл-шумом с распределением Рэлея');
            case 'Rayleigh_uncorrelated'
                title('Граница с пространственно-некоррелированным спекл-шумом с распределением Рэлея');
        end    
    case 'border_with_smal_obj'
        switch distribution
            case 'normal'
                title('Граница с мелкими объектами около нее со спекл-шумом с нормальным распределением, \sigma^2 = ' + string(D));
            case 'Rayleigh'
                title('Граница с мелкими объектами около нее со спекл-шумом с распределением Рэлея, \sigma = ' + string(sigma));
            case 'Rayleigh_correlated'
                title('Граница с мелкими объектами около нее с пространственно-коррелированным спекл-шумом с распределением Рэлея');
            case 'Rayleigh_uncorrelated'
                title('Граница с мелкими объектами около нее с пространственно-некоррелированным спекл-шумом с распределением Рэлея'); 
        end                 
end
          
end