[cPath, cName, cExt] = fileparts(mfilename('fullpath'));

% Add mic
addpath(genpath(fullfile(cPath, '..', '..')));


h = figure();


st1 = struct();
st1.lAsk        = true;
st1.cTitle      = 'Switch?';
st1.cQuestion   = 'Do you want to change from OFF to ON?';
st1.cAnswer1    = 'Yes of course!';
st1.cAnswer2    = 'No not yet.';
st1.cDefault    = st1.cAnswer2;


st2 = struct();
st2.lAsk        = true;
st2.cTitle      = 'Switch?';
st2.cQuestion   = 'Do you want to change from ON to OFF?';
st2.cAnswer1    = 'Yes of course!';
st2.cAnswer2    = 'No not yet.';
st2.cDefault    = st2.cAnswer2;



clock = Clock('Master');

stParams = struct();
stParams.cName = 'Test';
stParams.clock = clock;
stParams.cLabel = 'Test A';
stParams.dPeriod = 1;
stParams.dWidthToggle = 50;

stParams.stUitParams = struct();
stParams.stUitParams.lAsk = true;
stParams.stUitParams.stF2TOptions = st1;
stParams.stUitParams.stT2FOptions = st2;


hiot = HardwareIOToggle(stParams);
hiot.build(h, 10, 10);

 
% For development, set real API to an APIV instance

st = struct();
st.cName = sprintf('%s-api', hiot.cName);

apiv = APIVHardwareIOToggle(st);
hiot.setApi(apiv);
