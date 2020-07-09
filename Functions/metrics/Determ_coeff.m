function determ_coeff_rs = Determ_coeff(img,img_filt)
    U_aver = mean(img(:));
    U_aver = repmat(U_aver, [size(img,1) size(img,2)]);
    determ_coeff_rs = 1 - (sum(sum(abs(img-img_filt).^2))/sum(sum(abs(U_aver - img).^2)));
end 