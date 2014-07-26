function varargout = learning_GUI(varargin)
% LEARNING_GUI M-file for learning_GUI.fig
%      LEARNING_GUI, by itself, creates a new LEARNING_GUI or raises the existing
%      singleton*.
%
%      H = LEARNING_GUI returns the handle to a new LEARNING_GUI or the handle to
%      the existing singleton*.
%
%      LEARNING_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in LEARNING_GUI.M with the given input arguments.
%
%      LEARNING_GUI('Property','Value',...) creates a new LEARNING_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before learning_GUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to learning_GUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help learning_GUI

% Last Modified by GUIDE v2.5 22-Jul-2012 17:51:58

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @learning_GUI_OpeningFcn, ...
                   'gui_OutputFcn',  @learning_GUI_OutputFcn, ...
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


% --- Executes just before learning_GUI is made visible.
function learning_GUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to learning_GUI (see VARARGIN)

% Create and configure the video input object
% handles.video = videoinput('winvideo',2,'YUY2_720x480');
% triggerconfig(handles.video, 'Manual');
% set(handles.video,'TriggerRepeat',Inf)
% set(handles.video, 'LoggingMode', 'memory');
% set(handles.video, 'FramesPerTrigger', 10);
% set(handles.video, 'FrameGrabInterval', 5);
% start(handles.video);

handles.captureArea = [1 1; 720 480];

%Turn off the axes.
axis(handles.ImageAxes, 'off');

% Disable analyze button
set(handles.AnalyzeButton, 'Enable', 'off');

% Disable save button
% set(handles.SaveBlobButton, 'Enable', 'off');
% 
% vidRes = get(handles.video, 'VideoResolution');
% nBands = get(handles.video, 'NumberOfBands');
% hImage = image(zeros(vidRes(2), vidRes(1), nBands));

% preview(handles.video, hImage);

% Choose default command line output for learning_GUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes learning_GUI wait for user response (see UIRESUME)
% uiwait(handles.learnWindow);



% --- Outputs from this function are returned to the command line.
function varargout = learning_GUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in CaptureButton.
function CaptureButton_Callback(hObject, eventdata, handles)
% hObject    handle to CaptureButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
trigger(handles.video);
while islogging(handles.video)
    % wait for logging to stop
end
data = getdata(handles.video);
bounds = handles.captureArea;

handles.image1 = data(bounds(1,2):bounds(2,2),...
    bounds(1,1):bounds(2,1),1,1);

% Enable analyze button
set(handles.AnalyzeButton, 'Enable', 'on');
    
% update handles
guidata(hObject, handles);

% --- Executes on button press in AnalyzeButton.
function AnalyzeButton_Callback(hObject, eventdata, handles)
% hObject    handle to AnalyzeButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
m = msgbox('Analyzing Image. Please wait..');
% Perform image cleanup (thresholding, morphology operations)
handles.image1 = handCleanup(handles.image1);
[img, blob_data, blob_names] = contourTrack(handles.image1);
[handles.blob, name] = filterBlobs(blob_data, blob_names);
% update the table of analysis values
handles.image1 = img;
map=[0 0 0; 1 0 0; 0 1 0; 0 0 1; 1 1 0; 1 0 1; 0 1 1; .5 0 0; 0 .5 0; 0 0 .5];
% Show processed image
figure;
imshow(img, map);
close(m);

format('short'); % no decimal places
% Get data from the blob_obj object
dat = num2cell(handles.blob(3:11))';
% Set table row names
rows =  {'Holes'; 'Complexity' ; 'phi1'; 'phi2'; 'Imin'; 'Imax'; ...
    'Ri'; 'psi1'; 'psi2';};
% Set table col names
cols = {'Value'};
%Display the actual table
t = uitable('Parent', handles.learnWindow,'Data',dat,'ColumnName',cols,...
    'RowName',rows,'Position',[10 192 210 150]);

% enable save blob button
set(handles.SaveBlobButton, 'Enable', 'on');

% disable analyze button
set(handles.AnalyzeButton, 'Enable', 'off');
% update handles
guidata(hObject, handles);


function BlobNameEdit_Callback(hObject, eventdata, handles)
% hObject    handle to BlobNameEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% disable save blob button
set(handles.SaveBlobButton, 'Enable', 'on');
handles.bname = get(hObject, 'String');
% update handles
guidata(hObject, handles);
% enable save blob button
set(handles.SaveBlobButton, 'Enable', 'on');


% Hints: get(hObject,'String') returns contents of BlobNameEdit as text
%        str2double(get(hObject,'String')) returns contents of BlobNameEdit as a double


% --- Executes during object creation, after setting all properties.
function BlobNameEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to BlobNameEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in SaveBlobButton.
function SaveBlobButton_Callback(hObject, eventdata, handles)
% hObject    handle to SaveBlobButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% name of the structure in which blob data is saved
% I chose to use a .mat file
saveFile = 'storedBlobs.mat';

% set the name of the letter blob
letterBlob = handles.blob;

% open the .mat file where blob data is being stored
% retreive the name and form parameter data
% and append the learned blob
if(~exist(saveFile, 'file'))
    stored_params = letterBlob;
    stored_names{1} = handles.bname;
    save(saveFile, 'stored_params');
    save(saveFile, 'stored_names', '-append');
else 
    load(saveFile, 'stored_params');
    load(saveFile, 'stored_names');    
    stored_params = vertcat(stored_params, letterBlob);
    stored_names = vertcat(stored_names, handles.bname);    
    save(saveFile, 'stored_params', '-append');
    save(saveFile, 'stored_names', '-append');
end

% disable the save button
set(handles.SaveBlobButton, 'Enable', 'off');

% update the table of saved blobs
% Get all names from matrix
data = stored_names(:,1)';
rows = {'Name'};
cols = '';
% Display the table
t = uitable('Parent', handles.learnWindow, 'Data', data, 'ColumnName', cols, ...
    'RowName', rows, 'Position', [10, 80, 330, 45]);


% update handles
guidata(hObject, handles);

% --- Executes on button press in CloseButton.
function CloseButton_Callback(hObject, eventdata, handles)
% hObject    handle to CloseButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
delete(handles.video);
clear handles.video;
close(handles.learnWindow);

% --- Executes on button press in ResetButton.
function ResetButton_Callback(hObject, eventdata, handles)
% hObject    handle to ResetButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Reset the processed image
handles.procImage = handles.image;
% Show the original image
imshow(handles.image);

% Enable analyze button
set(handles.AnalyzeButton, 'Enable', 'on');


% Disable save button
set(handles.SaveBlobButton, 'Enable', 'off');

% update handles
guidata(hObject, handles);


% --- Executes on button press in SetCaptureAreaButton.
function SetCaptureAreaButton_Callback(hObject, eventdata, handles)
% hObject    handle to SetCaptureAreaButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
msgbox('Click on the top left and the bottom right of the capture area, and then hit enter');
selected = 0;
while ~selected
    [x,y] = getpts(handles.ImageAxes);
    if numel([x,y]) > 4 || x(1) < 1 || y(1) < 1 || x(2) < 1 || y(2) < 1 || x(1) > x(2)
        msgbox('Invalid Selection. Try Again.');
    else
        selected = 1;
    end
end

handles.captureArea = [x,y];
text(x,y,'*');

% update handles
guidata(hObject, handles);
