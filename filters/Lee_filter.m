function filt_img = Lee_filter(win_size, img)
 sigma_img = var(img(:));
 
 border = round((win_size-1)/2);
%  img = padarray(img,border,1);
 img = add_copy_border(img, border);
 filt_img = zeros(size(img));  
 side_of_win = win_size(1);
 center = (side_of_win - 1)/2;
 
for i = 1:1:(size(img,1) - (side_of_win - 1))
   for j = 1:1:(size(img,2) - (side_of_win - 1)) 
      window = img(i:i+side_of_win-1,j:j+side_of_win-1);
      U_aver = mean(window(:));
      sigma_u = var(window(:));
      
      w = sigma_u/(sigma_u + sigma_img);
      s = U_aver + w*(img(i+center,j+center) - U_aver);
      filt_img(i+center,j+center) = s;
   end
end

filt_img = filt_img(border(1)+1:end-border(1),border(2)+1:end-border(2));
filt_img = max(min(filt_img,1),0);
end