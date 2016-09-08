% The full course of an experiment

commandwindow;
clearvars;
rng('shuffle');

% Add current folder and all sub-folders
addpath(genpath([pwd '/..']));
id = partGen();
%--------------------------------------------------------------------------
%                       Global variables
%--------------------------------------------------------------------------
global window windowRect fontsize xCenter yCenter white;


%--------------------------------------------------------------------------
%                       Screen initialization
%--------------------------------------------------------------------------

% First create the screen for simulation displaying
% Using function prepareScreen.m
% This returned vbl may not be precise; flip again to get a more precise one
% This screen size is for test
[window, windowRect, vbl, ifi] = prepareScreen([0 0 1280 1024]);
HideCursor;


%--------------------------------------------------------------------------
%                       Global settings
%--------------------------------------------------------------------------

% Screen center
[xCenter, yCenter] = RectCenter(windowRect);

% device
% The way participants take the experiment; could be "key", "mouse", "game"
% To use different device for every section;
% comment this and define individually in every section
respdevice = 'mouse';

% Get instructions for each device
%instruc = getInstruc();


%%
%______________________________________________________________
%=====================================================
%                       Section one
%______________________________________________________________

%=====================================================
%                       Preparation of Section one
% This file is about questionnaire only, so I removed section one.
% Note that the deviceInstruc is written in japanese.
% Change it to your language.
% See getInstruc() for details about how to make the instruction file.

%=====================================================
%                       Execution of Section one


%=====================================================
%                       Cleanup of Section one

%%
%______________________________________________________________
%=====================================================
%                       Section two -- Survey
%______________________________________________________________

%=====================================================
%                       Preparation of Section two

% Define some DEFAULT values
isdialog = true; % Change this value to determine whether to use dialog
filename = 'surveylong.csv'; % The file name of survey to run; will open browser if not exists
survey_type = 'likert'; % Type of the survey, can be "question", "likert"
questNum = 30; % Number of questions in this survey
ansNum = 5; % Number of answers of each question
showQuestNum = 10; % Number of questions to display in one screen; you may need to try few times to get best display

% Prepare survey texture for later drawing; the file is loaded inside
% prepareSurvey.m; for the detail of the csv file's structure, see loadSurvey.m
[paperTexture, paperRect, questH, ansH, questYs, ansYs, instruc] = prepareSurvey(isdialog, filename, survey_type, questNum, ansNum, showQuestNum);

% Prepare INSTRUCTIONS
% Besides instruction from the file, the instruction of how to play with
% the survey is also displayed
% Three ways: keyboard, mouse, and gamepad
% Instruction will be different depending on the device you choose
% [instruc, ~] = breakLong(instruc, 60);
% currDeviceIn = deviceInstruc{3};

% Set FONT for instructions
Screen('Textsize', window, fontsize);
Screen('TextFont', window, 'Courier');

% COLOR settings
% Set color for identifying currently focused question and answer
% and selected answer
qcolor = [0 0 1 0.1];
acolor = [1 0 0 0.5];
scolor = [0 1 0 0.2];

% Base rect for questions and answers
baseQRect = [0 0 595 questH];
if strcmp(survey_type, 'likert')
    aCenters = linspace(595/(ansNum*2), 595*((ansNum-0.5)/ansNum), ansNum) + (xCenter-595/2);
end

paperlimit = [xCenter-595/2 xCenter+595/2];

% Keep a record of selections during loop
% These will be used to draw marks
selects = zeros([questNum, ansNum]);
currQ = 1;
currA = 0;
% To keep the marks in right place while scrolling screen
offsetRange = [showQuestNum-questNum 0];
offset = 0;


% Record selected rects here
seleRects = nan(4, questNum); % This is for drawing
tempRects = nan(4, questNum); % This is for recording


%=====================================================
%                       Execution of Section two

ShowCursor;

% First draw instructions
Screen('FillRect', window, 1, paperRect);
[~, ny] = DrawFormattedText(window, instruc, 'center', questH, 0);
%DrawFormattedText(window, currDeviceIn, 'center', ny+questH, 0);
Screen('Flip', window);

% Wait for 10 secs here for participants to read the instruction before
% check for any input
WaitSecs(1);

% If any key clicked, go to the loop
checkClicked(window);

% Show the survey
Screen('DrawTextures', window,paperTexture, [], paperRect, 0, 0);
Screen('Flip', window);

% Start loop to monitor the mouse position and check for click
while true
    % Get current coordinates of mouse
    [x, y, buttons] = GetMouse(window);
    
    % Don't let the mouse exceed our paper
    if x > paperlimit(2)
        SetMouse(paperlimit(2), y);
    elseif x < paperlimit(1)
        SetMouse(paperlimit(1), y);
    end
    
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
        if any(buttons) % And if any button gets clicked
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


%=====================================================
%                       Cleanup of Section two

% Get the results
[row, col] = find(selects);
selects = [row, col];
selects = sortrows(selects, 1);

% Save results to participants-specific file
selects % just show in command line for now