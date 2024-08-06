function temp = Aquarium_cost3 ( time  )
%function for getting max likelyhood cost


delay_spread=zeros(length(time),1);
tap_num=delay_spread;
for ii=1:length(time)
     [delay_spread(ii),tap_num(ii)] = Aquarium_cost2(time(ii));
end
temp=[delay_spread,tap_num];
    
