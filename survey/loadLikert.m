function [ instruc, questions, answers ] = loadLikert( filename, questNum, ansNum )
%LOADLIKERT Read likert survey from csv file
%   The csv file must be construted like this:
% row1 - 'Instructions to display before the survey' (this is definitely needed even if you have nothing to say. Please make sure you input something. I can get string of spaces for now)
% row2 - 'q1'
% row3 - 'q2'
% ...

% Check parameters
if nargin < 3
    % Use default file and type
    disp('[*] No file assigned. Searching for default file named "survey.csv" ...');
    filename = 'survey.csv';
    % questNum is not needed; but the ansNum is needed
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
c = textscan(fid, '%s', 'delimiter', ',');
fclose(fid);

% Get row number, rowNum - 1 is questions' number
s = size(c{1});
rowNum = s(1);
% Check if rowNum -1 == questNum
if (rowNum - 1) ~= questNum
    warning('[!] The number of questions might be wrong; the program can run with it but some information may be lost.');
end

newc = c{1};

% Seperate instructions with questions
instruc = newc{1};
newc = newc(2:end, :)';

% Save data
questions = newc;
answers = repmat(strsplit(num2str(1:ansNum)), questNum, 1);

end