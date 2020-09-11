function peak_snr_rs = psnrMetric(img_filt, img)
    mse_val = mseMetric(img,img_filt);    
    peak_snr_rs = 20*log10(255/sqrt(mse_val));
end