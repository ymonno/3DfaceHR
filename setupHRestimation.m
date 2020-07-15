function setupHRestimation(path_to_dataset)

p = mfilename('fullpath');
[installDirec,] = fileparts(p);
if nargin ==0
    path_to_dataset = installDirec;
end
if ~exist(path_to_dataset)
    mkdir(path_to_dataset)
end

% download sample data recoded in TokyoTech
urlTokyotechData = 'http://www.ok.sc.e.titech.ac.jp/res/VitalSensing/3DfaceHR/data/TokyoTech.zip';
filenameTokyotechData= path_to_dataset;
unzip(urlTokyotechData,filenameTokyotechData)

addpath(genpath(installDirec))

end