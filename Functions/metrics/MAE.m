function mae_rs = MAE(img,img_filt)
    mae_rs = (1/numel(img))*sum(sum(abs(img-img_filt)));
end 