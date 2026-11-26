function [sortDone,NSU,NMU] = checkSort(filename,sortPath)

%run through files in excel spreadsheet and check whether sorted
%return sort as matlab variable and also update file if chosen
%
%inputs: 
% filename: excel spreadsheet; needs to have the following columns:
%       Animal, Unit, Experiment, Probe, Suffix
% sortPath (optional): look for sort files in a folder other than the
%       standard folder on Z
%
% outputs:
%   sortDone: file sorted? (0/1)
%   NSU: nr single units in file
%   NMU: nr multi units in file
%   note: adding the last 2 makes processing slower because it requires
%   reading the sort file

arguments
    filename (1,1) string {mustBeText}
    sortPath (1,1) string='Z:\EphysNew\processedSpikes';
end

xlsTable=readtable(filename,'Sheet','Dataset');
xlsTable=convertvars(xlsTable,'Probe',@num2str);
 
sortDone=zeros(height(xlsTable),1);
NSU=zeros(height(xlsTable),1);
NMU=zeros(height(xlsTable),1);

% check for sort files
h=waitbar(0,'Checking files');
for i=1:height(xlsTable)
    waitbar(i/height(xlsTable),h);

    AUE=[xlsTable.Animal{i} '_u' xlsTable.Unit{i} '_' xlsTable.Experiment{i}];
    fname=fullfile(sortPath,xlsTable.Animal{i},AUE,[AUE '_p' xlsTable.Probe(i) '_spkSort.mat']);

    if isfile(fname)
        sortDone(i)=1;
        if nargout>1 %determining nr units requires opening the file
            load(fname);
            NSU(i)=sum(strcmp(spkSort.unitinfo,'SU'));
            NMU(i)=sum(strcmp(spkSort.unitinfo,'MU'));
            clear spkSort
        end
    end
end

close(h);




