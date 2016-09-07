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
respdevice = 'mouse';

% Get instructions for each device
%deviceInstruc = getInstruc();


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

ShowCursor;

% Get the fixation cross coords and set its line and color
fixCoords = getFixationCross();
linewidth = 4;
color = white;

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

% Go to the loop when any key clicked
while true
    [x, y, buttons] = GetMouse(window);
    if find(buttons)
        break
    end
end

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
    selected = 0;
    
    SetMouse(xCenter, samRect(2)-10);
    
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
        
        while true
            [x, y, buttons] = GetMouse(window);
            
            % Check if mouse in the sam range
            if x <= samRect(3) && x >= samRect(1) && y <= samRect(4) && y >= samRect(2)+ss1/3*2
                if find(buttons)
                    if currS
                        selects(i, :) = 0;
                        selects(i, currS) = 1;
                        selected = 1;
                        break
                    end
                end
                
                [~, tempS] = min(abs(xCenters - x));
                if tempS == currS
                    continue
                else
                    currS = tempS;
                    break
                end
            else
                continue
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