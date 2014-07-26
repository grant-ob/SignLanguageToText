function [gray_level, count] = histogram(input_image)
%HISTOGRAM calculates and the histogram for a grayscale image
%
% INPUT ARGUEMENTS:
%   input_image - a matrix of integers (0-255), representing the grayscale
%                 for which to find the histogram.
%
% EXTENDED DESCRIPTION:
%   This function finds and displays the histogram for the grayscale image
%   specified by the input_image arguement. The histogram is found by
%   examining each individual pixel and assigning it to the appropriate
%   bin. There are two outputs to this function: gray_level is an array of
%   gray levels (1:256), count is an array of pixel counts corresponding to
%   the gray levels

count = zeros(1,256);
gray_level = 1:256;
% Get the total number of pixels in the image
elements = numel(input_image);

for i = 1:elements  % Iterate through the image pixels
    % Assign the pixel to the appropriate bin
    bin = input_image(i) + 1;
    count(bin) = count(bin) + 1;
end
end

