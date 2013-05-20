function doClick()
% doClick()
%
% (Part of the Navigation Task Suite package)
% Plays a click sound and sets a flag to enable click limiting
%
% (c) 2013 Nick Penaranda, GMU Arch Lab (ARG -- Dr. Carryl Baldwin)
    global exp;
    exp.clicked = true;
    PsychPortAudio('Stop',exp.clickSlave);
    PsychPortAudio('Start',exp.clickSlave);
end

