function [ paperTexture, paperRect, questLine, ansLine, questH, ansW, instruc ] = prepareSurvey( isdialog,  filename, survey_type, questNum, ansNum, showQuestNum)
%PREPARESURVEY Prepare survey texture for later drawing


%--------------------------------------------------------------------------
%                       Global variables
%--------------------------------------------------------------------------
global window  windowRect fontsize xCenter;

% Whether to use dialog to set program if no parameter is given
% Default to yes
if nargin < 1
    isdialog = true;
end


%--------------------------------------------------------------------------
%                       Program settings
%--------------------------------------------------------------------------

if nargin < 6 % not all 6 parameter is given
    % Get information about the survey from user
    % Following information is needed:
    % suervey_filename, question_number, maximum_answer_num, questions_per_screen
    prompts = {'File Name: '; 'Survey type: '; 'Number of questions:'; 'Maximum number of answers: '; 'Number of questions to display per screen: '};
    if isdialog
        dlg_title = 'Program Settings';
        num_lines = 1;
        inputs = inputdlg(prompts, dlg_title, num_lines, {'survey.csv', 'question', '9', '4', '5'});
        [filename, survey_type, questNum, ansNum, showQuestNum] = inputs{:};
        ansNum = str2double(ansNum);
        questNum = str2double(questNum);
        showQuestNum = str2double(showQuestNum);
    else
        filename = input(['[*] ' prompts{1} '\n'], 's');
        survey_type = input(['[*] ' prompts{2} '\n'], 's');
        questNum = getIntegerInput(prompts{2});
        ansNum = getIntegerInput(prompts{3});
        showQuestNum = getIntegerInput(prompts{4});
    end

end


%--------------------------------------------------------------------------
%                       Survey manipulation
%--------------------------------------------------------------------------

switch survey_type
    case 'question'
        % Load survey
        [instruc, questions, answers] = loadSurvey(filename, questNum, ansNum);
        
        % Record the line number of each answer to build rects for later selection
        questLine = zeros(1, questNum);
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
        
    case 'likert'
        [instruc, questions, answers] = loadLikert(filename, questNum, ansNum);
        
        questLine = zeros(1, questNum);
        ansLine = 1;
        
        for i = 1:questNum
            [questions{i}, lineNum] = breakLong(questions{i}, 60);
            questLine(i) = lineNum;
        end
end


%--------------------------------------------------------------------------
%                       Display settings
%--------------------------------------------------------------------------

% Calculate the height of each question, and the height needed for screen
% to contain all questions
screenH = windowRect(4);
questH = ceil(screenH / showQuestNum);
newsh = questH * length(questions); % new screen height

% Also calculate the width for each answer, cause all answer have same
% width; no meaning for "question" type
ansW = round(595 / ansNum);

fontsize = 15;

% Get horizontal center of screen
[xCenter, ~] = RectCenter(windowRect);


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
switch survey_type
    case 'question'
        for i = 1:length(questions)
            anss = strjoin(answers(i, :), '\n');
            qstring = [questions{i} '\n\n' anss];
            nx = DrawFormattedText(paperTexture, sprintf('%2d. ', i), 5, questH*(i-1)+fontsize, 0);
            DrawFormattedText(paperTexture, qstring, nx+5, questH*(i-1)+fontsize, 0);
        end
    case 'likert'
        for i = 1:length(questions)
            qstring = [questions{i} '\n\n'];
            nx = DrawFormattedText(paperTexture, sprintf('%2d. ', i), 5, questH*(i-1)+fontsize, 0);
            [~, ny] = DrawFormattedText(paperTexture, qstring, nx+5, questH*(i-1)+fontsize, 0);
            
            for j = 1:ansNum
                DrawFormattedText(paperTexture, num2str(j), (j-0.5)*ansW, ny, 0);
            end
        end
end

