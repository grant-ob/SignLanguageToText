function [filt_data, filt_names] = filterBlobs(blob_data, blob_names)
%FILTERBLOBS keeps only the largest blob in a set of blobs
%   
% INPUT ARGUMENTS:
%   blob_data - a matrix of blob parameters, as specified by the contour
%               tracking and moments/form parameters computation function
%               in contourTrack.m
%   blob_names - a matrix of blob names, associated with the rows of
%                blob_data
%
% EXTENDED DESCRIPTION:
%   This function keeps only the largest blob in blobs indicated by the
%   rows of blob_data. In other words, blob_data and blob_names will become
%   one row each.

maxArea = -inf;
elements = numel(blob_data(:,1));
% Iterate through all blobs
for i = 1:elements
    if blob_data(i, 12) > maxArea
        % update the max if necessary
        maxArea = blob_data(i, 12);
        filt_data = blob_data(i, :);
        filt_names = blob_names(i, :);
    end    
end

