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
