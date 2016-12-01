close all
clear all
purge


s = serial('COM1');
s.BaudRate = 19200;
s.Terminator = 'CR/LF';
% s.ReadAsyncMode = 'manual';

get(s)

fopen(s);

fprintf(s, ':curr:aver?', 'async');
fprintf(s, ':curr:aper?', 'async');
% fprintf(s, ':curr:aver?');


s.BytesAvailable
readasync(s);
s.BytesAvailable

tic
c = fscanf(s)
toc
tic
c = fscanf(s)
toc
fclose(s);