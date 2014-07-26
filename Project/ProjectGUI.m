function varargout = ProjectGUI(varargin)
% PROJECTGUI M-file for ProjectGUI.fig
%      PROJECTGUI, by itself, creates a new PROJECTGUI or raises the existing
%      singleton*.
%
%      H = PROJECTGUI returns the handle to a new PROJECTGUI or the handle to
%      the existing singleton*.
%
%      PROJECTGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PROJECTGUI.M with the given input arguments.
%
%      PROJECTGUI('Property','Value',...) creates a new PROJECTGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ProjectGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ProjectGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ProjectGUI

% Last Modified by GUIDE v2.5 25-Jul-2012 20:56:30

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ProjectGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @ProjectGUI_OutputFcn, ...
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


% --- Executes just before ProjectGUI is made visible.
function ProjectGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ProjectGUI (see VARARGIN)

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

% Preview video object
% vidRes = get(handles.video, 'VideoResolution');
% nBands = get(handles.video, 'NumberOfBands');
% hImage = image(zeros(vidRes(2), vidRes(1), nBands));
% preview(handles.video, hImage);

handles.ClockReset = '8';
set(handles.TimeText, 'String', handles.ClockReset);

%timer updating after every 2 secs
handles.tmr = timer('TimerFcn', ...
{@TmrFcn,handles.MainWindow},'BusyMode','Queue',...
    'ExecutionMode','FixedRate','Period',1.0);
guidata(handles.MainWindow,handles);


% Disable start and stop buttons
set(handles.StartButton, 'Enable', 'off');
set(handles.StopButton, 'Enable', 'off');

% Choose default command line output for ProjectGUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes ProjectGUI wait for user response (see UIRESUME)
% uiwait(handles.MainWindow);

% --- Outputs from this function are returned to the command line.
function varargout = ProjectGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function TextBox_Callback(hObject, eventdata, handles)
% hObject    handle to TextBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of TextBox as text
%        str2double(get(hObject,'String')) returns contents of TextBox as a double


% --- Executes during object creation, after setting all properties.
function TextBox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to TextBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in StartButton.
function StartButton_Callback(hObject, eventdata, handles)
% hObject    handle to StartButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
start(handles.tmr);

% --- Executes on button press in StopButton.
function StopButton_Callback(hObject, eventdata, handles)
% hObject    handle to StopButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
stop(handles.tmr);

% --- Executes on button press in CloseButton.
function CloseButton_Callback(hObject, eventdata, handles)
% hObject    handle to CloseButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% delete(handles.video);
% clear handles.video;
close(handles.MainWindow);

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

% Disable start and stop buttons
set(handles.StartButton, 'Enable', 'on');
set(handles.StopButton, 'Enable', 'on');

% Disable capture area button
set(handles.SetCaptureAreaButton, 'Enable', 'off');

% update handles
guidata(hObject, handles);



%-------------------------- USER DEFINED FUNCTIONS ---------------------%

% TMRFCN function - timer function
function TmrFcn(src,event,handles)
handles = guidata(handles);
time = str2double(get(handles.TimeText, 'String'));
time = time - 1;
set(handles.TimeText,'String',num2str(time));
if time == 0
    stop(handles.tmr)    
    % capture the image
    trigger(handles.video);
    while islogging(handles.video)
        % wait for logging to complete
    end
    data = getdata(handles.video);
    bounds = handles.captureArea;
    % get Image
    image = data(bounds(1,2):bounds(2,2),...
        bounds(1,1):bounds(2,1),1,1);    
    % process the image
    image = handCleanup(image);
    [image, blob_data, blob_names] = contourTrack(image);
    
    if numel(blob_data) ~= 0
        [blob, name] = filterBlobs(blob_data, blob_names);
        % Load stored blob parameters and names
        if(exist('storedBlobs.mat', 'file'))
            load('storedBlobs.mat', 'stored_params');
            load('storedBlobs.mat', 'stored_names');
        else
            error('Blob parameters not found.');
        end    

        % Detect Sign
        blobNorm = normalizeParams(blob, stored_params);
        knownNorm = normalizeParams(stored_params);
        [~, name] = detectSign(blobNorm, knownNorm, stored_names);

    else
        name = {' '};
    end
    
    text = get(handles.TextBox, 'String');
    set(handles.TextBox, 'String', strcat(text, name));
    set(handles.LastLetterText, 'String', name);
    % reset the timer    
    set(handles.TimeText, 'String', handles.ClockReset);
    start(handles.tmr);
    
end
guidata(handles.MainWindow, handles);


% --- Executes on button press in ResetButton.
function ResetButton_Callback(hObject, eventdata, handles)
% hObject    handle to ResetButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.TimeText, 'String', handles.ClockReset);
