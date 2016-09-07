function [  ] = keyboardNum(  )
%KEYBOARDNUM Return the index number of keys on keyboard pressed
%   Use escape key to quit function

escapekey = KbName('ESCAPE');
spacekey = KbName('space');

disp('[*] Press "space" to start');
while true
    [keyDown, secs, keycode] = KbCheck;
    if keycode(spacekey)
        break
    end
end
disp('[*] Start to check key-pressing')

% Start when all key is released
while keyDown
    [keyDown, secs, keycode] = KbCheck;
end
while true
    [keyDown, secs, keycode] = KbCheck;
    k = find(keycode);
    if k
        keyname = KbName(k);
        fprintf('[+] Key pressing detected!!\n    Key: %s\tIndex:%d\n', keyname, k);
        if k == escapekey
            fprintf('[-] Escape key pressed; quiting...\n')
            return
        end
    end
    % Wait for all keys are released
    while keyDown
        [keyDown, secs, keycode] = KbCheck;
    end
end

