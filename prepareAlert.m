function prepareAlert( alertIndex )
% prepareAlert( alertIndex)
%
% (Part of the Navigation Task Suite package)
% Loads resources necessary to present the alert at the specified index
% (see ExpListener.m for the alert data array)
%
% alertIndex                row index of alert data to prepare
%
% (c) 2013 Nick Penaranda, GMU Arch Lab (ARG -- Dr. Carryl Baldwin)
    global exp;
    
    exp.alertIndex = alertIndex;
    
    imgFile = exp.alertConditions{alertIndex,1};
    sndFile = exp.alertConditions{alertIndex,2};
    
    if(~isempty(imgFile))
       img = imread([exp.alertLocation imgFile]);
        exp.alertTex = Screen('MakeTexture', exp.dashScr, img);
    else
        exp.alertTex = exp.blankTex;
    end

    if(~isempty(sndFile))
       snd = wavread([exp.alertLocation sndFile],'double')';
       PsychPortAudio('FillBuffer',exp.alertSlave,snd);
    end

    %logEvent(sprintf('AlertPrepared,%d',alertIndex));
end

