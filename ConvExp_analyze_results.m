load('22-Jun-2020_f0_35KHz_ThX2.2.mat')

[m,I] = min(sqrt((metrics.tn - ones(size(metrics.tn,1),1)*mean(metrics.tn)).^2 + ...
(metrics.ds - ones(size(metrics.ds,1),1)*mean(metrics.ds)).^2));
impulse_res = reshape(impulse_res,size(impulse_res,1),length(travel_times),[]);

for ii = 1:size(metrics.ds,2)
    ds(ii) = metrics.ds(I(ii),ii);
    tn(ii) = metrics.tn(I(ii),ii);
    IR(:,ii) = impulse_res(:,ii,I(ii));
end
% h = figure; subplot(2,2,3);
figure
plot(travel_times)
ylabel('Travel Time [sec]','FontSize',16)
xlabel('Function Call Number','FontSize',16)
grid on
% title('Travel Time');

% subplot(2,2,4);
image = abs(IR(250:1000,:))';
y = 1:size(image,1);
x = (1:size(image,2))/25;
figure;imagesc(x,y,image);
colormap(flipud(pink))
ylabel('Function Call Number','FontSize',16)
xlabel('Delay [ms]','FontSize',16)
colorbar
% title('Impulse Response Convergence');

% subplot(2,3,1);plot(ds)
% ylabel('Delay Spread [bins]')
% xlabel('Function Call Number')
% title('Best Delay Spread')
% subplot(2,3,2);plot(tn)
% ylabel('Tap Number [bins]')
% xlabel('Function Call Number')
% title('Best Tap Number')
% subplot(2,2,2);
figure;plot(mean(metrics.tn))
p=polyfit(1:length(tn),mean(metrics.tn),1);
hold on
plot(1:length(tn),(1:length(tn))*p(1) + p(2),'LineWidth',3)
ylabel('Tap Number [bins]','FontSize',16)
xlabel('Function Call Number','FontSize',16)
grid on
% title('Mean Tap Number')
% subplot(2,2,1);
figure;plot(mean(metrics.ds)*1e3)
p=polyfit(1:length(tn),mean(metrics.ds)*1e3,1);
hold on
plot(1:length(tn),(1:length(tn))*p(1) + p(2),'LineWidth',3)
ylabel('Delay Spread [ms]','FontSize',16)
xlabel('Function Call Number','FontSize',16)
grid on
% title('Mean Delay Spread')
% h.Position = [1 41 1536 748.8000];
for ii = 1:4
    figure(ii)
    savefig(['ConvExp_35k_2_' int2str(ii)]);
    print(['ConvExp_35k_2_' int2str(ii)],'-dpng','-r0');
end
pos = [1,20,50];
for ii = 1:3
    x=abs(matched_filter(251:end,pos(ii),1));
    figure;semilogy((1:1251)/25,x/sum(x));xlim([0,20]);grid on;
    ylabel('Amplitude', 'FontSize',16); xlabel('Time [ms]', 'FontSize',16);
    savefig(['IR_pos' int2str(ii)]);
    print(['IR_pos' int2str(ii)],'-dpng','-r0');
end
