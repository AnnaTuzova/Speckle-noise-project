function mse_rs = mseMetric(img_filt, img)
    mse_rs = (1/numel(img))*sum(sum(abs(img-img_filt).^2));
end