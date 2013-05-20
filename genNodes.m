function genNodes(length)
    global exp;

    last = [0, 0];
    
    for i=1:length
        if(rand() >= 0.5) 
            signX = 1;
        else
            signX = -1;
        end
        
        if(rand() >= 0.5) 
            signY = 1;
        else
            signY = -1;
        end
        
        exp.path(i,1) = last(1) + signX * (exp.mx + (exp.mx * 2 * rand()));
        exp.path(i,2) = last(2) + signY * (exp.my + (exp.my * 2 * rand()));
        
        nCols = size(exp.pathColors,1);
        if(i <= exp.nLevel)
            exp.path(i,3) = randi(nCols); % This should be 9
        else
            if(rand() > exp.probPositive)
                colPool = 1:nCols;
                colPool(colPool == exp.path(i - exp.nLevel,3)) = [];
                exp.path(i,3) = colPool(randi(nCols - 1));
            else
                exp.path(i,3) = exp.path(i - exp.nLevel,3);
            end
        end
        last = exp.path(i,:);
    end
    
    exp.path(:,4) = 0;
    
    exp.pathComplete = false;
    exp.navPosX = exp.path(1,1);
    exp.navPosY = exp.path(1,2);
    exp.nodeIndex = 1;
    exp.navDragging = false;
    exp.navDragLastX = 0;
    exp.navDragLastY = 0;
end