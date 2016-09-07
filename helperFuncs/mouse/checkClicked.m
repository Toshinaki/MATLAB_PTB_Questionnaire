function [  ] = checkClicked( window )
%CHECKCLICKED Check if any key of mouse is clicked and released

while true
    
    [~,~, buttons] = GetMouse(window);
    if any(buttons)
        while any(buttons)
            [~,~, buttons] = GetMouse(window);
        end
        break
    end
end
end

