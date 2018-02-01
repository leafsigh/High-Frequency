% This is an algorithm for "robot1" that will interact with the simulated
% market environment.

% In this script, robot_1 places a passive order at the best, but never
% places a bid above fundamental value or an ask below fundamental value.
max_potential_quantity_robot1=100;

alive_indicator_robot_j=1;
message_type=1;

FV=(max_price+min_price)/2;

if (best_bid<FV)&&(best_ask<FV) %best bid and best ask both below FV
    buy_sell_robot_j=1;
    quantity_robot_j=randi(max_quantity);
    price_robot_j=best_bid;
    
elseif (best_bid>FV)&&(best_ask>FV) %best bid and best ask both above FV
    buy_sell_robot_j=-1;
    quantity_robot_j=randi(max_potential_quantity_robot1);
    price_robot_j=best_ask;
    
else %best bid below FV and best ask above FV
    
    % randomly choose buy/sell with equal probability
    buy_sell_robot_j=randi(2);
    buy_sell_robot_j=2*(buy_sell_robot_j-1.5);

    %set order price to best on chosen side
    if buy_sell_robot_j==1
        price_robot_j=best_bid;
    else
        price_robot_j=best_ask;
    end
    
    quantity_robot_j=randi(max_potential_quantity_robot1);
end
