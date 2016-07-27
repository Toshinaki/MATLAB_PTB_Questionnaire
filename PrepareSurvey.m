function [ texture, paperRect, allRects, allRects2, questH ] = PrepareSurvey( window, windowRect, isdialog, filename, ansNum, showQuestNum )
%RUNSURVEYII Summary of this function goes here
%   Detailed explanation goes here


% window object is needed
if nargin < 2
    error('[!] No window object received. Please check your code!')
end

% Whether to use dialog or not
% Default to yes
if nargin < 3
    isdialog = true;
end


%--------------------------------------------------------------------------
%                       Program settings
%--------------------------------------------------------------------------

if nargin < 6
    % Get information about the survey from user
    % Following information is needed:
    % suervey_filename, maximum_answer_num, questions_per_screen
    prompts = {'File Name: '; 'Maximum number of answers: '; 'Number of questions to display per screen: '};
    if isdialog
        dlg_title = 'Program Settings';
        num_lines = 1;
        inputs = inputdlg(prompts, dlg_title, num_lines, {'survey.csv', '4', '5'});
    else
        inputs = cell(1, length(prompts));
        for i = 1:length(prompts)
            inputs{i} = input(['[*] ' prompts{i} '\n'], 's');
        end
    end
    [filename, ansNum, showQuestNum] = inputs{:};
    ansNum = str2double(ansNum);
    showQuestNum = str2double(showQuestNum);
end

%--------------------------------------------------------------------------
%                       Survey manipulation
%--------------------------------------------------------------------------

% Get survey
[questions, answers] = LoadSurvey( filename, ansNum );
questNum = length(questions);
%ansNum = size(answers, 2);

% Record the line number of each answer to build rects for later selection
questLine = zeros(questNum);
ansLine = zeros(size(answers));

% Check if string too long and break it by insert newline
% With Courier font, font size 15 and paper width 595,
% 60 seems to be a good point to insert new line
for i = 1:questNum
    [questions{i}, lineNum] = breakLong(questions{i}, 60);
    questLine(i) = lineNum;
    for j = 1:ansNum
        [answers{i, j}, lineNum] = breakLong(answers{i, j}, 60);
        ansLine(i, j) = lineNum;
    end
end


%--------------------------------------------------------------------------
%                       Display settings
%--------------------------------------------------------------------------

% Calculate the height of each questions, and the height needed for screen
% to contain all questions
s = get(0, 'MonitorPositions');
screenH = s(4);
questH = ceil(screenH / showQuestNum);
newsh = questH * length(questions);

fontsize = 15;


%--------------------------------------------------------------------------
%                       Build Rects for selection
%--------------------------------------------------------------------------

% Get horizontal center of screen
[xCenter, ~] = RectCenter(windowRect);

% Build question rects
baseRect = [0 0 595 questH];
% Save all rects to here
allRects = nan(4, questNum);
for i = 1:questNum
    allRects(:, i) = CenterRectOnPointd(baseRect, xCenter, questH * (i-0.5));
end

% Build answer rects
% These 2 for-loop can be conbined together, but I seperated them for
% simplicity
allRects2 = nan(4, questNum, ansNum);
for i = 1:questNum
    baseY = (i-1) * questH + fontsize * (questLine(i)+1) + fontsize/5;
    for j = 1:ansNum
        baseY = baseY + fontsize * ansLine(i, j);
        allRects2(:, i, j) = CenterRectOnPointd([0 0 595 fontsize*ansLine(i, j)], xCenter, (baseY - fontsize*ansLine(i, j)/2));
    end
end


%--------------------------------------------------------------------------
%                       Make background and survey
%--------------------------------------------------------------------------

% Make a texture of background of A4 size (595 X 842)
% Only width (595) used here
paperRect = [0 0 595 newsh];
paperRect = CenterRectOnPointd(paperRect, xCenter, newsh/2);

% A matrix (595 X newsh) of 1 means all white
textureRect = ones(ceil(paperRect(4) - paperRect(2)), ceil(paperRect(3) - paperRect(1)));
texture = Screen('MakeTexture', window, textureRect);

% Set font and size of texture
Screen('Textsize', texture, fontsize);
Screen('TextFont', texture, 'Courier');

% Draw questions and answers to texture in black
for i = 1:length(questions)
    anss = strjoin(answers(i, :), '\n');
    qstring = [questions{i} '\n\n' anss];
    nx = DrawFormattedText(texture, sprintf('%2d. ', i), 5, questH*(i-1)+fontsize, 0);
    DrawFormattedText(texture, qstring, nx+5, questH*(i-1)+fontsize, 0);
end