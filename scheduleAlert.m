% scheduleAlert( index, time )
%
% (Part of the Navigation Task Suite package)
% Prepares and schedules an alert to be played in the future.
%
% index             Index of alert to be passed to prepareAlert
% time              Time (s) in the future that this alert should be
%                   presented
%
% (c) 2013 Nick Penaranda, GMU Arch Lab (ARG -- Dr. Carryl Baldwin)
function scheduleAlert(index, time)
    global exp;
    exp.alertTriggerTime = GetSecs() + time;
    exp.triggerAlert = false;
    prepareAlert(index);
end