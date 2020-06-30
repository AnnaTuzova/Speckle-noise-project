function mape_rs = MAPE(img,img_filt)
    img = img(:); img_filt = img_filt(:);
    mape_rs = 0;
    for i = 1:length(img) 
        if (img(i) == 0)
            mape_rs = mape_rs + 0;
        else
            mape_rs = mape_rs + (abs(img(i) - img_filt(i)))/abs(img(i));
        end
    end
    mape_rs = 100*(1/length(img))*mape_rs;
end 