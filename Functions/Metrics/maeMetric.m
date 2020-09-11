function mae_rs = maeMetric(img_filt, img)
    mae_rs = (1/numel(img))*sum(sum(abs(img-img_filt)));
end 