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

% Last Modified by GUIDE v2.5 14-Apr-2022 22:55:19

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

setappdata(0,'fileName',0);
setappdata(0,'filePath',0);
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

%pepare fitness axis
setappdata(0,'axes_fitness',handles.axes_fitness);
set(handles.axes_fitness,'NextPlot','add')
xlabel(handles.axes_fitness,'Image #')
ylabel(handles.axes_fitness,'Fitness')
%prepare axis image
setappdata(0,'axes_image_data',handles.axes_image_data);
setappdata(0,'axes_image_best',handles.axes_image_best);
setappdata(0,'axes_image_diff',handles.axes_image_diff);
axis(handles.axes_image_data,'off');
axis(handles.axes_image_best,'off');
axis(handles.axes_image_diff,'off');
%% store user function handle
h2pop = findobj(gcf,'Tag','popupmenu_select_fitness_fun');
func_string = get(h2pop,'String');
val = get(h2pop,'Value');
selected_fitness_function = str2func(func_string{val});
setappdata(0,'selected_fitness_function',selected_fitness_function);

%% Update handles structure
guidata(hObject, handles);

%% add directories to path
fprintf('\n Initializing GUI, adding folder to path')
path_names_to_add = {'DM','Fitness','GA','GUI_utils','Utils',...
    'Fitness/MEAN','Fitness/PIQE','Fitness/FWHM'};
path_to_mfile = mfilename('fullpath');
path_to_mfile = fileparts(path_to_mfile);

for this_folder = path_names_to_add
    addpath(fullfile(path_to_mfile,cell2mat(this_folder)))
end

%% update user functions

% UIWAIT makes SIdmGUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);
setup_user_functions

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
%handles.controller.startGrabAcquisition();
getappdata(0)
evalin('base','hSI.startLoop')

