function [ window, windowRect, grey, vbl, ifi ] = GetScreen( ssize )
%GETSCREEN Get screen ready for dispaly
%   Return screen information for manipulation

if nargin < 1
    ssize = [0 0 1280 1024];
end

% Clear the workspace
%clearvars;
close all;
sca;

% Here we call some default settings for setting up Psychtoolbox
PsychDefaultSetup(2);

%--------------------------------------------------------------------------
%                       Screen initialisation
%--------------------------------------------------------------------------

% Find the screen to use for displaying the stimuli. By using "max" this
% will display on an external monitor if one is connected.
screenid = max(Screen('Screens'));

% Determine the values of black and white
black = BlackIndex(screenid);
white = WhiteIndex(screenid);
grey = white / 2;

% Set up screen
[window, windowRect] = PsychImaging('OpenWindow', screenid, grey, ssize);

% Set the blend function so that we get nice antialised edges to the dots
% defining our cyliner
Screen('BlendFunction', window, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

% Measure the vertical refresh rate of the monitor
ifi = Screen('GetFlipInterval', window);

% Retreive the maximum priority number and set max priority
topPriorityLevel = MaxPriority(window);
Priority(topPriorityLevel);

% Flip outside of teh loop to get a time stamp
vbl = Screen('Flip', window);

end

