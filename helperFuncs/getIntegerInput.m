function [ an_integer ] = getIntegerInput( prompt )
%GETINTEGERINPUT Get an integer from user 

warn = 'Please input an integer!! < %s > is not valid';
while true
    an_integer = input(['[*] ' prompt], 's');
    an_integer = str2double(an_integer);
    
    if isnan(an_integer)
        warning(['[!] ' warn], an_integer);
        continue
    else
        break
    end
end
end

