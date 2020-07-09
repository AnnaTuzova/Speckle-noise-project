function result_img = AnisotropicDiffusionExp(noise_img, t, k, delta_t)
%%параметры t, delta_t и k выбираютс€ экспериментально
%%ѕараметр t Ч это уровень размыти€, на котором мы хотим прекратить работу алгоритма, 
%%deltaT Ч шаг по времени, k Ч параметр функции g
%%g_type - вид функции g (1 или 2)

img = padarray(noise_img,[1,1]);
% img = add_copy_border(noise_img, [1,1]);
blur_img = zeros(size(noise_img));

level = 0;
while (level < t)
    N = img(1:end - 2,2:end - 1) - img(2:end-1,2:end-1);
    S = img(3:end,2:end - 1) - img(2:end-1,2:end-1);
    E = img(2:end - 1,3:end) - img(2:end-1,2:end-1);
    W = img(2:end - 1,1:end - 2) - img(2:end-1,2:end-1);
    

    blur_img = img(2:end-1,2:end-1) + ...
        + delta_t.*(g1(abs(N),k).*N + g1(abs(S),k).*S + ...
    	g1(abs(E),k).*E + g1(abs(W),k).*W);
    
    img(2:end-1,2:end-1) = blur_img;
    level = level + 1; % + delta_t;
end

result_img = blur_img;
result_img = max(min(result_img,1),0);
end

function g_result = g1(x,k)
    g_result = exp(-(x./k).^2);
end