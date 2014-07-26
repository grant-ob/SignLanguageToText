function blob_data = normalizeParams(blob_data, reference_data)
%NORMALIZEPARAMS Normalize blob parameters (0..1)
%
% INPUT ARGUMENTS:
%   blob_data - the data to normalize, in matrix form. Each row represents
%               a blob and each column represents a parameter of the blob,
%               as specified in the contour tracking algorithm in
%               contourTrack.m
%
%   reference_data - the data to be used as a reference for normalization.
%                    If this input is specified, the values of each column 
%                    of the blob_data matrix (except for columns 1, 2 and 12 
%                    - the centroid and m00) will be shift by the minimum 
%                    of the same column from the reference_data matrix, 
%                    and then divided by the maximum of that column from 
%                    the reference_data matrix shifted by the minimum.
                    

% Check the number of arguements
if nargin == 1
    % If there is only 1 arg, then blob_data is also treated as the
    % reference
    reference_data = blob_data;
end

for i = 3:11
    % Find max and min of form params
    max_i = max(reference_data(:,i));
    min_i = min(reference_data(:,i));
    % Perform normalization
    if(max_i - min_i) ~= 0
        blob_data(:,i) = (blob_data(:,i) - min_i)/(max_i - min_i);
    else if max_i ~= 0
        blob_data(:,i) = blob_data(:,i)/max_i;
        end
    end
end

