function [ questions, answers ] = LoadSurvey( filename, ansNum )
%GETQAS Read questionnaire from csv file

% Check Input parameter
% If no file assigned, search for default survey.csv
if nargin < 1
        disp('[*] No file assigned. Searching for default file named "survey.csv" ...')
        filename = 'survey.csv';
end
% If no ansNum given, ask user to input
% It is easier to parse the file with this
if nargin < 2
    prompt = '[*] Input the maximum number of answers for the questions:\n';
    ansNum = input(prompt, 's');
    ansNum = str2double(ansNum);
end

% Check if file exists
if exist(filename, 'file') ~= 2
    fprintf('[!] File "%s" not exists. Press ENTER to open file explorer; or input "q" to quit\n', filename)
    temp = input('', 's');
    if isempty(temp)
        filename = uigetfile({'*.csv', 'CSV File'});
    elseif lower(temp) == 'q'
        error('[!] File not assigned. Quit now...')
    else
        error('[!] Unknown input: "%s"', temp)
    end
    
    if ~filename
        error('[!] File not assigned. Quit now...')
    end
end

% Read from file
fid = fopen(filename);
c = textscan(fid, repmat('%s', 1, ansNum), 'delimiter', ',');
fclose(fid);

% Get row number, rowNum / 2 is questions' number
s = size(c{1});
rowNum = s(1);
% If rowNum is odd, then the file is no complete
if mod(rowNum, 2) == 1
    error('[!] Row number (%d) is odd, file might not complete. Quit now...', rowNum)
end

newc = reshape(cat(1, c{:}), rowNum, ansNum);

% Define cells to save parsed data
questions = cell(1, rowNum/2);
answers = cell(rowNum/2, ansNum);

% Save data into cells
for  i = 1:2:(rowNum)
    questions{(i+1)/2} = newc{i, 1};
    for j = 1:ansNum
        answers{(i+1)/2, j} = newc{(i+1), j};
    end

end

