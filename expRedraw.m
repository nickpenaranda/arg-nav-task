function expRedraw()
% expRedraw()
%
% (Part of the Navigation Task Suite package)
% Utility function that sets the redraw flag to notify subscreens to render
% (sparsely)
%
% (c) 2013 Nick Penaranda, GMU Arch Lab (ARG -- Dr. Carryl Baldwin)
    global exp;
    exp.redraw = true;
end