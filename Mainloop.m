% The full course of an experiment

commandwindow;
clearvars;

% Add current folder and all sub-folders
addpath(genpath(pwd));

%--------------------------------------------------------------------------
%                       Global variables
%--------------------------------------------------------------------------
global window  windowRect fontsize xCenter;



%--------------------------------------------------------------------------
%                       Screen initialization
%--------------------------------------------------------------------------

% First create the screen for simulation displaying
% Using function prepareScreen.m
% This returned vbl may not be precise; flip again to get a more precise one
% This screen size is for test
[window, windowRect, white, black, vbl, ifi] = prepareScreen([0 0 900 768]);
HideCursor;

%______________________________________________________________
%=====================================================
%                       Section one
%______________________________________________________________

%=====================================================
%                       Preparation of Section one

%=====================================================
%                       Execution of Section one

%=====================================================
%                       Cleanup of Section one



%______________________________________________________________
%=====================================================
%                       Section two -- Survey
%______________________________________________________________

%=====================================================
%                       Preparation of Section two

% Define some DEFAULT values
isdialog = true; % Change this value to determine whether to use dialog
filename = 'survey.csv'; % The file name of survey to run; will open browser if not exists
survey_type = 'likert'; % Type of the survey, can be "question", "likert"
questNum = 10; % Number of questions in this survey
ansNum = 5; % Number of answers of each question
showQuestNum = 10; % Number of questions to display in one screen; you may need to try few times to get best display
respdevice = 'game'; % The way participants take the survey; could be "key", "mouse", "game"

% Prepare survey texture for later drawing; the file is loaded inside
% prepareSurvey.m; for the detail of the csv file's structure, see loadSurvey.m
[paperTexture, paperRect, questH, ansH, questYs, ansYs, instruc] = prepareSurvey(isdialog, filename, survey_type, questNum, ansNum, showQuestNum);

% Prepare INSTRUCTIONS
% Besides instruction from the file, the instruction of how to play with
% the survey is also displayed
% Three ways: keyboard, mouse, and gamepad
% Instruction will be different depending on the device you choose
[instruc, ~] = breakLong(instruc, 60);
deviceInstruc = getInstruc(respdevice);

% Set FONT for instructions
Screen('Textsize', window, fontsize);
Screen('TextFont', window, 'Courier');

% COLOR settings
% Set color for identifying currently focused question and answer
% and selected answer
qcolor = [0 0 1 0.1];
acolor = [1 0 0 0.5];
scolor = [0 1 0 0.2];

% Response DEVICE settings
switch respdevice
    case 'key'
        % Key settings
        upkey = KbName('UpArrow');
        downkey = KbName('DownArrow');
        leftkey = KbName('LeftArrow');
        rightkey = KbName('RightArrow');
        escapekey = KbName('ESCAPE');
        spacekey = KbName('space');
    case 'game'
        % Gamepad settings
        % These may different in your pc and gamepad
        %Axes:                                                                 Buttons:
        %10: up down                                                     1: A
        %9: left right                                                      2: B
        %8: right trigger                                               3: X
        %7: right stick up down                                  4: Y
        %6: right stick left right                                5: LB
        %5: left trigger                                                 6: RB
        %4: left stick up down                                    7: BACK
        %3: left stick left right                                  8: START
        %2: right trigger (change slowly)              9: Icon
        %1: right stick up down (change is cons)10: left stick
        %                                                                            11: right stick
        GamepadName = 'Logitech Gamepad F310';
        gi = Gamepad('GetGamepadIndicesFromNames', GamepadName);
        selectButton = 2;
        movePre = 5;
        moveNxt = 6;
        btns = [selectButton movePre moveNxt];
        switch survey_type
            case 'question' % up, down for answers
                ansDirect = 10;
            case 'likert' % left, right for answers
                ansDirect = 9;
        end
end

% Base rect for questions and answers
baseQRect = [0 0 595 questH];
if strcmp(survey_type, 'likert')
    aCenters = linspace(595/(ansNum*2), 595*((ansNum-0.5)/ansNum), ansNum) + (xCenter-595/2);
end

