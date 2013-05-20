function varargout = ExpListener(varargin)
% varargout = ExpListener(varargin)
%
% (Part of the Navigation Task Suite package)
% Launches the experiment listener.  This is the GUI that maintains
% state outside of the PTB experiment window.  Close this to force the
% experiment to end and finalize devices and logs.
%
% (c) 2013 Nick Penaranda, GMU Arch Lab (ARG -- Dr. Carryl Baldwin)
%
% (auto-generated annotation below)
% ----
% EXPLISTENER M-file for ExpListener.fig
%      EXPLISTENER, by itself, creates a new EXPLISTENER or raises the existing
%      singleton*.
%
%      H = EXPLISTENER returns the handle to a new EXPLISTENER or the handle to
%      the existing singleton*.
%
%      EXPLISTENER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in EXPLISTENER.M with the given input arguments.
%
%      EXPLISTENER('Property','Value',...) creates a new EXPLISTENER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ExpListener_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ExpListener_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ExpListener

% Last Modified by GUIDE v2.5 20-May-2013 09:36:09

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ExpListener_OpeningFcn, ...
                   'gui_OutputFcn',  @ExpListener_OutputFcn, ...
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

function ExpListener_OpeningFcn(hObject, eventdata, handles, varargin)
    global exp;
    
    % ---------- Program parameters ----------
    exp.DEBUG = false;
    PORT = 'COM1';
    exp.SCREEN_NUM = 2;
    exp.ALERT_SCREEN_NUM = 1;
    % ---------- Program parameters ----------
    
    exp.alertLocation = 'alerts\\';
    exp.wavLocation = 'sounds\\';

    % Global state stuff (exp.state)
    exp.STANDBY = 0;
    exp.NAV = 1;
    exp.PHONE = 2;
    exp.STOP = 3;
    
    % Serial port init stuff
    exp.serial = serial(PORT);
    set(exp.serial,'BytesAvailableFcnMode','terminator');
    set(exp.serial,'BytesAvailableFcn',@serialReceive);
    
    % Audio stuff
    InitializePsychSound;
    exp.audio = PsychPortAudio('Open',[],9,1,44100,2);
    PsychPortAudio('Start',exp.audio);
    
    % Create audio slaves
    exp.ringSlave = PsychPortAudio('OpenSlave',exp.audio,1,2,[1 2]);
    exp.ringTone = wavread([exp.wavLocation 'ringtone.wav'],'double')';
    PsychPortAudio('FillBuffer',exp.ringSlave,exp.ringTone);
    
    exp.clickSlave = PsychPortAudio('OpenSlave',exp.audio,1,2,[1 2]);
    exp.click = wavread([exp.wavLocation 'blip_click.wav'],'double')';
    PsychPortAudio('FillBuffer',exp.clickSlave,exp.click);
    
    exp.alertSlave = PsychPortAudio('OpenSlave',exp.audio,1,2,[1 2]);

    exp.participantNumber = '0';
    exp.nLevel = 1;
    exp.logFile = -1;
    exp.startTime = GetSecs();
    
    % Phone state
    exp.ringAt = GetSecs();
    exp.ringScheduled = false;
    exp.ringDismiss = false;
    exp.phoneRinging = false;
    
    % Dash state
    exp.triggerAlert = false;
    exp.alertResponded = false;
    exp.redrawDash = true;
    
    exp.state = exp.STOP;
    
    handles.output = hObject;
    guidata(hObject, handles);

function varargout = ExpListener_OutputFcn(hObject, eventdata, handles) 
    varargout{1} = handles.output;

function checkListen_Callback(hObject, eventdata, handles)
    global exp;
    state = get(hObject,'Value') == 1;
    if(state) % Listening turned on
        disp(['Opening ' get(exp.serial,'Port') '...']);
        fopen(exp.serial);
    else
        disp(['Closing ' get(exp.serial,'Port') '...']);
        fclose(exp.serial);
    end
    
function btnStartTask_Callback(hObject, eventdata, handles)
    global exp;

    exp.state = exp.STANDBY;
    exp.stateExpireTime = GetSecs();
    expRedraw();

    % Run the task front-end
    NavSuite();
    
function editParticipantNum_Callback(hObject, eventdata, handles)
    global exp;
    exp.participantNumber = get(hObject,'String');
    
function editParticipantNum_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end


function btnDebug_Callback(hObject, eventdata, handles)
    global exp;
    exp.state = exp.STOP;
    keyboard;


function figure1_CloseRequestFcn(hObject, eventdata, handles)
    global exp;
    
    if(exp.state ~= exp.STOP)
        disp('**** Shut down the task first! ****');
    else
        fclose(exp.serial);
        fclose('all');
        PsychPortAudio('Close');
        % Hint: delete(hObject) closes the figure
        delete(hObject);
    end



function editNLevel_Callback(hObject, eventdata, handles)
    global exp;
    exp.nLevel = str2double(get(hObject,'String'));

function editNLevel_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
