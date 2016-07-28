function [ paperTexture, paperRect, qRects, aRects, questH, instruc ] = prepareSurvey( isdialog,  filename, questNum, ansNum, showQuestNum)
%PREPARESURVEY Prepare survey texture for later drawing


%--------------------------------------------------------------------------
%                       Global variables
%--------------------------------------------------------------------------
global window  windowRect fontsize;

% Whether to use dialog to set program if no parameter is given
% Default to yes
if nargin < 1
    isdialog = true;
end


%--------------------------------------------------------------------------
%                       Program settings
%--------------------------------------------------------------------------

if nargin < 5 % not all 5 parameter is given
    % Get information about the survey from user
    % Following information is needed:
    % suervey_filename, question_number, maximum_answer_num, questions_per_screen
    prompts = {'File Name: '; 'Number of questions:'; 'Maximum number of answers: '; 'Number of questions to display per screen: '};
    if isdialog
        dlg_title = 'Program Settings';
        num_lines = 1;
        inputs = inputdlg(prompts, dlg_title, num_lines, {'survey.csv', '9', '4', '5'});
        [filename, questNum, ansNum, showQuestNum] = inputs{:};
        ansNum = str2double(ansNum);
        questNum = str2double(questNum);
        showQuestNum = str2double(showQuestNum);
    else
        filename = input(['[*] ' prompts{1} '\n'], 's');
        questNum = getIntegerInput(prompts{2});
        ansNum = getIntegerInput(prompts{3});
        showQuestNum = getIntegerInput(prompts{4});
    end

end


%--------------------------------------------------------------------------
%                       Survey manipulation
%--------------------------------------------------------------------------

% Load survey

[instruc, questions, answers] = loadSurvey(filename, questNum, ansNum);

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
screenH = windowRect(4);
questH = ceil(screenH / showQuestNum);
newsh = questH * length(questions); % new screen height

fontsize = 15;


%--------------------------------------------------------------------------
%                       Build Rects for selection
%--------------------------------------------------------------------------

% Get horizontal center of screen
[xCenter, ~] = RectCenter(windowRect);

% Build question rects
baseRect = [0 0 595 questH];
% Save all rects to here
qRects = nan(4, questNum);
for i = 1:questNum
    qRects(:, i) = CenterRectOnPointd(baseRect, xCenter, questH * (i-0.5));
end

% Build answer rects
% These 2 for-loop can be conbined together, but I seperated them for
% readability
aRects = nan(4, questNum, ansNum);
for i = 1:questNum
    baseY = (i-1) * questH + fontsize * (questLine(i)+1) + fontsize/5;
    for j = 1:ansNum
        baseY = baseY + fontsize * ansLine(i, j);
        aRects(:, i, j) = CenterRectOnPointd([0 0 595 fontsize*ansLine(i, j)], xCenter, (baseY - fontsize*ansLine(i, j)/2));
    end
end


%--------------------------------------------------------------------------
%                       Make background and survey texture
%--------------------------------------------------------------------------

% Make a texture of background of A4 size (595 X 842)
% Only width (595) used here
paperRect = [0 0 595 newsh];
paperRect = CenterRectOnPointd(paperRect, xCenter, newsh/2);

% A matrix (595 X newsh) of "1"s means a white bacground
textureRect = ones(ceil(paperRect(4) - paperRect(2)), ceil(paperRect(3) - paperRect(1)));
paperTexture = Screen('MakeTexture', window, textureRect);

% Set font and size of texture
Screen('Textsize', paperTexture, fontsize);
Screen('TextFont', paperTexture, 'Courier');

% Draw questions and answers to texture in black
for i = 1:length(questions)
    anss = strjoin(answers(i, :), '\n');
    qstring = [questions{i} '\n\n' anss];
    nx = DrawFormattedText(paperTexture, sprintf('%2d. ', i), 5, questH*(i-1)+fontsize, 0);
    DrawFormattedText(paperTexture, qstring, nx+5, questH*(i-1)+fontsize, 0);
end

end

