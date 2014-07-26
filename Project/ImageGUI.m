function varargout = ImageGUI(varargin)
% IMAGEGUI M-file for ImageGUI.fig
%      IMAGEGUI, by itself, creates a new IMAGEGUI or raises the existing
%      singleton*.
%
%      H = IMAGEGUI returns the handle to a new IMAGEGUI or the handle to
%      the existing singleton*.
%
%      IMAGEGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in IMAGEGUI.M with the given input arguments.
%
%      IMAGEGUI('Property','Value',...) creates a new IMAGEGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ImageGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ImageGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ImageGUI

% Last Modified by GUIDE v2.5 25-Jul-2012 22:06:16

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ImageGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @ImageGUI_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before ImageGUI is made visible.
function ImageGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ImageGUI (see VARARGIN)

% Choose default command line output for ImageGUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

%Turn off the axes.
axis(handles.ImageAxes, 'off');

% UIWAIT makes ImageGUI wait for user response (see UIRESUME)
% uiwait(handles.Window);


% --- Outputs from this function are returned to the command line.
function varargout = ImageGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in NewImageButton.
function NewImageButton_Callback(hObject, eventdata, handles)
% hObject    handle to NewImageButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[fileName,pathName] = uigetfile(...
    {'*.jpg;*.bmp;*.png;*.tif;*.gif','Image Files (*.jpg,*.bmp,*.png,*.tif,*.gif)';...
    '*.*', 'All Files (*.*)'}, ...
    'Choose Image');
filePath = [pathName fileName];
if filePath ~=0
    %Load image
    img = imread(filePath);
    
    % Ensure that the image is grayscale
    if numel(img(1,1,:)) == 3
        img = rgb2gray(img);
    end   
    
    % Set handles images to newly loaded image
    handles.image = img;
    handles.procImage = img;
    imshow(handles.image);
    % update handles
    guidata(hObject, handles);
end

% --- Executes on button press in ResetImageButton.
function ResetImageButton_Callback(hObject, eventdata, handles)
% hObject    handle to ResetImageButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.procImage = handles.image;
imshow(handles.image);
% update handles
guidata(hObject, handles);

% --- Executes on button press in QuitButton.
function QuitButton_Callback(hObject, eventdata, handles)
% hObject    handle to QuitButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
close(handles.Window);

% --- Executes on button press in LearnButton.
function LearnButton_Callback(hObject, eventdata, handles)
% hObject    handle to LearnButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Open Learning GUI
learning_GUI;

% --- Executes on button press in DetectButton.
function DetectButton_Callback(hObject, eventdata, handles)
% hObject    handle to DetectButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Display message to notify user that calculation is working...
m = msgbox('Detecting Letters. Please Wait...');
img = handles.procImage;

img = handCleanup(img);

% Perform contour tracking
[img, blob_data, blob_names] = contourTrack(img);
[blob, name] = filterBlobs(blob_data, blob_names);


% Load stored blob parameters and names
if(exist('storedBlobs.mat', 'file'))
    load('storedBlobs.mat', 'stored_params');
    load('storedBlobs.mat', 'stored_names');
else
    error('Blob parameters not found.');
end

% Normalize both the stored blobs and the found blobs
knownNorm = normalizeParams(stored_params);
blobNorm = normalizeParams(blob, stored_params);

% Perform comparison to identify blobs
[detectedSign, name] = detectSign(blobNorm,knownNorm, stored_names);

close(m);


map=[0 0 0; 1 0 0; 0 1 0; 0 0 1; 1 1 0; 1 0 1; 0 1 1; .5 0 0; 0 .5 0; 0 0 .5];
imshow(img, map);

%Overlay text on the image to show the user the results
text(detectedSign(1), detectedSign(2), name, 'BackgroundColor', [0 1 1]);

% update handles
guidata(hObject, handles);
