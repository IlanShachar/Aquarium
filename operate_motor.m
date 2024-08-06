    clear ses3
    d = daq.getDevices;
    n=3;
    ses3 = daq.createSession('ni');%Create the data acquisition session with directsound!
    ses3.addDigitalChannel('Dev1','port0/line0:2','OutputOnly');
    down = [1,0,1];
    up = [0,1,1];
    stop = [1,1,1];%[0,0]; %need to figure out which one is correct
    off = [0,0,0];
    outputSingleScan(ses3,down);
    pause(n);
    outputSingleScan(ses3,up);
    pause(n)
    outputSingleScan(ses3,stop);
    pause(n)
    outputSingleScan(ses3,off);