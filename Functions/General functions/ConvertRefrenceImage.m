function test_image = ConvertRefrenceImage(test_image, noise_type)
    switch noise_type
        case 'Normal' 
            E = 0.3566; 
            D = 0.0201; 
            test_image = test_image.*(1 + E);
            test_image = max(min(test_image, 1), 0);
        case 'Rayleigh'
            sigma = 0.2707; 
            test_image = test_image.*(1 + sqrt(pi/2)*sigma);
            test_image = max(min(test_image, 1), 0);    
        case 'CorrelatedRayleigh'
            sigma = 0.2707; 
            test_image = test_image.*(1 + sqrt(pi/2)*sigma);
            test_image = max(min(test_image, 1), 0);
    end
end