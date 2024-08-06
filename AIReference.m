close all
%clear
clc

fid1 = fopen('log1.txt','w');
%------------------------f----------------------------------------------------------------------------------
Ttot=6;%Total duration time [s]
Tso=2;%start output 
Tdo=2;%duration output

fsin=10;%Hz - for output data
Fs = 250e3;			% set the sample rate, with 6 channels, 40kHz is the maximum

% fs=[8000,8192,11025,16000,22050,32000,44100,47250,48000,50000,88200,96000,176400,192000];% StandardSampleRates
   %   1    2     3     4     5     6     7     8     9    10    11     12    13  1
%% Setup Session, Add Channels and Configure Parameters
d = daq.getDevices;
% list_id={d(:).ID};
% dev1=d(strcmp(list_id,'Dev1'));%Analog inputs
%dev2=d(strcmp(list_id,'Audio1'));%Analog inputs
%dev3=d(strcmp(list_id,'Audio2'));%Analog outputs

% ses = daq.createSession('directsound');%Create the data acquisition session with directsound!
%ses2 = daq.createSession('directsound');%Create the data acquisition session with directsound!

ses = daq.createSession('ni');	%Create the data acquisition session with directsound!

%ses2.Rate = fs(12);%Define Sampling rate
% ses.Rate = fs(12);%Define Sampling rate
ses.Rate = Fs;
%ses2.IsContinuous = true;
%tsin=0:1/ses2.Rate:Tdo-1/ses2.Rate;%t of an output signal
%output_data=sin(2*pi*fsin*tsin);

ses.IsContinuous = true;
% ses.addAudioInputChannel(ses, dev1.ID,1);%Create analog input channel with board ID 'Audio6', Channels '1+2', measuring 'Audio'
%addAudioInputChannel(ses, dev2.ID,1:2);%Create analog input channel with board ID 'Audio10' (maybe Audio3), Channels '3+4', measuring 'Audio'
ses.addAnalogInputChannel('Dev1','ai0','Voltage');
%addAudioOutputChannel(ses2,dev3.ID,1);
%queueOutputData(ses2,output_data') 
%lho = addlistener(ses2,'DataRequired', @(src,event) src.queueOutputData(output_data'));
global param;
    param.sig=[];
    lh = addlistener(ses,'DataAvailable',@(src, event)logData(src,event));

% lh = addlistener(ses,'DataAvailable',@(src, event)logData2(src,event,fid1));
% startBackground(ses);
% pause(Tso);
%% Acquisition

    disp('Start receiving');

    % start the recording
    startBackground(ses);
pause(40);
%stop(ses2);
stop(ses);

disp('Stop receiving');
%ses2.release();
%ses2.IsContinuous = false;
%delete(lho);
ses.release();
ses.IsContinuous = false;
delete(lh);
% fclose(fid1);
%delete(ses);
%clear ses;
Sig = param.sig;



%% Log data
function logData(src, evt)
    global param;
    param.sig = [param.sig; evt.Data];
end
