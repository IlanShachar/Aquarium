%% This script runs an optimization using actual live data from the aquarium
%% with an adjustable wall
clear all
global matched_filter metrics travel_times Tduration impulse_res f0 BW multiplier

Tduration = 5; %in ms - also possible to run loop on various values
f0 = 35e3; BW = 1e4; 
BW = 5e3;
for multiplier = 1.4:0.2:2.2%Tduration = 3:8 %
%   for f0 = [20e3 23e3 26e3]
    impulse_res = [];
    matched_filter = [];
    metrics.ds = [];
    metrics.tn = [];
    travel_times = [];
    d = daq.getDevices;
    fun = @Aquarium_cost3;
    nvars = 1;
    % tot=[];    % ds=[];
    % tn=[];
    % ds=delay_spread;
    % tn=tap_num;
    % for jj=1:10
    %     load(strcat('Results_',num2str(jj)));
    %     %     figure(3); errorbar(L,delay_spread,sqrt(DS_var)); hold on
    %     %     figure(4); errorbar(L,tap_num,sqrt(TN_var)); hold on
    % %     figure(8); scatter(tn,ds,'b');hold on;
    %     %     tn=min(tn,tap_num);
    %     %     ds=min(ds,delay_spread);
    %     tot = cat(1,tot,res);
    %     ds = [ds,delay_spread];
    %     tn = [tn,tap_num];
    % end
    %set options for pareto optimization


    opts = optimoptions(@gamultiobj,'UseVectorized',true,'PlotFcn','gaplotpareto');
    %comment next line if you wish to see the optimization happen in real time,
    %and not just the end results
    opts.PlotFcn=[];
    % popind is the size of the population for every generation
    for popind = 10
    %     figure(10)
    %     scatter(tn,ds,'x')
    %     hold on
    %     ax = gca;
    %     % flip y axis to get ROC like curves.
    %     ax.YDir='reverse';
    %     hold on
    %     xlabel('Tap Number')
    %     ylabel('Delay Spread')
        %genind is the number of generation - the total number of function
        %evaluations is genind*popind
        for genind = 10
    %         figure;
    %         scatter(tn,ds)
    %         x=40:0.1:55;
            opts.PopulationSize = popind;
            opts.MaxGenerations = genind;
    %         ax = gca;
    %         ax.YDir='reverse';
    %         hold on
    %         xlabel('Tap Number')
    %         ylabel('Delay Spread')

    %         T=[];
    %         D=[];
    %         clear title
    %         for ii=1:100
    %             hold on;
    %             val=0;
    %             while length(val)<3
                    [xga,fvalga,~,gaoutput] = gamultiobj(fun,nvars,[],[],[],[],0,25,[],opts);
                    [val,Ia,Ic]=unique(fvalga(:,1));
    %             end
                %             figure(popind*genind^2)
                %             close
                %             fit(ii,:)=spline(fvalga(Ia,2),fvalga(Ia,1),x);
    %             T=[T;fvalga(Ia,2)];
    %             D=[D;fvalga(Ia,1)];
    %                         plot(fvalga(Ia,2),fvalga(Ia,1))
    %         end
            %         F=fit(T,D,'poly3');
            %         plot(x,feval(F,x));
    %         F=fit(T,D,'poly2');
    %         plot(x,feval(F,x));
    %         figure(10)
    %         plot(x,feval(F,x),'LineWidth',2);
            count=gaoutput.funccount;
    %         title(strcat('Tap Number vs Delay Spread - {}',num2str(count),' func count'));
            %         legend(num2str((1:11)'));
        end
    %     legend(['dt';num2str((10:10:60)')]);
    end
    matched_filter = reshape(matched_filter,size(matched_filter,1),length(travel_times),[]);
    save([date '_f0' num2str(f0) 'KHz_ThX' num2str(multiplier) '.mat'],'matched_filter','travel_times','metrics', 'impulse_res','multiplier')
%   end
end
clear matched_filter metrics travel_times Tduration impulse_res f0 BW multiplier