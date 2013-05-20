function doStandby()
% doStandby()
%
% (Part of the Navigation Task Suite package)
% Standby or "Home" subscreen
%
% Displays two big buttons -- dismiss phone and enter navigation to
% trigger respective functions.  Small button in the lower right to exit
% (Future, non-development versions should remove that --NP)
%
% (c) 2013 Nick Penaranda, GMU Arch Lab (ARG -- Dr. Carryl Baldwin)
    global exp;
    
    PHONE_SCREEN_DURATION = 1.5; % Seconds
    
    if(exp.redraw)
        Screen('FillRect', exp.scr, exp.phoneColor, exp.phoneRect);
        Screen('FrameRect', exp.scr, 255, exp.phoneRect, 1);
        %Screen('DrawText', exp.scr, exp.phoneText, exp.phoneTextCoords(1),exp.phoneTextCoords(2), 255);
        DrawFormattedText(exp.scr, exp.phoneText, exp.phoneTextCoords(1), exp.phoneTextCoords(2), 255);

        Screen('FillRect', exp.scr, exp.navColor, exp.navRect);
        Screen('FrameRect', exp.scr, 255, exp.navRect, 1);
        %Screen('DrawText', exp.scr, exp.navText, exp.navTextCoords(1), exp.navTextCoords(2), 255);
        DrawFormattedText(exp.scr, exp.navText, exp.navTextCoords(1), exp.navTextCoords(2), 255);

        Screen('FillRect', exp.scr, [128 0 0], exp.stopRect);
        Screen('FrameRect', exp.scr, 128, exp.stopRect, 1);
        
        Screen('Flip', exp.scr);
        clearRedraw();
    end
    
    [x,y,buttons] = GetMouse(exp.scr);
    if(any(buttons))
        if(~exp.clicked && IsInRect(x,y,exp.phoneRect)) % Clicked in phone rect
            if(~exp.phoneRinging)
                doClick();
            else
                exp.ringDismiss = true;
            end
            exp.stateExpireTime = GetSecs() + PHONE_SCREEN_DURATION;
            exp.state = exp.PHONE;
            expRedraw();
        elseif(~exp.clicked && IsInRect(x,y,exp.navRect)) % Clicked in nav rect
            logEvent('NavigationEntered');
            exp.state = exp.NAV;
            doClick();
            expRedraw();
        elseif(~exp.clicked && IsInRect(x,y,exp.stopRect)) % Clicked in stop rect
            logEvent('RequestStop');
            doClick();
            exp.state = exp.STOP;
        end
    else
        exp.clicked = false;
    end
    
end