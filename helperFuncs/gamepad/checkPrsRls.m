function [ psd, psdb, secs ] = checkPrsRls( gi, button, checkrls, limit )
%CHECKBUTTON check if the given button pressed
% Return the pressed button and the timestamp of pressing
% If checkrls is true, won't return until button released

switch nargin
    case 2
        checkrls = 1;
        limit = 0;
    case 3
        limit = 0;
end

psd = 0;
psdb = 0;
while ~psd
    
    if limit
        if GetSecs >= limit
            secs = limit;
            break
        end
    end
    
    if length(button) > 1
        for b = button
            if Gamepad('GetButton', gi, b)
                secs = GetSecs;
                psd = 1;
                psdb = b;
                break
            end
        end
    elseif length(button) == 1
        if Gamepad('GetButton', gi, button)
            secs = GetSecs;
            psd =1;
            psdb = button;
        end
    end
end

if checkrls
    btnpsd = psd;

    while btnpsd
        btnpsd = 0;
        if length(button) > 1
            for b = button
                if Gamepad('GetButton', gi, b)
                    btnpsd = 1;
                    break
                end
            end
        elseif length(button) == 1
            if Gamepad('GetButton', gi, button)
                btnpsd = 1;
            end
        end
    end
end

end

