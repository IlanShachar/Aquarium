%% This script loads the entire experimental database and displays it as 
%% well as running 100 optimizations for each combination of population 
%% size and number of generations. It then uses the results to make a second 
%% order polynomial fit in order to compare the relative performance of each 
%% combination (although the comparison is made according to the numer function 
%% evaluations)
fun = @cost;
tot=[];
ds=[];
nvars=1;
tn=[];
load(strcat('Results_1'));
ds=delay_spread;
tn=tap_num;
for jj=1:10
    load(strcat('Results_',num2str(jj)));
    %     figure(3); errorbar(L,delay_spread,sqrt(DS_var)); hold on
    %     figure(4); errorbar(L,tap_num,sqrt(TN_var)); hold on
%     figure(8); scatter(tn,ds,'b');hold on;
    %     tn=min(tn,tap_num);
    %     ds=min(ds,delay_spread);
    tot = cat(1,tot,res);
    ds = [ds,delay_spread];
    tn = [tn,tap_num];
end
%set options for pareto optimization
opts = optimoptions(@gamultiobj,'UseVectorized',true,'PlotFcn','gaplotpareto');
%comment next line if you wish to see the optimization happen in real time,
%and not just the end results
opts.PlotFcn=[];
% popind is the size of the population for every generation
for popind = [10]
    figure(10)
    scatter(tn,ds,'x')
    hold on
    ax = gca;
    % flip y axis to get ROC like curves.
    ax.YDir='reverse';
    hold on
    xlabel('Tap Number')
    ylabel('Delay Spread')
    %genind is the number of generation - the total number of function
    %evaluations is genind*popind
    for genind = [1:6]
        figure;
        scatter(tn,ds)
        x=40:0.1:55;
        opts.PopulationSize = popind;
        opts.MaxGenerations = genind;
        ax = gca;
        ax.YDir='reverse';
        hold on
        xlabel('Tap Number')
        ylabel('Delay Spread')
        T=[];
        D=[];
        clear title
        for ii=1:100
            hold on;
            val=0;
            while length(val)<3
                [xga,fvalga,~,gaoutput] = gamultiobj(fun,nvars,[],[],[],[],25,84,[],opts);
                [val,Ia,Ic]=unique(fvalga(:,1));
            end
            %             figure(popind*genind^2)
            %             close
            %             fit(ii,:)=spline(fvalga(Ia,2),fvalga(Ia,1),x);
            T=[T;fvalga(Ia,2)];
            D=[D;fvalga(Ia,1)];
                        plot(fvalga(Ia,2),fvalga(Ia,1))
        end
        %         F=fit(T,D,'poly3');
        %         plot(x,feval(F,x));
        F=fit(T,D,'poly2');
        plot(x,feval(F,x),'LineWidth',2);
        figure(10)
        plot(x,feval(F,x),'LineWidth',2);
        count=gaoutput.funccount;
        title(strcat('Tap Number vs Delay Spread - {}',num2str(count),' func count'));
        %         legend(num2str((1:11)'));
    end
    legend(['dt';num2str((10:10:60)')]);
end