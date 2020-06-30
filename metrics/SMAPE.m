function smape_rs = SMAPE(img,img_filt)
    img = img(:); img_filt = img_filt(:);
    smape_rs = 0;
    for i = 1:length(img) 
        if (img(i) == 0 && img_filt(i) == 0)
            smape_rs = smape_rs + 0;
        else
            smape_rs = smape_rs + (abs(img(i) - img_filt(i)))/((img(i)+img_filt(i))/2);
        end
    end
    smape_rs = 100*(1/length(img))*smape_rs;
end 