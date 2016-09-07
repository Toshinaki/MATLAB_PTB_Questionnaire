% The full course of an experiment

commandwindow;
clearvars;
rng('shuffle');

% Add current folder and all sub-folders
addpath(genpath(pwd));
id = partGen();
%--------------------------------------------------------------------------
%                       Global variables
%--------------------------------------------------------------------------
global window windowRect fontsize xCenter yCenter white grey;


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
resButtons = 1:4;
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


%=====================================================
%                       Execution of Section two


%=====================================================
%                       Cleanup of Section two

%%
%______________________________________________________________
%=====================================================
%                       Section three -- SAM
%______________________________________________________________

%=====================================================
%                       Preparation of Section three

% Get the fixation cross coords and set its line and color
fixCoords = getFixationCross();
linewidth = 4;
color = white;

browsing3 = 0;

% The folder of images to show
% Get images, set the width to show the images
filedir = fullfile([pwd '/..'], 'images/');
imgs = dir(fullfile(filedir, '*.jpg'));
imgnum = length(imgs);
imgxlen = 800;

% Set which sam scale to use: 'v'alence, 'a'rousal, or 'd'ominance
% Make texture for sam
samscl = 'v';
samimg = imread(fullfile(filedir, ['sam_' samscl '_5.png']));
samTexture = Screen('MakeTexture', window, samimg);
[ss1, ss2, ss3] = size(samimg);
samy = yCenter * 2 - ss1/2 - 10;
samRect = CenterRectOnPointd([0 0 ss2 ss1], xCenter, samy);

% Prepare circles for selection
cnum = 9;
circleRects = zeros(4, cnum);
xCenters = linspace(xCenter-ss2*0.85/2, xCenter+ss2*0.85/2, cnum);
baseRect = [0 0 50 50];
for i = 1:cnum
    circleRects(:, i) = CenterRectOnPointd(baseRect, xCenters(i), samy+ss1/3);
end

% Set a limit for every image
limit = 10;

% Record the selection
selects = zeros(imgnum, cnum);

%=====================================================
%                       Execution of Section three

% Go to the loop when RB pressed
checkPrsRls(gi, nextB);

% Flip to get vbl
vbl = Screen('Flip', window);

for i = 1:imgnum
    
    % Draw fixation cross
    Screen('DrawLines', window, fixCoords, linewidth, color, [xCenter yCenter], 2);
    [vbl, onset] = Screen('Flip', window, vbl+0.5*(1-ifi));
    
    % Read image and make texture
    img = imread(fullfile(filedir, imgs(i).name));
    [s1, s2, s3] = size(img);
    
    ratio = s2 / s1;
    imgylen = imgxlen / ratio;
    
    dstRect = [0 0 imgxlen imgylen];
    dstRect = CenterRectOnPointd(dstRect, xCenter, yCenter - 100);
    
    imgTexture = Screen('MakeTexture', window, img);
    
    % Main loop
    currS = 0;
    while true
        % Check current time; if limit is over, go to next image
        if GetSecs() > onset + limit + 1;
            break
        end
        
        % First draw image and sam
        Screen('DrawTextures', window, [imgTexture; samTexture], [], [dstRect; samRect]');
        % Then draw circles
        Screen('FrameOval', window, grey, circleRects, 2, 2);
        
        % If any circle been selected, fill it with blue
        if currS
            selectedCircle = circleRects(:, currS);
            Screen('FillOval', window, [0 0 0.5 0.2], selectedCircle);
        end
        
        % Flip after 1 second since cross show up
        Screen('Flip', window, vbl+1-ifi);
        
        selected = 0;
        btnpsd = 0;
        while true
            if Gamepad('GetButton', gi, 2)
                if currS
                    selected = 1;
                    selects(i, :) = 0;
                    selects(i, currS) = 1;
                    break
                end
            end
            
            axisState = Gamepad('GetAxis', gi, 3); % left right select
            if axisState
                btnpsd = 1;
                if axisState < 0
                    if currS > 1
                        currS = currS - 1;
                    else
                        currS = cnum;
                    end
                elseif axisState > 0
                    if currS < cnum
                        currS = currS + 1;
                    else
                        currS = 1;
                    end
                end
            end
            
            % Wait for release
            while true
                b = 0;
                if Gamepad('GetButton', gi, 2)
                    b = 1;
                end
                
                if Gamepad('GetAxis', gi, 3)
                    b = 1;
                    if browsing3
                        WaitSecs(0.1);
                    else
                        WaitSecs(0.2);
                    end
                    if Gamepad('GetAxis', gi, 3)
                        browsing3 = 1;
                        break
                    end
                    browsing3 = 0;
                end
                
                if ~b
                    break
                end
            end
            
            if btnpsd
                break
            end
        end
        
        if selected
            % Flip for next vbl
            vbl = Screen('Flip', window);
            break
        end
    end
    
end
            

%=====================================================
%                       Cleanup of Section two
selects