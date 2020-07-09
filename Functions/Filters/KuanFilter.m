function filt_img = KuanFilter(img, win_size, fact)
 border = round((win_size-1)/2);
%  img = padarray(img,border,1);
 img = add_copy_border(img, border);
 side_of_win = win_size(1);
 filt_img = zeros(size(img));   
 center = (side_of_win - 1)/2;
 ENL_win = [25,25];
 ENL_val = ENL(img, ENL_win);   
 
 for i = 1:1:size(img,1) - (side_of_win - 1) 
   for j = 1:1:size(img,2) - (side_of_win - 1) 
      window = img(i:i+side_of_win-1,j:j+side_of_win-1);
     
      mean_u = mean(window(:));
      std_u = std(window(:));
      C_e = std_u/mean_u;
      NLOOK = (1 + fact)*ENL_val;
      C_u = 1/sqrt(NLOOK);
      w = (1 - (C_u^2/C_e^2))/(1 + C_u^2);
   
      s = mean_u + w*(img(i+center,j+center) - mean_u);
      filt_img(i+center,j+center) = s;
   end
 end

filt_img = filt_img(border(1)+1:end-border(1),border(2)+1:end-border(2));
filt_img = max(min(filt_img,1),0);
end