% Keep a record of selections during loop
% These will be used to draw marks
selects = zeros([questNum, ansNum]);
currQ = 1;
currA = 0;
% To keep the marks in right place while scrolling screen
switch respdevice
    case 'mouse'
        offsetRange = [showQuestNum-questNum 0];
    otherwise
        currRange = [1 showQuestNum];
end
offset = 0;


% Record selected rects here
seleRects = nan(4, questNum); % This is for drawing
tempRects = nan(4, questNum); % This is for recording


%=====================================================
%                       Execution of Section two

% First draw instructions
Screen('FillRect', window, 1, paperRect);
[~, ny] = DrawFormattedText(window, instruc, 'center', questH, 0);
DrawFormattedText(window, deviceInstruc, 'center', ny+questH, 0);
Screen('Flip', window);

% Wait for 10 secs here for participants to read the instruction before
% check for any input
WaitSecs(1);
switch respdevice
    
    case 'mouse'
        ShowCursor;
        %---------- This is for mouse------------------------------------
        while true
            % Check for mouse click; if clicked, approach to next
            [x, y, buttons] = GetMouse(window);
            if any(buttons)
                while any(buttons) % loop until key realeased
                    [x, y, buttons] = GetMouse(window);
                end
                break
            end
        end
        
        % Show the survey
        Screen('DrawTextures', window,paperTexture, [], paperRect, 0, 0);
        Screen('Flip', window);
        
        % Start loop to monitor the mouse position and check for click
        while true
            % Get current coordinates of mouse
            [x, y, buttons] = GetMouse(window);
            
            % Don't let the mouse exceed our paper
            x = max((xCenter - 595/2), x);
            x = min((xCenter + 595/2), x);
            
            % Scroll the paper
            % Since GetMouseWheel is not supported in linux,
            % I'll use something like hot corners to scroll the paper
            if y > windowRect(4)-2 && offset > offsetRange(1)
                offset = offset - 1;
                SetMouse(x, y-50);
            elseif y < windowRect(2) + 2 && offset < offsetRange(2)
                offset = offset + 1;
                SetMouse(x, y+50);
            end
            
            % Move the survey texture with the offset
            newpaper = paperRect;
            newpaper(2:2:end) = newpaper(2:2:end) + offset * questH;
            Screen('DrawTextures', window, paperTexture, [], newpaper, 0, 0);
            
            
            
            % Find the nearest question from mouse
            [~, newcurrQ] = min(abs(questYs+offset*questH - y));
            if newcurrQ ~= currQ
                currA = 0;
            end
            currQ = newcurrQ;
            
            currY = questYs(currQ) + offset * questH;
            qrect = CenterRectOnPointd(baseQRect, xCenter, currY);
            Screen('FillRect', window, qcolor, qrect); % draw a rect over the question
            
            % Find the nearest answer from mouse
            switch survey_type
                case 'question'
                    currAYs = ansYs(currQ, :) + offset*questH;
                    if y >= currAYs(1) - ansH(currQ, 1)/2 && y <= currAYs(end) + ansH(currQ, end)
                        [~, currA] = min(abs(currAYs - y));
                        currY = ansYs(currQ, currA);
                        arect = CenterRectOnPointd([0 0 595 ansH(currQ, currA)], xCenter, currY);
                    else
                        currA = 0;
                    end
                case 'likert'
                    currAYs = ansYs(currQ) + offset*questH;
                    if y >= currAYs - ansH/2 && y <= currAYs + ansH/2
                        [~, currA] = min(abs(aCenters - x));
                        currY = ansYs(currQ);
                        arect = CenterRectOnPointd([0 0 round(595 / ansNum) fontsize], aCenters(currA), currY);
                    else
                        currA = 0;
                    end
            end
            
            if currA % If any answer gets hovered
                if find(buttons) % And if any button gets clicked
                    tempRects(:, currQ) = arect;
                    selects(currQ, :) = 0;
                    selects(currQ, currA) = 1;
                end
                arect(2:2:end) = arect(2:2:end) + offset * questH;
                Screen('FrameRect', window, acolor, arect); % draw a rect over the answer
            end
            % Draw rects to identify selected answers
            k = find(selects);
            if ~isempty(k) % check if any answer been selected
                seleRects = tempRects;
                seleRects(2:2:end, :) = seleRects(2:2:end, :) + offset * questH;
                Screen('FillRect', window, scolor, seleRects);
            end
            
            Screen('Flip', window);
            
            % If all questions have been answered, quit the survey after 3 secs
            if size(k, 1) == questNum
                WaitSecs(3);
                break
            end
            
            % Do not go back until all buttons are released
            while find(buttons)
                [x, y, buttons] = GetMouse(window);
            end
            
        end
        
