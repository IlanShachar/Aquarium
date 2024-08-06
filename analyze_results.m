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
% title('Travel Time');

% subplot(2,2,4);
figure;imagesc(abs(IR)');
ylabel('Function Call Number','FontSize',16)
xlabel('Delay [bins]','FontSize',16)
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
% title('Mean Tap Number')
% subplot(2,2,1);
figure;plot(mean(metrics.ds))
p=polyfit(1:length(tn),mean(metrics.ds),1);
hold on
plot(1:length(tn),(1:length(tn))*p(1) + p(2),'LineWidth',3)
ylabel('Delay Spread [seconds]','FontSize',16)
xlabel('Function Call Number','FontSize',16)
% title('Mean Delay Spread')
% h.Position = [1 41 1536 748.8000];