% --- Executes on button press in Abort.
function Abort_Callback(hObject, eventdata, handles)
% hObject    handle to Start (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%handles.controller.abortAcquisition();
evalin('base','hSI.abort')

% --- Executes during object creation, after setting all properties.
function axes_fitness_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axes_fitness (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate axes_fitness

% --- Executes on button press in select.
function select_Callback(hObject, eventdata, handles)
% hObject    handle to select (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[fileName,filePath] = uigetfile('*.mat');
setappdata(0,'fileName',fileName);
setappdata(0,'filePath',filePath);

guidata(hObject,handles)


% --- Executes on button press in clear.
function clear_Callback(hObject, eventdata, handles)
% hObject    handle to clear (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
cla



function edit_generation_number_Callback(hObject, eventdata, handles)
% hObject    handle to edit_generation_number (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
generationsNum = str2double(get(hObject,'String'));
setappdata(0,'generationsNum',generationsNum);

guidata(hObject,handles)

% Hints: get(hObject,'String') returns contents of edit_generation_number as text
%        str2double(get(hObject,'String')) returns contents of edit_generation_number as a double


% --- Executes during object creation, after setting all properties.
function edit_generation_number_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_generation_number (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
generationsNum = str2double(get(hObject,'String'));
setappdata(0,'generationsNum',generationsNum);
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_population_size_Callback(hObject, eventdata, handles)
% hObject    handle to edit_population_size (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
popSize = str2double(get(hObject,'String'));
setappdata(0,'popSize',popSize);

guidata(hObject,handles)
% Hints: get(hObject,'String') returns contents of edit_population_size as text
%        str2double(get(hObject,'String')) returns contents of edit_population_size as a double


% --- Executes during object creation, after setting all properties.
function edit_population_size_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_population_size (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
popSize = str2double(get(hObject,'String'));
setappdata(0,'popSize',popSize);
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_frames_per_image_Callback(hObject, eventdata, handles)
% hObject    handle to edit_frames_per_image (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
framesPerImg = str2double(get(hObject,'String'));
setappdata(0,'framesPerImg',framesPerImg);

guidata(hObject,handles)
% Hints: get(hObject,'String') returns contents of edit_frames_per_image as text
%        str2double(get(hObject,'String')) returns contents of edit_frames_per_image as a double


% --- Executes during object creation, after setting all properties.
function edit_frames_per_image_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_frames_per_image (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

framesPerImg = str2double(get(hObject,'String'));
setappdata(0,'framesPerImg',framesPerImg);

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_channel_num_Callback(hObject, eventdata, handles)
% hObject    handle to edit_channel_num (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
channel = str2double(get(hObject,'String'));
setappdata(0,'channel',channel);

guidata(hObject,handles)
% Hints: get(hObject,'String') returns contents of edit_channel_num as text
%        str2double(get(hObject,'String')) returns contents of edit_channel_num as a double


% --- Executes during object creation, after setting all properties.
function edit_channel_num_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_channel_num (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
channel = str2double(get(hObject,'String'));
setappdata(0,'channel',channel);
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu_select_fitness_fun.
function popupmenu_select_fitness_fun_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu_select_fitness_fun (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

func_string = get(hObject,'String');
val = get(hObject,'Value');
selected_fitness_function = str2func(func_string{val});
setappdata(0,'selected_fitness_function',selected_fitness_function);

%% Update handles structure
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function popupmenu_select_fitness_fun_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu_select_fitness_fun (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
setappdata(0,'func','PIQE');
% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in updateMirror.
function updateMirror_Callback(hObject, eventdata, handles)
% hObject    handle to updateMirror (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[vecName,vecPath] = uigetfile('*.mat');
setappdata(0,'vecName',vecName);
setappdata(0,'vecPath',vecPath);

guidata(hObject,handles)


% --- Executes during object creation, after setting all properties.
function axes_image_data_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axes_image_data (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% setappdata(0,handles)


% Hint: place code in OpeningFcn to populate axes_image_data



function edit_treshold_Callback(hObject, eventdata, handles)
% hObject    handle to edit_treshold (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

treshold = str2double(get(hObject,'String'));
setappdata(0,'treshold',treshold);

guidata(hObject,handles)

% Hints: get(hObject,'String') returns contents of edit_treshold as text
%        str2double(get(hObject,'String')) returns contents of edit_treshold as a double


% --- Executes during object creation, after setting all properties.
function edit_treshold_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_treshold (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

treshold = str2double(get(hObject,'String'));
setappdata(0,'treshold',treshold);

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_width_Callback(hObject, eventdata, handles)
% hObject    handle to edit_width (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

width = str2double(get(hObject,'String'));
setappdata(0,'width',width);

guidata(hObject,handles)

% Hints: get(hObject,'String') returns contents of edit_width as text
%        str2double(get(hObject,'String')) returns contents of edit_width as a double


% --- Executes during object creation, after setting all properties.
function edit_width_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_width (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

width = str2double(get(hObject,'String'));
setappdata(0,'width',width);

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_expected_elements_Callback(hObject, eventdata, handles)
% hObject    handle to edit_expected_elements (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

expect_elem = str2double(get(hObject,'String'));
setappdata(0,'expect_elem',expect_elem);

guidata(hObject,handles)

% Hints: get(hObject,'String') returns contents of edit_expected_elements as text
%        str2double(get(hObject,'String')) returns contents of edit_expected_elements as a double


% --- Executes during object creation, after setting all properties.
function edit_expected_elements_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_expected_elements (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

expect_elem = str2double(get(hObject,'String'));
setappdata(0,'expect_elem',expect_elem);

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_image_dim_Callback(hObject, eventdata, handles)
% hObject    handle to edit_image_dim (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

image_dim = str2double(get(hObject,'String'));
setappdata(0,'image_dim',image_dim);

guidata(hObject,handles)

% Hints: get(hObject,'String') returns contents of edit_image_dim as text
%        str2double(get(hObject,'String')) returns contents of edit_image_dim as a double


% --- Executes during object creation, after setting all properties.
function edit_image_dim_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_image_dim (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

image_dim = str2double(get(hObject,'String'));
setappdata(0,'image_dim',image_dim);

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes during object deletion, before destroying properties.
function uipanel6_DeleteFcn(hObject, eventdata, handles)
% hObject    handle to uipanel6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



