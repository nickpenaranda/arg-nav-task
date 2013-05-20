function results = NavSuite()
% results = NavSuite()
%
% (Part of the Navigation Task Suite package)
% The main loop function.  Handles all one-time calculations and pop-
% ulates much of the exp global variable.
%
% (c) 2013 Nick Penaranda, GMU Arch Lab (ARG -- Dr. Carryl Baldwin)
    global exp;
    results = {};
    
    maxTPS = 100;
    loopDelay = 1 / maxTPS;
    
    Screen('Preference', 'SkipSyncTests', 1);
    Screen('Preference', 'SuppressAllWarnings', true);

    % PTB init stuff
    AssertOpenGL;
    if(exp.DEBUG == true)
        [exp.scr,exp.scrRect] = Screen('OpenWindow', ...
            exp.SCREEN_NUM,[0, 0, 0],[32, 32, 800+32, 480+32]);
        
        [exp.dashScr,exp.alertScrRect] = Screen('OpenWindow', ...
            exp.ALERT_SCREEN_NUM,[0, 0, 0], [64, 64, 640+32, 480+32]);
    else
        [exp.scr,exp.scrRect] = Screen('OpenWindow',exp.SCREEN_NUM,[0, 0, 0],[]);
        [exp.dashScr,exp.alertScrRect] = Screen('OpenWindow',exp.ALERT_SCREEN_NUM,[0, 0, 0], []);
    end
    
    Screen('TextFont',exp.scr,'Arial');

    if(exp.DEBUG == true)
        ShowCursor('Hand',0);
    else
        HideCursor();
    end
    
    [exp.mx, exp.my] = RectCenter(exp.scrRect);
    
    % Load alarm/task data
    img = imread([exp.alertLocation 'No Vis.jpg']);
    exp.blankTex = Screen('MakeTexture',exp.dashScr,img);
    
    exp.dashTex = exp.blankTex;

    % One-time position calculations
    
    areaPadding = 32;
    exp.areaPadding = areaPadding;

    exp.clicked = false;
    exp.taskResponse = '';
    exp.taskResponded = false;
    
    exp.alertResponse = -1;
    exp.alertResponded = false;
    exp.alertPresent = false;
    
    stopSize = 24;
    exp.stopRect = [exp.scrRect(3) - stopSize, exp.scrRect(4) - stopSize, ...
                    exp.scrRect(3), exp.scrRect(4)];
    
    exp.navButtonWidth = exp.scrRect(4) / 4;
    exp.navButtonHeight = 48;
    
    exp.navButtonNo = [128 128 128];
    exp.navButtonNoRect = [ ...
        exp.mx - (exp.navButtonWidth * 1.5) - areaPadding, ...
        exp.scrRect(4) - areaPadding - exp.navButtonHeight, ...
        exp.mx - (exp.navButtonWidth * 0.5) - areaPadding, ...
        exp.scrRect(4) - areaPadding];

    exp.navButtonYes = [128 128 128];
    exp.navButtonYesRect = [ ...
        exp.mx + (exp.navButtonWidth * 0.5) + areaPadding, ...
        exp.scrRect(4) - areaPadding - exp.navButtonHeight, ...
        exp.mx + (exp.navButtonWidth * 1.5) + areaPadding, ...
        exp.scrRect(4) - areaPadding];
    
    % ===== EXPERIMENT PARAMETERS =====
    exp.pathColors = {
        [178 220 239] % Light blue
        [49 162 242] % Medium blue
        [163 206 39] % Light green
        [68 137 26] % Dark green
        [224 111 139] % Pink
        [190 38 51] % Red
        [247 226 107] % Beige
        [235 137 49] % Orange
        [157 157 157] % Gray
    };

    % path graphical parameters
    exp.pathNodeSize = 8;
    exp.pathNodeOutlineSize = 11;
    exp.pathNodeOutlineWeight = 3;
    exp.pathWeight = 2;
    
    % probability of a positive trial
    exp.probPositive = 0.33;
    
    % maximum number of nodes to generate between alert presentations
    % you shouldn't need to change this
    exp.nodesPerTrial = 50;
    
    % Alert data (these files should be in the alerts subdirectory)
    % First column are .jpg (image) files; second column are .wav (sound)
    % files.
    exp.alertConditions = { ...
        '', 'High Aud.wav'; ...
        '', 'Low Aud.wav'; ...
        '', 'High Tac.wav'; ...
        '', 'Low Tac.wav'; ...
        '', 'High TacAud.wav'; ...
        '', 'Low TacAud.wav'};
    
    % Number of times to repeat alerts
    exp.alertBlocks = 2;
    
    % Alert timing parameters
    % Formula is as follows:
    %
    % nextAlert = now + base + (jitter * random( 0.0 -> 1.0 ))
    %
    % i.e., the next alert will happen in at least (base) seconds plus
    % UP TO jitter seconds.
    exp.initialAlertDelayBase = 30;
    exp.initialAlertDelayJitter = 10;
    exp.alertDelayBase = 10;
    exp.alertDelayJitter = 10;
    
    % <DO NOT EDIT>
    exp.alertOrder = [];
    for i=1:exp.alertBlocks
        order = shuffle(1:size(exp.alertConditions,1));
        exp.alertOrder = [exp.alertOrder order];
    end
    exp.orderIndex = 1;
    % </DO NOT EDIT>
    
    % Create nodes and reset nav task state
    genNodes(exp.nodesPerTrial);
    
    % Schedule the first alert; future alerts are scheduled dynamically
    % after each alert response
    scheduleAlert(exp.alertOrder(1), ...
        exp.initialAlertDelayBase + rand() * exp.initialAlertDelayJitter);
    
    logEvent(sprintf('StartExperiment,%s,%d',exp.participantNumber,exp.nLevel));
    
    % Button labels used in serialReceive.m
    % These should reflect your mappings in the Logitech Profiler
    % on the sim computer -- OR ELSE!!!
    exp.btn1Label = 'x';
    exp.btn2Label = 'square';
    exp.btn3Label = 'round';
    exp.btn4Label = 'triangle';
    exp.brakeLabel = 'brake'; % DO NOT CHANGE

    % Main loop
    while(exp.state ~= exp.STOP)
        timeNow = GetSecs();
        lastLoop = timeNow;
        if(exp.alertTriggerTime > 0 && timeNow >= exp.alertTriggerTime)
            exp.alertTriggerTime = -1;
            exp.triggerAlert = true;
        end
        doDash();
        doNav();
        WaitSecs('UntilTime',lastLoop + loopDelay);
        drawnow; % Don't forget this or else program locks MATLAB!!!
    end
    
    logEvent('StopExperiment');
    disp('Stopping.');
    Screen('CloseAll');
    ShowCursor();
    
    % Flush and close data files, if needed.
    
    Screen('Preference', 'SuppressAllWarnings', false);

end