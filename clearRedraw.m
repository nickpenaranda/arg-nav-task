function clearRedraw()
% clearRedraw()
%
% (Part of the Navigation Task Suite package)
% Helper function that clears the redraw flag. Call this after rendering
% within any NavSuite subscreen (e.g., doNav, doStandby, etc...)
%
% (c) 2013 Nick Penaranda, GMU Arch Lab (ARG -- Dr. Carryl Baldwin)
    global exp;
    exp.redraw = false;
end