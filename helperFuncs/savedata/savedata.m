function [  ] = savedata( id, filename, data, row, col )
%SAVEDATA 

if nargin < 4
    row = 0;
    col = 0;
elseif nargin < 5
    col = 0;
end

mainFolder = fullfile(pwd, 'data');
pfolder = [mainFolder '/' num2str(id) '/'];
filename = [filename '.csv'];

fprintf('[*] Writing data to file %s........', filename);
dlmwrite([pfolder filename], data, '-append', 'precision', 15);
fprintf('Success!\n');

end

