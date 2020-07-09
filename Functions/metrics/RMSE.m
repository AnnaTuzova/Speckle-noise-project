function rmse_rs = RMSE(img,img_filt)
    rmse_rs = sqrt((1/numel(img))*sum(sum(abs(img-img_filt).^2)));
end