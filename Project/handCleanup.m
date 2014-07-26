function output_image = handCleanup(image)
%HANDCLEANUP function used to clean up training images before contour
%              tracking
%
% INPUT ARGUEMENTS:
%   image - the image on which to perform the cleanup
%
% EXTENDED DESCRIPTION:
%   This function performs cleanup on grayscale training images. The cleanup
%   is performed by first applying a threshold using otsu's method,
%   followed by morphological operators for removing noise. As a
%   precondition, the image must be grayscale. Otherwise, the thresholding
%   function will not work.

% Perform opening and closing with a disk structuring element
% This reduces the noise in the image, making thresholding more effective
se = strel('disk', 2);
image = imopen(image, se);
image = imclose(image, se);

% Use a low threshold to threshold out the arm and other background
thresh = 40;
bw_image = im2bw(image, thresh/255);

% Eliminate black spot noise
bw_image = ~bwareaopen(~bw_image, 30, 4);

% Eliminate white spot noise
bw_image = ~bwareaopen(bw_image, 30, 4);

output_image = bw_image;
end

