purge

% Set current directory to the directory containing this file
[filepath, filename, ext] = fileparts(mfilename('fullpath'));
cd(filepath);
            

addpath(pwd);
addpath(fullfile(pwd, 'classes'));
addpath(fullfile(pwd, 'functions'));


test = TestProgressBar();
test.build();


