close all
clear all
purge


s = serial('COM1');
s.BaudRate = 19200;
s.Terminator = 'CR/LF';
% s.ReadAsyncMode = 'manual';

get(s)

fopen(s);

fprintf(s, ':curr:aver?');
fprintf(s, ':curr:aper?');
% fprintf(s, ':curr:aver?');


s.BytesAvailable
readasync(s);
s.BytesAvailable


c = fscanf(s)
c = fscanf(s)

fclose(s);