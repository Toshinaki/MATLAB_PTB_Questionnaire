function [ deviceInstruc ] = getInstruc( respdevice )
%GETINSTRUC Return instructions for different device

devices = {'mouse', 'game', 'key'};
instrucs = {'Please use mouse to complete the survey:\n> move the mouse to select among questions\n> left click to select your answer\n> wheel to scroll the screen\n\nIf you are ready, left click the mouse to start the survey',...
    'Please use game controller to complete the survey:\n> "LT", "RT" to select among questions\n> "up", "down" to select among answers\n> "B" to make your choice\n\nIf you are ready, press "B" to start the survey',...
    'Please use keyboard to complete the survey:\n> "up", "down" to select among questions\n> "left", "right" to select among answers\n> "space" to make your choice\n\nIf you are ready, press the "space" to start the survey'};

[isdevice, i] = ismember(respdevice, devices);

if ~isdevice
    error('[!] Device < %s > could not be recognised; check your input!', respdevice);
end

deviceInstruc = instrucs{i};

end

