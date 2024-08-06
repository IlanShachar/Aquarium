function [delay_spread, tap_num] = Aquarium_cost2 ( time  )
%function for getting max likelyhood cost
global metrics travel_times
    N = 10;
    ds = zeros(1,N);
    tn = ds;
    % dispmnt = round(dispmnt*2)/2;
    % fprintf('Please move hydrophone to: %s cm.\n',num2str(dispmnt));
    % pause
    ses3 = daq.createSession('ni');%Create the data acquisition session with directsound!
    ses3.addDigitalChannel('Dev1','port0/line0:2','OutputOnly');
    down = [1,0,1];
    up = [0,1,1];
    stop = [1,1,1];%[0,0]; %need to figure out which one is correct
    off = [0,0,0];
    outputSingleScan(ses3,stop);
    fprintf('Moving for %s seconds.\n',num2str(time));
    outputSingleScan(ses3,down);
    pause(time);
    outputSingleScan(ses3,stop);
    fprintf('Pause for water to settle.\n');
    pause(15);

    for ii = 1:N
        [ds(ii), tn(ii)] = Aquarium_cost ( time  );
        pause(1);
    end
    outputSingleScan(ses3,up);
    pause(time + 2);
    outputSingleScan(ses3,stop);
    outputSingleScan(ses3,off);
    [a,b] = hist(ds,200);
    [val,I] = max(a);
    delay_spread = round(b(I));
    [a,b] = hist(tn,200);
    [val,I] = max(a);
    tap_num = round(b(I));
    delay_spread = mean(ds);
    tap_num = mean(tn);
    travel_times = [travel_times, time]; %add time to global parameter times
    metrics.ds = [metrics.ds, ds(:)];   %add ds to global metrics variable
    metrics.tn = [metrics.tn, tn(:)];   %add tn to global metrics variable
    
    