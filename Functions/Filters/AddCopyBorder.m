function img = AddCopyBorder(img, border)
    up_border = [img(1,1).*ones(1,border(1)) img(1,:) img(1,end).*ones(1,border(1))];
    down_border = [img(end,1).*ones(1,border(1)) img(end,:) img(end,end).*ones(1,border(1))];
    left_border = img(:,1);
    right_border = img(:,end);
    
    img = [repmat(left_border,[1 border(1)]) img repmat(right_border,[1 border(1)])];
    img = [repmat(up_border,[border(2) 1]); img; repmat(down_border,[border(2) 1])];
end