function [  ] = gamepadPressCheck( index )
%GAMEPADPRESSCHECK Check if gamepad pressed

while true
  fprintf('Please click the mouse now.\n');
  [x,y,buttons] = GetMouse([], index);
  while any(buttons) % if already down, wait for release
    [x,y,buttons] = GetMouse([],index);
  end
  while ~any(buttons) % wait for press
    [x,y,buttons] = GetMouse([],index);
  end
  fprintf('[+] Button pressed:\nx: %d; y: %d; buttons: %d;\n', x,y,buttons);
  while any(buttons) % wait for release
    [x,y,buttons] = GetMouse([],index);
  end

end
end

