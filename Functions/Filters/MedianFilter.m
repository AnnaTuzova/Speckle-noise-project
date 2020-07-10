function filt_img = MedianFilter(img, win_size)
	border = round((win_size-1)/2);
% 	img = padarray(img,border,1);
    img = AddCopyBorder(img, border);
    filt_img = zeros(size(img));
    side_of_win = win_size(1);
    center = (side_of_win - 1)/2;
    
for i = 1:1:size(img,1) - (side_of_win - 1) 
   for j = 1:1:size(img,2) - (side_of_win - 1) 
      window = img(i:i+side_of_win-1,j:j+side_of_win-1);
      med = median(window(:));
      
      filt_img(i+center,j+center) = med;
   end
end

filt_img = filt_img(border(1)+1:end-border(1),border(2)+1:end-border(2));
filt_img = max(min(filt_img,1),0);
end