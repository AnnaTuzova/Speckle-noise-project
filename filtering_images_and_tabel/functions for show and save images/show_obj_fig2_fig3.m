function show_obj_fig2_fig3(row_ind, col_ind, image, image_noise, distribution, name_of_object)
D = 0.0201; sigma = 0.2707; 
%%without noise
figure('Name', 'Objects wihout noise');
imshow(padarray(image(row_ind,col_ind),[1,1],0)); 

switch name_of_object
    case 'small_obj'
    	title('��������� ������� ��� ��������� ����');
    case 'big_obj'
        title('������� ������ ��� ��������� ����');
    case 'border'
        title('������� ��� ��������� ����');       
    case 'border_with_smal_obj'      
        title('������� � ������� ��������� ����� ��� ��� ��������� ����'); 
end


%%with noise
figure('Name', 'Objects wih noise');
imshow(padarray(image_noise(row_ind,col_ind),[1,1],0)); 

switch name_of_object
    case 'small_obj'
        switch distribution
            case 'normal'  
                title('��������� ������� �� �����-����� � ���������� ��������������, \sigma^2 = ' + string(D));   
            case 'Rayleigh'    
                title('��������� ������� �� �����-����� � �������������� �����, \sigma = ' + string(sigma));
            case 'Rayleigh_correlated'
                title('��������� ������� � ���������������-��������������� �����-����� � �������������� �����');
            case 'Rayleigh_uncorrelated'
                title('��������� ������� � ���������������-����������������� �����-����� � �������������� �����');
        end  
    case 'big_obj'
        switch distribution
            case 'normal'
                title('������� ������ �� �����-����� � ���������� ��������������, \sigma^2 = ' + string(D));
            case 'Rayleigh'
                title('������� ������ �� �����-����� � �������������� �����, \sigma = ' + string(sigma));
            case 'Rayleigh_correlated'
                title('������� ������ � ���������������-��������������� �����-����� � �������������� �����');
            case 'Rayleigh_uncorrelated'
                title('������� ������ � ���������������-����������������� �����-����� � �������������� �����');
        end 
    case 'border'
        switch distribution
            case 'normal'
                title('������� �� �����-����� � ���������� ��������������, \sigma^2 = ' + string(D));
            case 'Rayleigh'
                title('������� �� �����-����� � �������������� �����, \sigma = ' + string(sigma));
            case 'Rayleigh_correlated'
                title('������� � ���������������-��������������� �����-����� � �������������� �����');
            case 'Rayleigh_uncorrelated'
                title('������� � ���������������-����������������� �����-����� � �������������� �����');
        end    
    case 'border_with_smal_obj'
        switch distribution
            case 'normal'
                title('������� � ������� ��������� ����� ��� �� �����-����� � ���������� ��������������, \sigma^2 = ' + string(D));
            case 'Rayleigh'
                title('������� � ������� ��������� ����� ��� �� �����-����� � �������������� �����, \sigma = ' + string(sigma));
            case 'Rayleigh_correlated'
                title('������� � ������� ��������� ����� ��� � ���������������-��������������� �����-����� � �������������� �����');
            case 'Rayleigh_uncorrelated'
                title('������� � ������� ��������� ����� ��� � ���������������-����������������� �����-����� � �������������� �����'); 
        end                 
end
          
end