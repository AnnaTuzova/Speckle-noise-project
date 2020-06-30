function filt_img = bilateral_filter(win_size, img, sig_d, sig_r)

 border = round((win_size-1)/2);
%  img = padarray(img,border,1);
 img = add_copy_border(img, border);
 side_of_win = win_size(1);
 filt_img = zeros(size(img));   
 center = (side_of_win - 1)/2;
 
for i = 1:1:size(img,1) - (side_of_win - 1) 
   for j = 1:1:size(img,2) - (side_of_win - 1) 
      window = img(i:i+side_of_win-1,j:j+side_of_win-1);
      
      k = repmat([i:i+side_of_win-1]',[1,side_of_win]);
      l = repmat([i:i+side_of_win-1],[side_of_win,1]);
      
      weight = exp(-((i + center - k).^2 + (i + center - l).^2)./(2*sig_d) -...
          ((img(i+center,j+center) - window).^2)./(2*sig_r));
      s = sum(sum(weight.*window))/sum(sum(weight));
      filt_img(i+center,j+center) = s;
   end
end

filt_img = filt_img(border(1)+1:end-border(1),border(2)+1:end-border(2));
filt_img = max(min(filt_img,1),0);
end