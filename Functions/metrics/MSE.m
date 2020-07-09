function mse_rs = MSE(img,img_filt)
    mse_rs = (1/numel(img))*sum(sum(abs(img-img_filt).^2));
end