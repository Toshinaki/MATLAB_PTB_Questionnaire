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

%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
%                       Section one
%--------------------------------------------------------------------------

%--------------------------------------------------
%                       Preparation of Section one

%--------------------------------------------------
%                       Execution of Section one

%--------------------------------------------------
%                       Cleanup of Section one


%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
%                       Section two -- Survey
%--------------------------------------------------------------------------

%--------------------------------------------------
%                       Preparation of Section two

% Define some default values
isdialog = true; % Change this value to determine whether to use dialog
filename = 'survey.csv'; % The file name of survey to run; will open browser if not exists
survey_type = 'likert'; % Type of the survey, can be "question", "likert"
questNum = 10; % Number of questions in this survey
ansNum = 5; % Number of answers of each question
showQuestNum = 5; % Number of questions to display in one screen; you may need to try few times to get best display
respdevice = 'key'; % The way participants take the survey; could be "key", "mouse", "game"

% Prepare survey texture for later drawing; the file is loaded inside
% prepareSurvey.m; for the detail of the csv file's structure, see loadSurvey.m
[paperTexture, paperRect, questLine, ansLine, questH, ansW, instruc] = prepareSurvey(isdialog, filename, survey_type, questNum, ansNum, showQuestNum);

% Prepare instructions.
% Besides instruction from the file, the instruction of how to play with
% the survey is also displayed
% Three ways: keyboard, mouse, and gamepad
% Instruction will be different depending on the device you choose
[instruc, ~] = breakLong(instruc, 60);
deviceInstruc = getInstruc(respdevice);

% Set font for instructions
Screen('Textsize', window, fontsize);
Screen('TextFont', window, 'Courier');

% Color settings
% Set color for identifying currently focused question and answer
% and selected answer
qcolor = [0 0 1 0.1];
acolor = [1 0 0 0.5];
scolor = [0 1 0 0.2];

% Key settings
upkey = KbName('UpArrow');
downkey = KbName('DownArrow');
leftkey = KbName('LeftArrow');
rightkey = KbName('RightArrow');
escapekey = KbName('ESCAPE');
spacekey = KbName('space');

% Base rect for questions and answers
baseQRect = [0 0 595 questH];
if strcmp(survey_type, 'likert')
    baseARect = [0 0 ansW fontsize];
end

% Keep a record of selections during loop
% These will be used to draw marks
selects = zeros([questNum, ansNum]);
currQ = 1;
currA = 0;
% To keep the marks in right place while scrolling screen
currRange = [1 showQuestNum]; 
offset = 0;

% Record selected rects here
seleRects = nan(4, questNum);
tempRects = nan(4, questNum);


%--------------------------------------------------
%                       Execution of Section two

% First draw instructions
Screen('FillRect', window, 1, paperRect);
[~, ny] = DrawFormattedText(window, instruc, 'center', questH, 0);
DrawFormattedText(window, deviceInstruc, 'center', ny+questH, 0);
Screen('Flip', window);

%---------- This is for keyboard
% Wait for 10 secs here for participants to read the instruction before
% check for any input
WaitSecs(10);
while true
    [keyDown, secs, keycode] = KbCheck;
    if keycode(spacekey) % Start loop if space pressed
        break
    end
end

% Show the survey
Screen('DrawTextures', window,paperTexture, [], paperRect, 0, 0);
Screen('Flip', window);

% Start loop to check for input
while true
    [keyDown, secs, keycode] = KbCheck;
    if keycode(spacekey) % space pressed
        if currQ && currA % when both question and answer is focused
            selects(currQ, :) = 0;
            selects(currQ, currA) = 1; % then record that selection
        end
    elseif keycode(upkey) % up pressed
        if currQ > 1 % current focusing question is the 1st one then don't change focus
            currQ = currQ - 1;% otherwise move focus 1 question up
        end
        currA = 0; % and set the current focusing answer to nothing
    elseif keycode(downkey) % down pressed
        if currQ < questNum % same thing as upkey
            currQ = currQ + 1;
        end
        currA = 0;
    elseif keycode(leftkey) % left pressed
        if currA >1
            currA = currA - 1;
        end
    elseif keycode(rightkey) % right pressed
        if currA < ansNum
            currA = currA + 1;
        end
    else % no key pressed, then go back to the start point of the loop
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
        qrect = CenterRectOnPointd(baseQRect, xCenter, questH*(currQ-0.5));
        qrect(2:2:end) = qrect(2:2:end) + offset * questH;
        Screen('FillRect', window, qcolor, qrect); % draw a rect over the question
    end
    if currA % An answer is focused; right key must be pressed to show the rect
        switch survey_type
            case 'question'
                baseY = (currQ - 1) * questH + fontsize * (questLine(currQ) + 1) + fontsize/5; % this height may need some modification to show correctlu on your machine
                baseY = baseY + fontsize * sum(ansLine(currQ, 1:(currA-1)));
                arect = CenterRectOnPointd([0 0 595 fontsize*ansLine(currQ, currA)], xCenter, baseY+fontsize*ansLine(currQ, currA)/2);
            case 'likert'
                baseY = (currQ - 1) * questH + fontsize * (questLine(currQ) + 1) + fontsize/5; % this height may need some modification to show correctlu on your machine
                arect = CenterRectOnPointd(baseARect, (xCenter-595/2)+(currA-0.5)*ansW, baseY+fontsize/2);
        end
        if keycode(spacekey)
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
    while keyDown
        [keyDown, secs, keycode] = KbCheck;
    end
end

%--------------------------------------------------
%                       Cleanup of Section two

% Get the results
[row, col] = find(selects);
selects = [row, col];
selects = sortrows(selects, 1);

% Save results to participants-specific file
selects % just show in command line for now