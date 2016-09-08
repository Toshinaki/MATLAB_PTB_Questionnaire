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
[window, windowRect, vbl, ifi] = prepareScreen([0 0 900 768]);
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
respdevice = 'game';
% Response DEVICE settings
% Gamepad settings
% These might differ in your pc and gamepad
%     Axes:                                                       Buttons:
%10: up down                                             1: A
%9: left right                                               2: B
%8: right trigger                                          3: X
%7: right stick up down                              4: Y
%6: right stick left right                              5: LB
%5: left trigger                                            6: RB
%4: left stick up down                                7: BACK
%3: left stick left right                                8: START
%2: right trigger (change slowly)                 9: Icon
%1: right stick up down (change is cons)    10: left stick
%                                                                11: right stick

GamepadName = 'Logitech Gamepad F310';
gi = Gamepad('GetGamepadIndicesFromNames', GamepadName);
preB = 5;
nextB = 6;
leftstick = [3 4];

% Get instructions for each device
deviceInstruc = getInstruc(respdevice);


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

% Define button to move through answers
switch survey_type
    case 'likert'
        ansB = 3;
    case 'quest'
        ansB = 4;
end

browsing1 = 0;
browsing2 = 0;

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

% Keep a record of selections during loop
% These will be used to draw marks
selects = zeros([questNum, ansNum]);
currQ = 1;
currA = 0;
% To keep the marks in right place while scrolling screen
currRange = [1 showQuestNum];
offset = 0;


% Record selected rects here
seleRects = nan(4, questNum); % This is for drawing
tempRects = nan(4, questNum); % This is for recording


%=====================================================
%                       Execution of Section two

% First draw instructions
Screen('FillRect', window, 1, paperRect);
[~, ny] = DrawFormattedText(window, instruc, 'center', questH, 0);
DrawFormattedText(window, currDeviceIn, 'center', ny+questH, 0);
Screen('Flip', window);

% Wait for 10 secs here for participants to read the instruction before
% check for any input
WaitSecs(1)
%---------- This is for gamepad------------------------------------
% If the button (in this case 2) pressed, go to the loop
checkPrsRls(gi, nextB);

while true
    % Check for buttons; if no buttons pressed, keep checking
    btnpsd = 0;
    isselect = 0;

    if Gamepad('GetButton', gi, 2)
        btnpsd = 1;
        if currQ && currA
            isselect = 1;
            selects(currQ, :) = 0;
            selects(currQ, currA) = 1;
        end
    end
    
    if Gamepad('GetButton', gi, preB)
        btnpsd = 1;
        if currQ > 1
            currQ = currQ - 1;
            currA = 0;
        end
    end
    if Gamepad('GetButton', gi, nextB)
        btnpsd = 1;
        if currQ < questNum
            currQ = currQ + 1;
            currA = 0;
        end
    end
    
    axisState = Gamepad('GetAxis', gi, ansB);
    if axisState
        btnpsd = 1;
        if axisState < 0 % previous answer
            if currA > 1
                currA = currA - 1;
            else
                currA = ansNum;
            end
        elseif axisState > 0 % next answer
            if currA < ansNum
                currA = currA + 1;
            else
                currA = 1;
            end
        end
    end

    if ~btnpsd
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
    if currA % An answer is focused
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
        btnpsd = 0;
        if Gamepad('GetButton', gi, 2) % B is pressed, wait for release
            btnpsd = 1;
        end

        if Gamepad('GetAxis', gi, ansB) % navigate answers
            btnpsd = 1;
            if browsing1
                WaitSecs(0.2);
            else
                WaitSecs(0.25);
            end
            if Gamepad('GetAxis', gi, ansB)
                browsing1 = 1;
                break
            end
            browsing1 = 0;
        end
        

        if Gamepad('GetButton', gi, preB) || Gamepad('GetButton', gi, nextB) % navigate questions
            btnpsd = 1;
            if browsing2
                WaitSecs(0.05);
            else
                WaitSecs(0.5);
            end
            if Gamepad('GetButton', gi, preB) || Gamepad('GetButton', gi, nextB)
                browsing2 = 1;
                break
            end
            browsing2 = 0;
        end

        if ~btnpsd
            break
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