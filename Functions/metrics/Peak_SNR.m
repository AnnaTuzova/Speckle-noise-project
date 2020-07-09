function peak_snr_rs = Peak_SNR(img,img_filt)
    mse = MSE(img,img_filt);    
    peak_snr_rs = 20*log10(255/sqrt(mse));
end