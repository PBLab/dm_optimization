function varargout = SIdmGUI(varargin)
% SIDMGUI MATLAB code for SIdmGUI.fig
%      SIDMGUI, by itself, creates a new SIDMGUI or raises the existing
%      singleton*.
%
%      H = SIDMGUI returns the handle to a new SIDMGUI or the handle to
%      the existing singleton*.
%
%      SIDMGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SIDMGUI.M with the given input arguments.
%
%      SIDMGUI('Property','Value',...) creates a new SIDMGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before SIdmGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to SIdmGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help SIdmGUI

% Last Modified by GUIDE v2.5 16-Sep-2019 11:27:33

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @SIdmGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @SIdmGUI_OutputFcn, ...
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


% --- Executes just before SIdmGUI is made visible.
function SIdmGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to SIdmGUI (see VARARGIN)
xlabel('Frame')
ylabel('Intensity')
setappdata(0,'handles',handles.axes1);

% Choose default command line output for SIdmGUI
handles.output = hObject;
% get handle to the controller
for i = 1:2:length(varargin)
    switch varargin{i}
        case 'controller'
            handles.controller = varargin{i+1};
        otherwise
            error('unknown input')
    end
end
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes SIdmGUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = SIdmGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% --- Executes during object creation, after setting all properties.
function etLogFileName_CreateFcn(hObject, eventdata, handles)
% hObject    handle to etLogFileName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in Start.
function Start_Callback(hObject, eventdata, handles)
% hObject    handle to Abort (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.controller.startGrabAcquisition();

% --- Executes on button press in Abort.
function Abort_Callback(hObject, eventdata, handles)
% hObject    handle to Start (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.controller.abortAcquisition();

% --- Executes during object creation, after setting all properties.
function axes1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axes1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate axes1
