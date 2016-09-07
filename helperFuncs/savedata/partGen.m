function [ id ] = partGen(  )
%PARTIFILEGEN Generate participant-specific file

% First make a folder in participant's id
mainFolder = fullfile(pwd, 'data');
if ~exist(mainFolder, 'dir')
    mkdir(mainFolder)
end
all_file = dir(mainFolder);
all_dir = all_file([all_file(:).isdir]);

fprintf('[+] Generating id for new participant...\n');
n = numel(all_dir);
id = n - 2;
fprintf('[*] Success! Participant was given id #%d\n', id);

fprintf('[+] Creating folder for partcipant #%d........', id);
mkdir(mainFolder, num2str(id));
fprintf('Success!\n\n');

% Then generate files to hold experiment data into the above folder
pfolder = [mainFolder '/' num2str(id) '/'];
  % file for participant information
ct = fix(clock);
ct = sprintf('%4d%02d%02d%02d%02d', ct(1:end-1));
partinfo = {['ID,' num2str(id)] ['DATE,' ct] 'NAME' 'GENDER' 'AGE' 'STROOP' 'CAMERA'};
  % file for stroop
strp = {'Trial #, Color Name, Real Color, Responded?, Which?, Correct?, Onset Time, Response Time, Delay'};
  % file for emotion regulation
emrgl = {'Pic #, Pic Emotion, Response'};

files = {ct 'stroop' 'reg' 'mood1' 'mood2' 'questnr'};
% Contents
ctn = {partinfo strp emrgl {''} {''} {''}};

for i = 1:length(files)
    f = files{i};
    fprintf('[+] Generating %s.csv........', f);
    fid = fopen([pfolder f '.csv'], 'wt');
    fprintf(fid, '%s\n', ctn{i}{:});
    fclose(fid);
    fprintf('Success!\n');
end

fprintf('\n[*] Data files for participant #%d generated successfully at:\n    %s\n', id, pfolder);

end
