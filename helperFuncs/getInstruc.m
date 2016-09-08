function [ instruc ] = getInstruc(  )
%GETINSTRUC Return instructions for different device
% Newline: linux - \n; osx - \r; windows - \r\n
% I'm using "\n" in the file for new line of instuctions
% One paragraph is an instruction
% And a new paragraph will recognised as another instruction
% Change the delimiter of your file to avoid problem
% ; + * ! # etc. make it something you won't use in the instructions

filename = 'instruction.txt';
fid = fopen(filename);
if fid < 0
    error('[!] File < %s > not found; check if filename is valid', filename);
end
c = textscan(fid, '%s', 'delimiter', '\r\n');
fclose(fid);
instruc = c{1};

for i = 1:length(instruc)
    instruc{i} = double(instruc{i});
end
end

