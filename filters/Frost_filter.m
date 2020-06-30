function filt_img = Frost_filter(win_size,img,damp_fact)
    
    border = round((win_size-1)/2);
%     img = padarray(img,border,1);
    img = add_copy_border(img, border);
    side_of_win = win_size(1);
    filt_img = zeros(size(img));   
    center = (side_of_win - 1)/2;

    [x,y]= meshgrid(-border(1,1):border(1,1),-border(1,2):border(1,2));
    S = sqrt(x.^2+y.^2);
    
for i = 1:1:size(img,1) - (side_of_win - 1) 
    for j = 1:1:size(img,2) - (side_of_win - 1) 
        window = img(i:i+side_of_win-1,j:j+side_of_win-1);
        U_aver = mean(window(:));
        U_var = var(window(:));
       
        %Weight for each pixel in the local window
        B =  damp_fact*(U_var/(U_aver*U_aver));
        Weigh = exp(-S.*B);
       
        % Filtering
        s = sum(window(:).*Weigh(:))./sum(Weigh(:));
        filt_img(i+center,j+center) = s;
    end
end

filt_img = filt_img(border(1)+1:end-border(1),border(2)+1:end-border(2));
filt_img = max(min(filt_img,1),0);
end