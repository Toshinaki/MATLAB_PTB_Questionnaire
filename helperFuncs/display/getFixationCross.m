function [ allCoords ] = getFixationCross()
%GETFIXATIONCROSS Set a fixation cross for display


%--------------------------------------------------------------------------
%                       Global variables
%--------------------------------------------------------------------------
global windowRect;


%--------------------------------------------------------------------------
%                       Program settings
%--------------------------------------------------------------------------

% Screen Y fraction for fixation cross
crossFrac = 0.0167;

% Here we set the size of the arms of our fixation cross
fixCrossDimPix = windowRect(4) * crossFrac;

% Now we set the coordinates (these are all relative to zero we will let
% the drawing routine center the cross in the center of our monitor for us)
xCoords = [-fixCrossDimPix fixCrossDimPix 0 0];
yCoords = [0 0 -fixCrossDimPix fixCrossDimPix];
allCoords = [xCoords; yCoords];

end

