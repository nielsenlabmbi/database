function [lensInfo,calFactor]=KeyenceMetadata(imageFile)

%imageFile='D:\RV_LayersByArea\test images\FEAH4_PV_S1_c3_r3_testComppressed1.tif';

% open image as binary
fid = fopen(imageFile, 'rb');

% read all
fileContent = fread(fid, '*uint8');
fclose(fid);

%% Search for start of the xml part (if it starts with '<?xml')
xmlStartIdx = strfind(fileContent', '<?xml');
if isempty(xmlStartIdx)
    disp('No xml part found.');
    calFactor=NaN;
    lensInfo='NaN';
else
    % Extract xml part
    xmlContent = fileContent(xmlStartIdx:end);

    %convert to string to make readable
    xmlString=char(xmlContent');

    % find parts we care about
    pat1='>';
    idx1=strfind(xmlString,pat1); %this will be used for all searches

    %calibration
    pat2='</Calibration>';
    idxStop=strfind(xmlString,pat2);
    idxStart=max(idx1(idx1<=idxStop));
    calString=xmlString(idxStart+1:idxStop-1);

    %this needs to be converted to double, which is a bit complicated because
    %we start with a string that then needs to be interpreted as a byte pattern
    calFactor=typecast(uint64(str2double(calString)),'double');
    calFactor=calFactor/1000; %to get to um per pixel

    %lens
    pat2='</LensName>';
    idxStop=strfind(xmlString,pat2);
    idxStart=max(idx1(idx1<=idxStop));
    lensString=xmlString(idxStart+1:idxStop-1);

    %get magnification
    pat=digitsPattern(2)+'x';
    s=extract(lensString,pat);
    lensInfo=s{1};
end
