% This is for demostration

commandwindow;

[window, windowRect] = GetScreen([0 0 900 768]);
HideCursor;

isdialog = true;
filename = 'survey.csv';
ansNum = 4;
showQuestNum = 5;
[texture, paperRect, qRects, aRects, questH] = PrepareSurvey(window, windowRect, isdialog, filename, ansNum, showQuestNum);

Screen('DrawTextures', window, texture, [], paperRect, 0, 0);

Screen('Flip', window);

% set keys
upkey = KbName('UpArrow');
downkey = KbName('DownArrow');
leftkey = KbName('LeftArrow');
rightkey = KbName('RightArrow');
escapekey = KbName('ESCAPE');

questNum = size(qRects, 2);
selects = zeros([questNum, ansNum]);
currQ = 1;
currA = 0;
currRange = [1 showQuestNum];
offset = 0;


% wait for key response
while true    
    [keyDown, secs, keycode] = KbCheck;
    if keycode(escapekey)
        break
    elseif keycode(upkey)
        if currQ < 2
            currQ = 1;
        else
            currQ = currQ - 1;
        end
        currA = 0;
    elseif keycode(downkey)
        if currQ < questNum
            currQ = currQ + 1;
        end
        currA = 0;
    elseif keycode(leftkey)
        if currA < 2
            currA = 1;
        else
            currA = currA - 1;
        end
    elseif keycode(rightkey)
        if currA < ansNum
            currA = currA + 1;
        end
    else
        continue
    end

    % Draw to screen
    if currQ < currRange(1)
        offset = offset + 1;
        currRange = currRange - 1;
    elseif currQ > currRange(2)
        offset = offset - 1;
        currRange = currRange + 1;
    end
    newpaper = paperRect;
    newpaper(2:2:end) = newpaper(2:2:end) + offset * questH;
    Screen('DrawTextures', window, texture, [], newpaper, 0, 0);
    if currQ
        qrect = qRects(:, currQ);
        qrect(2:2:end) = qrect(2:2:end) + offset * questH;
        qcolor = [0 0 1 0.1];
        Screen('FillRect', window, qcolor, qrect);
    end
    if currA
        arect = aRects(:, currQ, currA);
        arect(2:2:end) = arect(2:2:end) + offset * questH;
        acolor = [1 0 0 0.1];
        Screen('FillRect', window, acolor, arect);
    end
    Screen('Flip', window);
    
    while keyDown
        [keyDown, secs, keycode] = KbCheck;
    end
end


%WaitSecs(5);
ShowCursor;