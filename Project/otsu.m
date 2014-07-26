function threshold = otsu(input_image)
%OTSU calculates the optimal image threshold based on otsu's method
%
% INPUT ARGUEMENTS:
%   input_image - a matrix of integers (0-255), representing the grayscale
%                 image on which to perform otsu's method
%
%
% EXTENDED DESCRIPTION:
%   Otsu's method is a method for calculating the optimal threshold for a  
%   bi-modal image. This method suggests that the best threshold 
%   corresponds to the minimum sum of within-group variances.
%   The optimal threshold is calculated by stepping through all 256 possible
%   threshold values and calculating the within group variances.


wgv_min = inf;
[levels, count] = histogram(input_image);
p = count/256;
    
for t = 1:256
    BX2 = 0;
    BX = 0;
    BN = 0;
    WX2 = 0;
    WX = 0;
    WN = 0;
    for i = 1:256
        if i < t
            BX = BX + p(i)*(i-1);
            BX2 = BX2 + p(i)*(i-1)*(i-1);
            BN = BN + p(i);
        else
            WX = WX + p(i)*(i-1);
            WX2 = WX2 + p(i)*(i-1)*(i-1);
            WN = WN + p(i);
        end
    end
    v1 = (BN*BX2 - BX*BX) / (BN*(BN-1));
    ps1= BN;
    v2 = (WN*WX2 - WX*WX) / (WN*(WN-1));
    ps2= WN;
    wgv = ps1*v1 + ps2*v2;
    if wgv < wgv_min
        wgv_min = wgv;
        threshold = t;
    end
end
end

