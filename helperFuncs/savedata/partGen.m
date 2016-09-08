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
partinfo = {['ID,' num2str(id)] ['DATE,' ct] 'NAME' 'GENDER' 'AGE'};
  % file1
file1 = {'Trial #, var1, var2, var3'};
  % file2
file2 = {'#, var1, var2, var3'};
  
files = {ct 'file1' 'file2' 'file3'};
% Contents
% file3 is blank file
ctn = {partinfo file1 file2 {''}};

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
