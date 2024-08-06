function cost = cost (input)
load(strcat('Results_',num2str(randi(10)),'.mat'))
% load(strcat('Results_11.mat'))
cost = zeros(length(input),2);
%% 2d
% cost(:,1) = griddata(x,y,delay_spread,range,depth,'cubic');
% cost(:,2) = griddata(x,y,taps,range,depth,'cubic');
%% 1d
% cost(:,1) = spline(L,delay_spread,input);
% cost(:,2) = spline(L,tap_num,input);
%% no interpolation
for ii=1:length(input)
    [~,I] = min(abs(L - input(ii)));    
%     cost(ii,:) = [res(1,I),res(2,I)];
    cost(ii,:) = [delay_spread(I),tap_num(I)];
end