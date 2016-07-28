function [ instruc, questions, answers ] = loadSurvey( filename, questNum, ansNum )
%LOADSURVEY Read questionnaire from csv file
%   The csv file must be construted like this:
% row1 - 'Instructions to display before the survey' (leave this blank even if no instructions is available)
% row2 - 'question1'
% row3 - 'answer1' 'answer2' 'answer3'...
% row4 - 'question2'
% ...

% Check parameters
if nargin < 3
    % Use default file
    disp('[*] No file assigned. Searching for default file named "survey.csv" ...');
    filename = 'survey.csv';
    % questNum is not needed; but the ansNum is needed for parsing the file
    % so input both please
    prompts = {'Input the number of questions:\n'; 'Input the maximum number of answers for the questions:\n'};
    questNum = getIntegerInput(prompts{1});
    ansNum = getIntegerInput(prompts{2});
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

% Get row number, (rowNum - 1) / 2 is questions' number
s = size(c{1});
rowNum = s(1);
% If rowNum is even, then the file is no complete
if mod(rowNum, 2) == 0 || (rowNum-1)/2 ~= questNum
    error('[!] Row number (%d) is odd, file might not complete. Quit now...', rowNum)
end

newc = reshape(cat(1, c{:}), rowNum, ansNum);

% Seperate instructions with questions
instruc = newc{1};
newc = newc(2:end, :);

% Define cells to save parsed data
questions = cell(1, questNum);
answers = cell(questNum, ansNum);

% Save data into cells
for  i = 1:2:(rowNum-1)
    questions{(i+1)/2} = newc{i, 1};
    for j = 1:ansNum
        answers{(i+1)/2, j} = newc{(i+1), j};
    end
end

end