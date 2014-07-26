function [trackedImage, blob_data, blob_names] = ...
    contourTrack(image)

%CONTOURTRACK contour tracking an object with crack code and moment 
%             calculations to find form parameters of a binary grayscale 
%             image
%
% INPUT ARGUMENTS:
%   image - the image on which to perform contour tracking
%   
% OUTPUT VARIABLES:
%   trackedImage - an image showing the traced objects
%   blob_data - a matrix holding the form parameters, centroid, and name of
%               each blob discovered in the image. Each row corresponds to
%               a different blob, and the column assignments are as
%               follows:
%                   1 - Center X    2 - Center Y
%                   3 - Number of Holes     4 - Complexity
%                   5 - phi1    6 - phi2    7 - Imin    8 - Imax
%                   9 - Ri  10 - psi1   11 - psi2   12 - m00
%
%
% EXTENDED DESCRIPTION:
%   This function performs contour tracking on the objects in a binary 
%   image using crack code. The moments up to M11 are calculated during 
%   contour tracking by a method derived from Green's Theorem. As well, the
%   perimeter of the object and the number of holes in the object are
%   calculated. Form parameters are then calculated and are stored in the
%   blob_data matrix.
%

% Pad image in zeros
[r,c] = size(image);
pad_image = zeros(r+2,c+2);
pad_image(2:r+1, 2:c+1) = image;
image = pad_image;

% Unique label for each blob
label = 2;

% Variable for tracking if we are inside an object
% Used for hole counting
inside = 0;
blob_data = [];
% Find objects in the image by scanning through each pixel
for J = 2:r+1
    for I = 2:c+1
        if image(J,I) == 1 && image(J,I-1) == 0
            % New object found
            code = 1;
            % Set up crack code variables
            UX=I;   UY=J+1;
            VX=I-1;   VY=J+1;
            PX=I;   PY=J;
            StartX=I;   StartY=J;
            % Set up blob analysis parameters
            first = 1;
            M00 = 0;            M01 = 0;
            M10 = 0;            M11 = 0;
            M02 = 0;            M20 = 0;
            perimeter = 0;
            sumY = 0;           sumY2 = 0;
            sumX = 0;           sumX2 = 0;
            MYY=J;              X = I;
            % Call tracking function
            Track();
            new_blob = getData(M00, M01, M10, M02, M20, M11, perimeter);
            blob_data = vertcat(blob_data, new_blob);
            if inside > 1 && M00 < 0
                % we have found a hole in an object
                % increment number of holes on the object that we are
                % inside
                blob_data(inside-1, 3) = ...
                    blob_data(inside-1, 3) + 1;
            end
            label = label + 1;
        else if image(J,I) == 1 && image(J,I-1) > 1
                % we are inside an object
                inside = image(J,I-1);
            else if image(J,I) > 1 && image(J, I-1) == 1
                    % we are leaving an object
                    inside = 0;
                end
            end
        end            
    end
end
if numel(blob_data)== 0
    msgbox('No objects found!');
end
blob_names = cell(1, 1);
trackedImage = image;

% Track - Nested Function for Tracking
function Track()
   while PX ~= StartX || PY ~= StartY || code ~= 1 || first == 1
       first = 0;
       perimeter = perimeter + 1;
       
       image(PY, PX) = label;
           
       % Update U,V and moments
       switch code;
            case 0
                UX=PX-1;    UY=PY;
                VX=PX-1;    VY=PY-1;

                %Moments
                M00 = M00-MYY;
                M01 = M01 - sumY;
                M02 = M02 - sumY2;
                X = X - 1;
                sumX = sumX - X;
                sumX2 = sumX2 - X*X;
                M11 = M11 - (X*sumY);

            case 1
                UX=PX;      UY=PY+1;
                VX=PX-1;    VY=PY+1;

                %Moments
                sumY = sumY + MYY;
                sumY2 = sumY2 + MYY*MYY;
                MYY=MYY+1;
                M10 = M10 - sumX;
                M20 = M20 - sumX2;

            case 2
                UX=PX+1;    UY=PY;
                VX=PX+1;    VY=PY+1;

                %Moments
                M00=M00+MYY;
                M01 = M01 + sumY;
                M02 = M02 + sumY2;
                M11 = M11 + (X*sumY);
                sumX = sumX + X;
                sumX2 = sumX2 + X*X;
                X = X + 1;

            case 3
                UX=PX;      UY=PY-1;
                VX=PX+1;    VY=PY-1;

                %Moments
                MYY=MYY-1;
                sumY = sumY - MYY;
                sumY2 = sumY2 - MYY*MYY;
                M10 = M10 + sumX;
                M20 = M20 + sumX2;

       end                
       
       % Determine next code
        V=image(VY,VX);
        U=image(UY,UX);

        if V>=1
            code=code-1;
            if code==-1
                code=3;
            end
            PX=VX;
            PY=VY;
        else
            if U==0
                code=code+1;
                if code==4
                    code=0;
                end

            else                           
                PX=UX;
                PY=UY;
            end
        end
   end
end  

% Nested function for calculating form parameters indepedent of position,
% orientation and scale from basic moments and perimeter
function data = getData(m00, m01, m10, m02, m20, m11, perimeter)
    data = zeros(1, 12);
    % Centroid - needed for detecting movement
    % X Center 
    data(1) = m10/m00;
    % Y Center
    data(2) = m01/m00;
    % Number of Holes
    data(3) = 0;
    % Complexity
    data(4) = (perimeter^2) / m00;
    % M02 Central Moment
    Mc02 = m02 - ((m01^2)/m00);
    % M20 Central Moment
    Mc20 = m20 - ((m10^2)/m00);
    % M11 Central Moment
    Mc11 = m11 - ((m10*m01)/m00);
    % Phi 1
    data(5) = Mc02 + Mc20;
    % Phi 2
    data(6) = (Mc20 - Mc02)^2 + 4*(Mc11^2);
    % Imin
    data(7) = (data(5) - sqrt(data(6)))/2;
    % Imax
    data(8) = (data(5) + sqrt(data(6)))/2;
    % Ri
    data(9) = data(7)/data(8);
    % Psi 1
    data(10) = data(5)/(m00^2);
    % Psi 2
    data(11) = data(6)/(m00^4);
    % M00 - area (needed for filtering out smaller blobs in training)
    data(12) = m00;
end

end

