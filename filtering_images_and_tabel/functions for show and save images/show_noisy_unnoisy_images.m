function show_noisy_unnoisy_images(image, image_noise, distribution)

figure('Name', 'Image without noise');
imshow(padarray(image,[1,1],0)); title('������������� �����������');

figure('Name', 'Image with noise');
imshow(padarray(image_noise,[1,1],0));

switch distribution
    case 'normal'
        D = 0.0201;
        title('����������� �� �����-����� � ���������� ��������������, \sigma^2 = ' + string(D));
    case 'Rayleigh'
        sigma = 0.2707; 
        title('����������� �� �����-����� � �������������� �����, \sigma = ' + string(sigma));
    case 'uniform'
        title('����������� �� �����-����� � ����������� ��������������, \sigma^2 = ' + string(var));
    case 'Rayleigh_correlated'
        title('����������� � ���������������-��������������� �����-����� � �������������� �����');
    case 'Rayleigh_uncorrelated'
        title('����������� � ���������������-����������������� �����-����� � �������������� �����');
end  
           
end