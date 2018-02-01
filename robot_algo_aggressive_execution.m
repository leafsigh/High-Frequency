%-------------------------------------------------%
%
%           FIN566 PS#5 Q4a,b,c Robot1 Algorithm
%
%              
%               10/17/2017
%
%            First Version: 10/17/2013
%
%-------------------------------------------------%

%-------------------------------------------------%
% LEAVE THESE FIXED!
goal_inventory_level=1000;
buy_sell_robot_j=1;
price_robot_j=max_price;
FAK_indic=1;
message_type=1;
%-------------------------------------------------%

%-------------------------------------------------%

alive_indicator_robot_j=1;

% Set order quantity in such a way that robot1 stops trading after he
% reaches his goal inventory level
safety_factor=1.5;
max_potential_quantity_robot1=10;


% % Version for part (a)
% quantity_robot_j=min(max_potential_quantity_robot1,(goal_inventory_level-robot1_cum_net_inventory),bid_ask_depth_stor_mat((t-1),2));
% quantity_robot_j=max(0,quantity_robot_j);


% % Version for part (b)
quantity_robot_j=min((goal_inventory_level-smart_robot_cum_net_inventory(8)),bid_ask_depth_stor_mat((t-1),2));
quantity_robot_j=max(0,quantity_robot_j);

% % Version for part (c)
% quantity_robot_j=min(max_potential_quantity_robot1,(goal_inventory_level-robot1_cum_net_inventory),bid_ask_depth_stor_mat((t-1),2));
% quantity_robot_j=max(0,quantity_robot_j);
% if (bid_ask_stor_mat((t-1),2)-bid_ask_stor_mat((t-1),1))>1
%     quantity_robot_j=0;
% end









   