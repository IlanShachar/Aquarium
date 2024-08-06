function [delay_spread, tap_num] = Aquarium_cost ( time  )
% dispmnt = round(dispmnt*2)/2;
% fprintf('Please move hydrophone to: %s cm.\n',num2str(dispmnt));
% pause
% keyboard;
%% Setup
global matched_filter Tduration impulse_res f0 BW multiplier
    Fs = 250e3;			% set the sample rate, with 6 channels, 40kHz is the maximum

    Ttot = 0.2;%Total duration time [s]
    Tso = 0;%start output 
    Tdo = Tduration*1e-3;%duration output
    
    
%     Tdo = 5e-3;
%     multiplier = 2;
%     f0 = 26e3; BW = 3e3;%Hz - for output data
    
    
    f1 = f0 + BW; %30e3;



    %Setup Session, Add Channels and Configure Parameters
    d = daq.getDevices;
%     list_id={d(:).ID};
MF_len=0; p4=1; p5=1;
while MF_len<p4&&MF_len<p5
    ses = daq.createSession('ni');	%Create the data acquisition session with directsound!
    ses2 = daq.createSession('ni');%Create the data acquisition session with directsound!
    ses.Rate = Fs;			%Define Sampling rate
    ses2.Rate = Fs;			%Define Sampling rate
    ses.IsContinuous = true;

    % add 1 channels to the session. It can be customized
    ses.addAnalogInputChannel('Dev1','ai0','Voltage');

    ses2.addAnalogOutputChannel('Dev1','ao0','Voltage'); %Add output channel

    tsin = 0:1/Fs:Tdo-1/Fs;%t of an output signal
    Ref = 0.0005*chirp(tsin,f0,Tdo,f1);
    queueOutputData(ses2,Ref');
    lho = addlistener(ses2,'DataRequired', @(src,event) src.queueOutputData(Ref'));

    global param;
    param.sig=[];
    lh = addlistener(ses,'DataAvailable',@(src, event)logData(src,event));

%% Acquisition

    disp('Start receiving');

    % start the recording
    startBackground(ses);
    pause(Tso);

    %starting transmitting
    startBackground(ses2)

    pause(Tdo)
    pause(Ttot-Tso-Tdo)

    stop(ses2);
    stop(ses);

    disp('Stop receiving');

    ses2.release();
    ses2.IsContinuous = false;
    delete(lho);
    ses.release();
    ses.IsContinuous = false;
    delete(lh);
    delete(ses);
    delete(ses2);

    Sig = param.sig;

    clear ses ses2 lh lho d param

%% Analyze

    Factor = 10;
    Pf = 0.08;
    Ts = 0.1;


    Fc = (f0+f1)/2;
    W = f1 - f0;

    L = 128;  % BP filter length
    % BPF:
    B = 1.2*W;    % BPF band
    % BB conversion:
    bLPF = fir1(L, B/Fs);
    FsBB = Fs/Factor;
%     b = fir1(1000,[20/125 30/125],'bandpass');
%     Sig=filter(b,1,Sig);
    [RefBB, ~, ~, ~] = ConvertToBBVer0(Ref, Fc, Fs, Factor, bLPF);
    [SigBB, ~, ~, ~] = ConvertToBBVer0(Sig', Fc, Fs, Factor, bLPF);

    MF = xcorr(SigBB,RefBB);
%     figure;plot(abs(MF))
    
%     %% Ilan's matched filter - comment to disengage
%     Ref2 = [Ref zeros(1,length(Sig) - length(Ref))];
%     MF=ifft(fft(Sig).*fft(Ref2)');
%     
%     figure;plot(abs(MF))
%     movRMS = dsp.MovingRMS('Method','Exponential weighting','ForgettingFactor',0.99);
%     MF = step(movRMS,MF);
%     figure;plot(MF);
%     FsBB = Fs;
%     
%     %% end of ilan's MF
    
    [~,p1] = max(abs(MF));
    p2 = p1 - FsBB*1e-2;
    p3 = p1 - FsBB*2*1e-3;
%     TH = max(abs(MF(1:p2)))*multiplier;
    TH = max(abs(MF))/multiplier;
%     temp = MF; temp(MF<TH*1.5) = 0;
%     figure;plot(temp);
    p4 = p1 + FsBB*3e-2; 
    p5 = p1 + FsBB*5e-2; 
%     TH = CalcTH(W*Ts, Pf)*sqrt(2);
    MF_len = length(MF);
%     loc = find(abs(MF) < TH);
    try
        IR = MF(p2:p5);
        IR(abs(IR) < TH) = 0;
    catch
        p3
        p4
        MF_len = 0;
        continue;
    end


    MF = MF(p2:p5);
    impulse_res = [impulse_res, IR(:)];
    matched_filter = [matched_filter, MF(:)];  %add IR to global matched_filter variable
    

    tMF = linspace(0, length(MF)/FsBB, length(MF));
    
%     figure; plot((1:length(Sig))/Fs, Sig);
%     figure;plot(abs(MF));
%     figure;plot( abs(IR));
%     figure;spectrogram(Ref,hanning(1024,'periodic'),round(1024*0.95),1024*2,Fs,'yaxis'); colormap jet
%     ylim([0,35])
%     figure;spectrogram(Sig,hanning(1024,'periodic'),round(1024*0.8),1024*2,Fs,'yaxis'); colormap jet
%     ylim([0,35])
%     
%     figure; plot(Sig)
    
    indices = find(IR);
    try 
%         delay_spread = indices(end) - indices(1);
        pdp = abs(IR((p1-p2):end));
        t = (1:length(pdp))/FsBB;
        zero_moment = sum(pdp);
        first_moment = sum(t.*pdp) / zero_moment;
        second_moment = sum((t - first_moment).^2.*pdp) / zero_moment;
        delay_spread = sqrt(second_moment);
%         tap_num = length(indices);
        tap_num = length(find(indices(2:end) - indices(1:end-1) - 1)) + 1;
    catch
        indices
        MF_len = 0;
%         matched_filter = matched_filter(:,1:end-1);
%         impulse_res = impulse_res(:,1:end-1);
    end
  end
end
%% Log data
function logData(src, evt)
    global param;
    param.sig = [param.sig; evt.Data];
end

