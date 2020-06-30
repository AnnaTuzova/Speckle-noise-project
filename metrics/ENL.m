function [ENL_max,ENL_med] = ENL(img, ENL_win)
 ENL_h = ENL_win(1);
 ENL_w = ENL_win(2);
 rem_h = rem(size(img,1), ENL_h);
 rem_w = rem(size(img,2), ENL_w);
 enl_result = [];
for i = 1:ENL_h:size(img,1) - (ENL_h - 1) 
   for j = 1:ENL_w:size(img,2) - (ENL_w - 1) 
       if (i == size(img,1) - rem_h + 1)
           window = img((i - ENL_h - rem_h):end,j:j + ENL_w - 1);
       elseif (j == size(img,2) - rem_h + 1)
           window = img(i:i + ENL_h - 1,(j - ENL_w - rem_w):end);
       elseif ((i == size(img,1) - rem_h + 1) && (j == size(img,2) - rem_h + 1))
           window = img((i - ENL_h - rem_h):end,(j - ENL_w - rem_w):end);
       else
           window = img(i:i + ENL_h - 1,j:j + ENL_w - 1);
       end
       
       E = mean(window(:));
       D = var(window(:));
       enl_result = [enl_result, E^2/D];
   end
end
% reshape(enl_result, [ceil(size(img,2), ENL_w), ceil(size(img,1), ENL_h)])'
 ENL_max = max(enl_result);
 ENL_med = median(enl_result);
end