function doNav()
% doNav()
%
% (Part of the Navigation Task Suite package)
% Navigation Task subscreen
%
% Presents the perceptual navigation task to the participant.
%
% (c) 2013 Nick Penaranda, GMU Arch Lab (ARG -- Dr. Carryl Baldwin)
    global exp;
    
    if(exp.redraw)
        visScale = 1.0;
        visRect = [ ...
            exp.navPosX - exp.mx * visScale, exp.navPosY - exp.my * visScale, ...
            exp.navPosX + exp.mx * visScale, exp.navPosY + exp.my * visScale];
        
        i=exp.nodeIndex;
        if(exp.path(i,4)==0) % Not yet seen
            if(IsInRect(exp.path(i,1),exp.path(i,2),visRect)) % Now seen
                exp.path(i,4) = 1; % Visible
                logEvent(sprintf('NavNodeFound,%d,%d',i,exp.path(i,3)));
            end
        end
        if(exp.nodeIndex > 0)
            workingPath = exp.path;
            workingPath(:,1) = workingPath(:,1) - exp.navPosX;
            workingPath(:,2) = workingPath(:,2) - exp.navPosY;

            curNode = workingPath(exp.nodeIndex,:);

            if(exp.nodeIndex > 1)
                prevNode = workingPath(exp.nodeIndex - 1, :);
            else
                prevNode = [];
            end

            if(exp.nodeIndex < length(workingPath))
                nextNode = workingPath(exp.nodeIndex+1,:);
            else
                nextNode = [];
            end

            % If previous node, draw line from that to curNode
            if(~isempty(prevNode))
                drawLine(prevNode,curNode);
            end

            % If there's a nextNode, draw line from curNode to that
            if(~isempty(nextNode))
                drawLine(curNode,nextNode);
            end

            % Draw the currentNode
            drawNode(curNode);

            % No button
            Screen('FillRect', exp.scr, [128 128 128], exp.navButtonNoRect);
            DrawFormattedText(exp.scr,'No',exp.navButtonNoRect(1) + 32, ...
                exp.navButtonNoRect(2) + 16, 255);

            % Yes button
            Screen('FillRect', exp.scr, [128 128 128], exp.navButtonYesRect);
            DrawFormattedText(exp.scr,'Yes',exp.navButtonYesRect(1) + 32, ...
                exp.navButtonYesRect(2) + 16, 255);

            Screen('FillRect', exp.scr, [128 0 0], exp.stopRect);
            Screen('FrameRect', exp.scr, 128, exp.stopRect, 1);
        end
        
        Screen('Flip', exp.scr);
        clearRedraw();
    end
    
    [x,y,buttons] = GetMouse(exp.scr);
    if(~any(buttons))
        if(exp.navDragging)
            exp.navDragging = false;
            logEvent(sprintf('NavDragEnd,%d,%d',exp.navPosX,exp.navPosY));
        end
        exp.clicked = false;
    elseif(~exp.clicked && IsInRect(x,y,exp.stopRect) && ~exp.navDragging) % Clicked in stop rect
        logEvent('RequestStop');
        doClick();
        exp.state = exp.STOP;
        
    elseif(~exp.clicked && IsInRect(x,y,exp.navButtonNoRect) && ~exp.navDragging) % Clicked negative
        exp.taskResponse = 'negative';
        expRedraw();

    elseif(~exp.clicked && IsInRect(x,y,exp.navButtonYesRect) && ~exp.navDragging) % Clicked positive
        exp.taskResponse = 'positive';
        expRedraw();

    elseif(~exp.navDragging && ~exp.clicked) % Not dragging and not clicked; start drag
        exp.navDragging = true;
        exp.navDragLastX = x;
        exp.navDragLastY = y;
        logEvent(sprintf('NavDragStart,%d,%d',exp.navPosX,exp.navPosY));
        
    elseif(~exp.clicked) % Dragging
        deltaX = x - exp.navDragLastX;
        deltaY = y - exp.navDragLastY;
        exp.navPosX = exp.navPosX - deltaX;
        exp.navPosY = exp.navPosY - deltaY;
        exp.navDragLastX = x;
        exp.navDragLastY = y;
        expRedraw();
    end
    
    if(~isempty(exp.taskResponse))
        consumeTaskResponse();
    end
    
    if(exp.nodeIndex > length(exp.path) && ~exp.pathComplete) % Complete
        logEvent('NavPathComplete');
        exp.pathComplete = true;
    end
end

function consumeTaskResponse()
    global exp;
    
    doClick();
    if(exp.path(exp.nodeIndex,4))
        if(exp.nodeIndex <= exp.nLevel) % Loading trial (should be negative)
            if(strcmp(exp.taskResponse,'negative'))
                isCorrect = 'correct';
            else
                isCorrect = 'incorrect';
            end
        else
            if(exp.path(exp.nodeIndex,3) == exp.path(exp.nodeIndex - exp.nLevel,3)) % Pos trial
                if(strcmp(exp.taskResponse,'negative'))
                    isCorrect = 'incorrect';
                else
                    isCorrect = 'correct';
                end
            else % Neg trial
                if(strcmp(exp.taskResponse,'negative'))
                    isCorrect = 'correct';
                else
                    isCorrect = 'incorrect';
                end
            end
        end
            
        logEvent(sprintf('TaskResponse,%s,%d,%s',exp.taskResponse,exp.path(exp.nodeIndex,3),isCorrect));
        exp.nodeIndex = exp.nodeIndex + 1;
    end
    exp.taskResponse = '';
end

function drawLine(n1,n2)
    global exp;
    
    Screen('DrawLine',exp.scr,128, ...
        n1(1) + exp.mx, n1(2) + exp.my, ...
        n2(1) + exp.mx, n2(2) + exp.my, ...
        exp.pathWeight);
end

function drawNode(n)
    global exp;
    
    Screen('FrameOval', exp.scr,255, ...
        [n(1) - exp.pathNodeOutlineSize + exp.mx, n(2) - exp.pathNodeOutlineSize + exp.my, ...
         n(1) + exp.pathNodeOutlineSize + exp.mx, n(2) + exp.pathNodeOutlineSize + exp.my], ...
         exp.pathNodeOutlineWeight, exp.pathNodeOutlineWeight);
    Screen('FillOval', exp.scr,exp.pathColors{n(3)}, ...
        [n(1) - exp.pathNodeSize + exp.mx, n(2) - exp.pathNodeSize + exp.my, ...
         n(1) + exp.pathNodeSize + exp.mx, n(2) + exp.pathNodeSize + exp.my]);
end
