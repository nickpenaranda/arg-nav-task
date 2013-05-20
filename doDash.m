function doDash()
% doDash()
%
% (Part of the Navigation Task Suite package)
% Alarm subscreen?  This will be refactored in future versions.
%
% (c) 2013 Nick Penaranda, GMU Arch Lab (ARG -- Dr. Carryl Baldwin)
    global exp;
    
    % Process alert requests
    if(exp.triggerAlert)
        PsychPortAudio('Start',exp.alertSlave);
        exp.dashTex = exp.alertTex;
        exp.redrawDash = true;
        exp.triggerAlert = false;
        exp.alertPresent = true;
        alertInfo = exp.alertConditions(exp.alertIndex,:);
        logEvent(sprintf('AlertOnset,%s,%s,%s', ...
            alertInfo{1},alertInfo{2},alertInfo{3}));
        %exp.nodeIndex = -1; % Clears nav task
        exp.redraw = true;
    elseif(exp.alertResponded)
        % consume alert response
        PsychPortAudio('Stop',exp.alertSlave);
        logEvent(['AlertDismissed,' exp.alertResponse]);
        exp.dashTex = exp.blankTex;
        exp.redrawDash = true;
        exp.alertResponded = false;
        exp.alertPresent = false;
        exp.alertResponse = '';
        resetTaskAndAlert();
    end
    
    if(exp.redrawDash)
        Screen('DrawTexture',exp.dashScr,exp.dashTex);
        Screen('Flip', exp.dashScr);
        exp.redrawDash = false;
    end
end

function resetTaskAndAlert()
    global exp;
    
    genNodes(50);
    exp.redraw = true;
    scheduleAlert(randi(length(exp.alertConditions)), 20 + (rand() * 10));
end