function [ newString, lineNum ] = breakLong( oldString, maxlen )
%BREAKLONG Break long strings into multiple line with given length

howLong = ceil(length(oldString) / maxlen);
strings = cell(1, howLong);

if howLong > 1
    for i = 1:(howLong-1)
        strings{i} = oldString(maxlen*(i-1)+1:maxlen*i);
    end
    strings{i+1} = oldString(maxlen*i+1:end);
    lineNum = i + 1;
else
    strings{1} = oldString;
    lineNum = 1;
end
% switch howLong
%     case 2
%         newString = [oldString(1:55) '\n' oldString(55:end)];
%     case 3
%         newString = [oldString(1:55) '\n' oldString(56:110) '\n' oldString(110:end)];
%     case 4
%         newString = [oldString(1:55) '\n' oldString(56:110) '\n' oldString(110:165) '\n' oldString(166:end)];
% end

newString = strjoin(strings, '\n');

end

