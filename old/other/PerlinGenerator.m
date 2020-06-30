function perlin_noise = PerlinGenerator(img, p)
    seed = 10;
    img_width = size(img,2);
    img_high = size(img,1);
    white_noise = zeros(img_width*2,img_high*2);
    for x = 1:img_width
        for y = 1:img_high
            rand_number = (1 - rand()*2);
            white_noise(x,y) = rand_number;
        end
    end
   
    % perlin noise
    perlin_noise = zeros(img_width,img_high);
    for x = 1:img_width
        for y = 1:img_high
            perlin_noise(x,y) = perlinNoise2d(2+x/(20*seed),2+y/(20*seed));
        end
    end     
  
    function cos_interpolate = CosineInterpolate(a, b, x)
        ft = x*pi;
        f = (1-cos(ft))*0.5;
        cos_interpolate = (a*(1-f)+b*f);
    end

    function smoothed_noise = SmoothedNoise(x,y)   
        corners = (white_noise(x-1,y-1) + white_noise(x+1,y-1) + white_noise(x-1,y+1) + white_noise(x+1,y+1))/16;
        sides = (white_noise(x-1,y) + white_noise(x+1,y) + white_noise(x,y+1) + white_noise(x,y-1))/8;
        center = white_noise(x,y)/4;
        smoothed_noise = (corners + sides + center);
    end

    function interpolated_noise = InterpolatedNoise(x,y)
        integerX = floor(x);
        integerY = floor(y);

        fractionalX = x - integerX;
        fractionalY = y - integerY;

        v1 = SmoothedNoise(integerX, integerY);
        v2 = SmoothedNoise(integerX+1, integerY);
        v3 = SmoothedNoise(integerX, integerY + 1);
        v4 = SmoothedNoise(integerX+1, integerY + 1);

        i1 = CosineInterpolate(v1,v2,fractionalX);
        i2 = CosineInterpolate(v3,v4, fractionalX);

        interpolated_noise = CosineInterpolate(i1,i2,fractionalY);
    end

    function perlin_result = perlinNoise2d(x,y)
        total = 0;
        frequency = 0;
        amplitude = 0;
        n = 5;
        for i = 1:n
           frequency = 2^i; 
           amplitude = p^i;
           total = total + InterpolatedNoise(x*frequency,y*frequency)*amplitude;
        end

        perlin_result = total;
    end
end