case 'key'
        %---------- This is for keyboard------------------------------------
        while true
            [keyDown, secs, keycode] = KbCheck;
            if keycode(spacekey) % Start loop if space pressed
                while keyDown % loop until key realeased; in fact keyboard condition doese not need for this; cause only when a question and an answer is hovered does space make a choice
                    [keyDown, secs, keycode] = KbCheck;
                end
                break
            end
        end
        
        % Show the survey
        Screen('DrawTextures', window,paperTexture, [], paperRect, 0, 0);
        Screen('Flip', window);
        
        % Start loop to check for keyboard input
        while true
            [keyDown, secs, keycode] = KbCheck;
            if ~keyDown
                continue
            end
            k = find(keycode);
            switch k
                case spacekey % space pressed
                    if currQ && currA % when both question and answer is focused
                        selects(currQ, :) = 0;
                        selects(currQ, currA) = 1; % then record that selection
                    end
                case upkey % up pressed
                    if currQ > 1 % current focusing question is the 1st one then don't change focus
                        currQ = currQ - 1; % otherwise move focus 1 question up
                    end
                    currA = 0; % and set the current focusing answer to nothing
                case downkey % down pressed
                    if currQ < questNum % same thing as upkey
                        currQ = currQ + 1;
                    end
                    currA = 0;
                case leftkey % left
                    if currA > 1
                        currA = currA - 1;
                    end
                case rightkey % right
                    if currA < ansNum
                        currA = currA + 1;
                    end
                otherwise % no meaningful key pressed, then go back to the start point of the loop
                    continue
            end
            
            % Draw to screen based on the input
            % Check if current focusing question is out of the range that can be
            % shown in one screen, and set the offset
            if currQ < currRange(1)
                offset = offset + 1;
                currRange = currRange - 1;
            elseif currQ > currRange(2)
                offset = offset - 1;
                currRange = currRange + 1;
            end
            
            % Move the survey texture with the offset
            newpaper = paperRect;
            newpaper(2:2:end) = newpaper(2:2:end) + offset * questH;
            Screen('DrawTextures', window, paperTexture, [], newpaper, 0, 0);
            
            if currQ % A question is focused; this is always true
                currY = questYs(currQ) + offset * questH;
                qrect = CenterRectOnPointd(baseQRect, xCenter, currY);
                Screen('FillRect', window, qcolor, qrect); % draw a rect over the question
            end
            if currA % An answer is focused; the space key must be pressed to show the rect
                switch survey_type
                    case 'question'
                        currY = ansYs(currQ, currA);
                        arect = CenterRectOnPointd([0 0 595 ansH(currQ, currA)], xCenter, currY);
                    case 'likert'
                        currY = ansYs(currQ);
                        arect = CenterRectOnPointd([0 0 round(595 / ansNum) fontsize], aCenters(currA), currY);
                end
                if k == spacekey
                    tempRects(:, currQ) = arect;
                end
                arect(2:2:end) = arect(2:2:end) + offset * questH;
                Screen('FrameRect', window, acolor, arect); % draw a rect over the hovering answer
            end
            
            % also draw the selected answers
            k = find(selects);
            if ~isempty(k) % check if any answer been selected
                seleRects = tempRects;
                seleRects(2:2:end, :) = seleRects(2:2:end, :) + offset * questH;
                Screen('FillRect', window, scolor, seleRects);
            end
            
            Screen('Flip', window);
            
            % If all questions have been answered, quit the survey after 3 secs
            if size(k, 1) == questNum
                WaitSecs(3);
                break
            end
            
            % Do not go back until all keys are released
            while keyDown
                [keyDown, secs, keycode] = KbCheck;
            end
        end
        
    case 'game'
        %---------- This is for gamepad------------------------------------
        % If the button (in this case 2) pressed, go to the loop
        while true
            if Gamepad('GetButton', gi, selectButton)
                break
            end
        end
        
        while true
            % Check for buttons; if no buttons pressed, keep checking
            while true
                % Check if any button gets pressed
                btnpressed = 0;
                isselect = 0;
                
                for b = btns
                    if Gamepad('GetButton', gi, b)
                        btnpressed = 1;
                        switch b
                            case 2 % B
                                if currQ && currA % when both question and answer is focused
                                    isselect = 1;
                                    selects(currQ, :) = 0;
                                    selects(currQ, currA) = 1; % then record that selection
                                end
                            case 5 % LB
                                if currQ > 1
                                    currQ = currQ - 1;
                                    currA = 0;
                                end
                            case 6 % RB
                                if currQ < questNum
                                    currQ = currQ + 1;
                                    currA = 0;
                                end
                        end
                    end
                end
                
                axisState = Gamepad('GetAxis', gi, ansDirect);
                if axisState < 0 % Move to previous answer
                    btnpressed = 1;
                    if currA > 1
                        currA = currA - 1;
                    end
                end
                if axisState > 0 % Move to next answer
                    btnpressed = 1;
                    if currA < ansNum
                        currA = currA + 1;
                    end
                end
                
                % If any button gets pressed, move to the drawings
                if btnpressed
                    break
                end
            end
            
            % Draw to screen based on the input
            % Check if current focusing question is out of the range that can be
            % shown in one screen, and set the offset
            if currQ < currRange(1)
                offset = offset + 1;
                currRange = currRange - 1;
            elseif currQ > currRange(2)
                offset = offset - 1;
                currRange = currRange + 1;
            end
            
            % Move the survey texture with the offset
            newpaper = paperRect;
            newpaper(2:2:end) = newpaper(2:2:end) + offset * questH;
            Screen('DrawTextures', window, paperTexture, [], newpaper, 0, 0);
            
            if currQ % A question is focused; this is always true
                currY = questYs(currQ) + offset * questH;
                qrect = CenterRectOnPointd(baseQRect, xCenter, currY);
                Screen('FillRect', window, qcolor, qrect); % draw a rect over the question
            end
            if currA % An answer is focused; the space key must be pressed to show the rect
                switch survey_type
                    case 'question'
                        currY = ansYs(currQ, currA);
                        arect = CenterRectOnPointd([0 0 595 ansH(currQ, currA)], xCenter, currY);
                    case 'likert'
                        currY = ansYs(currQ);
                        arect = CenterRectOnPointd([0 0 round(595 / ansNum) fontsize], aCenters(currA), currY);
                end
                if isselect
                    tempRects(:, currQ) = arect;
                end
                arect(2:2:end) = arect(2:2:end) + offset * questH;
                Screen('FrameRect', window, acolor, arect); % draw a rect over the answer
            end
            
            % also draw the selected answers
            k = find(selects);
            if ~isempty(k) % check if any answer been selected
                seleRects = tempRects;
                seleRects(2:2:end, :) = seleRects(2:2:end, :) + offset * questH;
                Screen('FillRect', window, scolor, seleRects);
            end
            
            Screen('Flip', window);
            
            % If all questions have been answered, quit the survey after 3 secs
            if size(k, 1) == questNum
                WaitSecs(3);
                break
            end
            
            % Do not go back until all keys are released
            while true
                btnpressed = 0;
                for i = btns
                    if Gamepad('GetButton', gi, i)
                        btnpressed = 1;
                        break
                    end
                end
                axisState = Gamepad('GetAxis', gi, ansDirect);
                if axisState ~= 0
                    btnpressed = 1;
                end
                if ~btnpressed
                    break
                end
            end
            
        end
end


%=====================================================
%                       Cleanup of Section two

% Get the results
[row, col] = find(selects);
selects = [row, col];
selects = sortrows(selects, 1);

% Save results to participants-specific file
selects % just show in command line for now