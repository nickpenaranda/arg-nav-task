function serialReceive(obj, event)
% serialReceive( obj, event )
%
% (Part of the Navigation Task Suite package)
% Serial interface callback function.  This function defines the imperative
% commands that the navigation task suite can respond to.  See
% ExpListener.m for serial port setup defaults
%
% (c) 2013 Nick Penaranda, GMU Arch Lab (ARG -- Dr. Carryl Baldwin)
    global exp;
    
    cmd = fscanf(obj, '%d\n');
    if(exp.alertPresent && cmd <= 16)
        exp.alertResponded = true;
        switch(cmd)
            case 1
                exp.alertResponse = 'x';
            case 2
                exp.alertResponse = 'square';
            case 4
                exp.alertResponse = 'round';
            case 8
                exp.alertResponse = 'triangle';
            case 16
                exp.alertResponse = 'brake';
            otherwise
                exp.alertResponse = 'unknown';
        end
        logEvent(['ResponseReceived,',exp.alertResponse]);
    elseif(cmd == 32) % Right shoulder
        exp.taskResponded = true;
        exp.taskResponse = 'positive';
        logEvent('TaskResponseReceived,positive');
    elseif(cmd == 64) % Left shoulder
        exp.taskResponded = true;
        exp.taskResponse = 'negative';
        logEvent('TaskResponseReceived,negative');
    end
    %disp(['(DEBUG/serialReceive) Command: ' num2str(cmd)]);
end