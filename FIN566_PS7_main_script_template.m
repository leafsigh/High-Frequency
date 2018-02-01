% %If you are going to run this script independently, rather than calling
% it from a meta-script, uncomment the two "Independence Commands" below,
% as indicated.

run_main_script_independently_indic=0;

% %*****Independence Commands*********** (Uncomment to run this script independently)
clear
run_main_script_independently_indic=1; 
l=1;
%tic


% %% %*****Startup Tasks***********
% 
% if run_main_script_independently_indic==1
%    'Alert: script is running independently, using locally specified parameter values'
    
%*****Setting the appropriate path 
    %(This will need to be modified on each individual computer)
    %(I just need to uncomment the appropriate path file)
    
'Home MBP'
Matlab_trading_simulations_folder='/Users/yisongdong/Desktop/MSF&Python/MSF/Algorithmic MKT Microstructure/Problem set7/untitled folder/untitled folder';

p=path;
path(p,Matlab_trading_simulations_folder);

cd(Matlab_trading_simulations_folder)

matching_engine_algo='Enter_cancel_mod_matching_subscript_battlebots';

orderbook_construction_code='orderbook_depth_construction_subscript';

number_of_smart_robots=8;  

robot1_commands='robot_algo_mm_template';%
robot2_commands='know_lop_only';%
robot3_commands='robot_algo_uprice_MM_FV';
robot4_commands='robot_algo_aggressive_execution';

smart_robot_commands_cell=cell(number_of_smart_robots,1);

smart_robot_commands_cell{1}=robot1_commands;
smart_robot_commands_cell{2}=robot1_commands;
smart_robot_commands_cell{3}=robot2_commands;
smart_robot_commands_cell{4}=robot2_commands;
smart_robot_commands_cell{5}=robot3_commands;
smart_robot_commands_cell{6}=robot3_commands;
smart_robot_commands_cell{7}=robot4_commands;
smart_robot_commands_cell{8}=robot4_commands;

background_trader_commands='bgt_behavior_rw_price_FAK_ECM';

t_max=10000;

burn_in_period=3322;

num_bgt=30;

smart_robot_activity_fraction=.3;

vol_cnt = 40;

meta = 30;

meach_sim_transac_price=zeros(t_max,l);

meta_test_robot_profits_comparison_matrix=zeros(meta,vol_cnt);
meta_test_robot_trading_volume=zeros(meta,vol_cnt);
meta_test_robot_final_inventory_position=zeros(meta,vol_cnt);
meta_test_robot_final_cash_position=zeros(meta,vol_cnt);
meta_test_robot_final_inventory_inshare=zeros(meta,vol_cnt);

meta_profits_comparison_matrix=zeros(meta,number_of_smart_robots);
meta_volume_comparison_matrix=zeros(meta,number_of_smart_robots);


%Meta Loop%
for l=1:meta
    
l

tic
%vol IC parameter%

test_robot_activity_fraction=.3;
observe_period =100;
god_view_indic=1;
test_robot_trading_volume=zeros(1,vol_cnt);
test_robot_cum_inventory=zeros(1,vol_cnt);
test_robot_cash_position=zeros(1,vol_cnt);
test_robot_order_reserve = cell(vol_cnt,1);
test_robot_buy_order_reserve = cell(vol_cnt,1);
test_robot_sell_order_reserve = cell(vol_cnt,1);

for m=1:vol_cnt
    
    test_robot_order_reserve{m}=zeros(t_max,4);
    test_robot_buy_order_reserve{m}=zeros(t_max,4);
    test_robot_sell_order_reserve{m}=ones(t_max,4)*1000000;

end

%vol Total parameter
test_robot_trading_volume_total=zeros(1,vol_cnt);
test_robot_cum_inventory_total=zeros(1,vol_cnt);
test_robot_cash_position_total=zeros(1,vol_cnt);
test_robot_order_reserve_total = cell(vol_cnt,1);
test_robot_buy_order_reserve_total = cell(vol_cnt,1);
test_robot_sell_order_reserve_total = cell(vol_cnt,1);

for m=1:vol_cnt
    
    test_robot_order_reserve_total{m}=zeros(t_max,4);
    test_robot_buy_order_reserve_total{m}=zeros(t_max,4);
    test_robot_sell_order_reserve_total{m}=ones(t_max,4)*1000000;

end

%naive IC parameter
test_robot_trading_volume_naive = 0;
test_robot_cum_inventory_naive = 0;
test_robot_cash_position_naive = 0;
test_robot_order_reserve_naive = zeros(t_max,4);
test_robot_buy_order_reserve_naive = zeros(t_max,4);
test_robot_sell_order_reserve_naive = ones(t_max,4)*1000000;

max_quantity=100;

max_price=1000;
min_price=1;

price_flex=40;

prob_last_order_price_resets=0.06;
plopr_intercept=0.025;
plopr_ordersize_param=0.05;
perm_price_impact_slope_coeff=plopr_ordersize_param*((1-plopr_intercept)/max_quantity);



%%
% %% %*******Creating Data-Storage Structures***********

live_buy_orders_list=zeros(t_max,7);
live_sell_orders_list=zeros(t_max,7);

bid_ask_stor_mat=zeros(t_max,2);
bid_ask_depth_stor_mat=zeros(t_max,2);

    % time, aggressor sign, price, executed quantity, passor order_id,passor_account_id, aggressor_account_id
transaction_price_volume_stor_mat=zeros(t_max,7);
transaction_price_volume_stor_mat=[ones(1,7);transaction_price_volume_stor_mat];

% For test robot %
godview_transac_mat=zeros(1000,4);
test_robot_compare_mat = zeros(6,vol_cnt);
test_robot_trading_profit_plot = zeros(t_max,vol_cnt);
test_robot_inventory_position_plot = zeros(t_max,vol_cnt);
test_robot_cash_position_plot = zeros(t_max,vol_cnt);

test_robot_compare_mat_total = zeros(6,vol_cnt);
test_robot_trading_profit_plot_total = zeros(t_max,vol_cnt);
test_robot_inventory_position_plot_total = zeros(t_max,vol_cnt);
test_robot_cash_position_plot_total = zeros(t_max,vol_cnt);

test_robot_trading_profit_plot_naive=zeros(t_max,1);
test_robot_inventory_position_plot_naive=zeros(t_max,1);
test_robot_cash_position_plot_naive=zeros(t_max,1);


ao_sign_stor_vec=zeros(t_max,1);

smart_robot_cum_net_inventory=zeros(1,number_of_smart_robots);

smart_robot_order_entry_times=zeros(t_max,1);

% Storing the underlying FV price ("last_order_price") and the actual
% price at which each order is entered
last_order_price_stor_vec=zeros(t_max,1);
entered_order_price_stor_vec=zeros(t_max,1);
entered_order_quantity_stor_vec=zeros(t_max,1);

back_test_data = zeros(t_max,7);

transaction_price_mat = zeros(1,2);

% %% %*******Creating Blank State-Variables that Algos Can Use***********
state_variable_1=0;
state_variable_2=0;
state_variable_3=0;
state_variable_4=0;
state_variable_5=0;
state_variable_6=0;
state_variable_7=0;
state_variable_8=0;
state_variable_9=0;
state_variable_10=0;

% %% %******* Running the Simulation***********

t=1;
order_id=0;
last_order_price=floor((max_price+min_price)/2);


while t<=t_max

background_trader_gets_to_act_test=rand(1);

if background_trader_gets_to_act_test>smart_robot_activity_fraction

robot_j_acct_id=randi(num_bgt)+number_of_smart_robots;

message_type=1;

order_id=t;

eval(background_trader_commands);
   
entered_order_price_stor_vec(t)=price_robot_j;
entered_order_quantity_stor_vec(t)=quantity_robot_j;

back_test_data(t,:) = [robot_j_acct_id, buy_sell_robot_j, price_robot_j, quantity_robot_j, FAK_indic, order_id, t];

eval(matching_engine_algo);
   
if (number_of_execution_records>start_of_time_t_num_execu_recs)
    
    prob_last_order_price_resets=plopr_intercept+perm_price_impact_slope_coeff*entered_order_quantity_stor_vec(t);
    
    test_for_last_order_price_choice_j=rand(1);
 
    if test_for_last_order_price_choice_j<prob_last_order_price_resets
        last_order_price=price_robot_j; 
    end
end

ao_sign_stor_vec(t)=AO_indic_with_sign;

eval(orderbook_construction_code);
  
  last_order_price_stor_vec(t)=last_order_price;

t=t+1;
end

tail = find(transaction_price_volume_stor_mat(:,1),1,'last');
if tail>1 && transaction_price_volume_stor_mat(tail,1)~=transaction_price_volume_stor_mat(tail-1,1) && transaction_price_volume_stor_mat(tail-1,1)~=transaction_price_mat(end,1)
    transaction_price_mat = [ transaction_price_mat;transaction_price_volume_stor_mat(tail-1,1),transaction_price_volume_stor_mat(tail-1,3)];
end

smart_robot_participation_draw=randi(number_of_smart_robots);

smart_robot_gets_to_act_test=rand(1);

if t>=burn_in_period && smart_robot_gets_to_act_test<=smart_robot_activity_fraction

    parent_script_only_price=last_order_price;

    robot_j_acct_id=smart_robot_participation_draw;%DON'T change this!
    
    smart_robot_commands=smart_robot_commands_cell{robot_j_acct_id};

    terminal_message_indic=0; 
    
    while terminal_message_indic==0 
        
        eval(smart_robot_commands);

        back_test_data(t,:)=[robot_j_acct_id, buy_sell_robot_j, price_robot_j, quantity_robot_j, FAK_indic, order_id, t];
        
        if message_type==1
            order_id=t;
        end
        
        if message_type==2
            price_robot_j=entered_order_price_stor_vec(order_id);
        end
        
        
        if (price_robot_j>max_price)||(price_robot_j<min_price)
            message_type=3; 
            alive_indicator_robot_j=0;
        end
        
        if quantity_robot_j==0
            alive_indicator_robot_j=0;
        end
        
        if alive_indicator_robot_j==0
            quantity_robot_j=0;
        end
        
        %Now correct "last_order_price" if it somehow got changed by
        %the "smart_robot_commands" script (that should only ever happen by mistake):
        last_order_price=parent_script_only_price;
        
        
        entered_order_price_stor_vec(t)=price_robot_j;
        entered_order_quantity_stor_vec(t)=quantity_robot_j;
        
        smart_robot_order_entry_times(t)=robot_j_acct_id;
        
        eval(matching_engine_algo);
        
        ao_sign_stor_vec(t)=AO_indic_with_sign;

        eval(orderbook_construction_code);
        
        last_order_price_stor_vec(t)=last_order_price;
        
    end

    t=t+1;
    
    tail = find(transaction_price_volume_stor_mat(:,1),1,'last');
    if tail>1 && transaction_price_volume_stor_mat(tail,1)~=transaction_price_volume_stor_mat(tail-1,1) && transaction_price_volume_stor_mat(tail-1,1)~=transaction_price_mat(end,1)
        transaction_price_mat = [transaction_price_mat;transaction_price_volume_stor_mat(tail-1,1),transaction_price_volume_stor_mat(tail-1,3)];
    end

end

% Test Robot %
partic_test = rand(1);

% % VOL_IC
if t>burn_in_period && partic_test<=test_robot_activity_fraction
    
%     tail = find(transaction_price_volume_stor_mat(:,3),1,'last');
%     observe_mat1 = transaction_price_volume_stor_mat(tail-observe_period:tail-1,3);
%     observe_mat2 = transaction_price_volume_stor_mat(tail-observe_period+1:tail,3);
    taill = find(transaction_price_mat(:,2),1,'last');
    observe_mat1 = transaction_price_mat(taill-observe_period:taill,2);
    observe_mat2 = transaction_price_mat(taill-observe_period-1:taill-1,2);
    return_vec = (observe_mat2-observe_mat1)./observe_mat1;
    downside_vec = return_vec(return_vec<0);
    upside_vec = return_vec(return_vec>0);
    downside_std = std(downside_vec);
    upside_std = std(upside_vec);
    vol_mark_mat = linspace(0,0.01,vol_cnt);
    
    for i=1:vol_cnt
        % test robot command
        vol_mark = vol_mark_mat(i);
        if  downside_std>=vol_mark 
            buy_sell_test_robot=-1;
            quantity_test_robot=randi(20);
            test_robot_sell_order_reserve{i}(test_robot_sell_order_reserve{i}(:,2)<best_bid,:)=1000000;
            test_robot_buy_order_reserve{i}(:,:)=0;
            price_test_robot=best_bid;
        elseif upside_std>=vol_mark
            buy_sell_test_robot=1;
            quantity_test_robot=randi(20);
            test_robot_buy_order_reserve{i}(test_robot_buy_order_reserve{i}(:,2)>best_ask,:)=0;
            test_robot_sell_order_reserve{i}(:,:)=1000000;            
            price_test_robot=best_ask;
%         if  downside_std>=vol_mark && test_robot_cum_inventory(i)>0
%             buy_sell_test_robot=-1;
%             quantity_test_robot=randi(20);
%             test_robot_sell_order_reserve{i}(test_robot_sell_order_reserve{i}(:,2)<best_bid,:)=1000000;
%             test_robot_buy_order_reserve{i}(:,:)=0;
%             price_test_robot=best_bid;
%         elseif downside_std>=vol_mark && test_robot_cum_inventory(i)<0
%             buy_sell_test_robot=0;
%             price_test_robot=0;
%             quantity_test_robot=0;           
%         elseif upside_std>=vol_mark && test_robot_cum_inventory(i)<0
%             buy_sell_test_robot=1;
%             quantity_test_robot=randi(20);
%             test_robot_buy_order_reserve{i}(test_robot_buy_order_reserve{i}(:,2)>best_ask,:)=0;
%             test_robot_sell_order_reserve{i}(:,:)=1000000;            
%             price_test_robot=best_ask;
%         elseif downside_std>=vol_mark && test_robot_cum_inventory(i)>0
%             buy_sell_test_robot=0;
%             price_test_robot=0;
%             quantity_test_robot=0;
        elseif test_robot_cum_inventory(i)>0
            buy_sell_test_robot = -1;
            price_test_robot = best_bid;
            quantity_test_robot = randi(20);
        elseif test_robot_cum_inventory(i)<0
            buy_sell_test_robot = 1;
            price_test_robot = best_ask;
            quantity_test_robot = randi(20);
        else
            buy_sell_test_robot = 2*(randi(2)-1.5);
            if buy_sell_test_robot == 1
                price_test_robot = best_bid;
                quantity_test_robot = randi(20);
            elseif buy_sell_test_robot ==-1
                price_test_robot = best_ask;
                quantity_test_robot = randi(20);
            end
        end
        test_robot_order = [buy_sell_test_robot,price_test_robot,quantity_test_robot,t];
        test_robot_order_reserve{i}(t,:) = test_robot_order;
        if buy_sell_test_robot==1
            test_robot_buy_order_reserve{i}(end,:)=test_robot_order;
            test_robot_buy_order_reserve{i}=sortrows(test_robot_buy_order_reserve{i},[-2,4]);
        elseif buy_sell_test_robot == -1
            test_robot_sell_order_reserve{i}(end,:)=test_robot_order;
            test_robot_sell_order_reserve{i}=sortrows(test_robot_sell_order_reserve{i},[2,4]);
        end
        godview_transac_mat = zeros(100,4);
        god_view_indic = 1;
        live_sell_orders_list_temp=live_sell_orders_list;
        live_buy_orders_list_temp=live_buy_orders_list;
        
        % test robot matching engine
        buy_sell_test_robot=1;
        while test_robot_buy_order_reserve{i}(1,2)>=live_sell_orders_list_temp(1,3) && test_robot_buy_order_reserve{i}(1,2)~=0

            while test_robot_buy_order_reserve{i}(1,2)>=live_sell_orders_list_temp(1,3) && test_robot_buy_order_reserve{i}(1,3)>live_sell_orders_list_temp(1,4)&& test_robot_buy_order_reserve{i}(1,2)~=0
                godview_transac_mat(god_view_indic,:)=[buy_sell_test_robot,live_sell_orders_list_temp(1,3),live_sell_orders_list_temp(1,4),t];
                test_robot_buy_order_reserve{i}(1,3) = test_robot_buy_order_reserve{i}(1,3)-live_sell_orders_list_temp(1,4);
                live_sell_orders_list_temp(1,:)=[];
                god_view_indic = god_view_indic + 1;
            end
            if test_robot_buy_order_reserve{i}(1,2)>=live_sell_orders_list_temp(1,3) && test_robot_buy_order_reserve{i}(1,3)<=live_sell_orders_list_temp(1,4) && test_robot_buy_order_reserve{i}(1,3)>0&& test_robot_buy_order_reserve{i}(1,2)~=0
                godview_transac_mat(god_view_indic,:)=[buy_sell_test_robot,live_sell_orders_list_temp(1,3),test_robot_buy_order_reserve{i}(1,3),t];
                god_view_indic = god_view_indic+1;
                live_sell_orders_list_temp(1,4)=live_sell_orders_list_temp(1,4)-test_robot_buy_order_reserve{i}(1,3);
                test_robot_buy_order_reserve{i}(1,:)=[ ];
                god_view_indic = god_view_indic + 1;
            end

        end
            
        buy_sell_test_robot = -1;
        while test_robot_sell_order_reserve{i}(1,2)<=live_buy_orders_list_temp(1,3) && test_robot_sell_order_reserve{i}(1,2)~=1000000

            while test_robot_sell_order_reserve{i}(1,2)<=live_buy_orders_list_temp(1,3) && test_robot_sell_order_reserve{i}(1,3)>live_buy_orders_list_temp(1,4)&& test_robot_sell_order_reserve{i}(1,2)~=1000000
                godview_transac_mat(god_view_indic,:)=[buy_sell_test_robot,live_buy_orders_list_temp(1,3),live_buy_orders_list_temp(1,4),t];
                test_robot_sell_order_reserve{i}(1,3) = test_robot_sell_order_reserve{i}(1,3)-live_buy_orders_list_temp(1,4);
                live_buy_orders_list_temp(1,:)=[];
                god_view_indic = god_view_indic + 1;
            end
            if test_robot_sell_order_reserve{i}(1,2)<=live_buy_orders_list_temp(1,3) && test_robot_sell_order_reserve{i}(1,3)<=live_buy_orders_list_temp(1,4) && test_robot_sell_order_reserve{i}(1,3)~=1000000 && test_robot_sell_order_reserve{i}(1,3)~=1000000
                godview_transac_mat(god_view_indic,:)=[buy_sell_test_robot,live_buy_orders_list_temp(1,3), test_robot_sell_order_reserve{i}(1,3),t];
                god_view_indic = god_view_indic+1;
                live_buy_orders_list_temp(1,4)=live_buy_orders_list_temp(1,4)-test_robot_sell_order_reserve{i}(1,3);
                test_robot_sell_order_reserve{i}(1,:)=[ ];
                god_view_indic = god_view_indic + 1;
            end

        end
        test_robot_trading_volume(i) = test_robot_trading_volume(i)+sum(godview_transac_mat(:,3));
        test_robot_cum_inventory(i) = test_robot_cum_inventory(i)+sum(godview_transac_mat(:,1).*godview_transac_mat(:,3));
        test_robot_cum_inventory_position = test_robot_cum_inventory(i)*transaction_price_volume_stor_mat(find(transaction_price_volume_stor_mat(:,3),1,'last'),3);
        test_robot_cash_position(i) = test_robot_cash_position(i)-sum(godview_transac_mat(:,1).*godview_transac_mat(:,2).*godview_transac_mat(:,3));
        test_robot_trading_profit = test_robot_cum_inventory_position+test_robot_cash_position(i);
        test_robot_trading_profit_plot(t,i)= test_robot_trading_profit;
        test_robot_inventory_position_plot(t,i) = test_robot_cum_inventory_position;
        test_robot_cash_position_plot(t,i) = test_robot_cash_position(i);
        test_robot_compare_mat(:,i)=[vol_mark;test_robot_trading_volume(i);test_robot_cum_inventory(i);test_robot_cum_inventory_position;test_robot_cash_position(i); test_robot_trading_profit];
    end
    
    
end

%TOTAL VOL

% if t>burn_in_period+observe_period && partic_test<=test_robot_activity_fraction
%     
%     total_vol = std(return_vec);
%     vol_mark_mat = linspace(0,0.02,vol_cnt);
%     
%     for i=1:vol_cnt
%         % test robot command
%         vol_mark = vol_mark_mat(i);
%         if test_robot_cum_inventory_total(i)>0 && total_vol>=vol_mark
%             buy_sell_test_robot=-1;
%             quantity_test_robot=randi(20);
%             price_test_robot=best_bid;
%         elseif test_robot_cum_inventory_total(i)<0 && upside_std>=vol_mark
%             buy_sell_test_robot=1;
%             quantity_test_robot=randi(20);
%             price_test_robot=best_ask;
%         else
%             buy_sell_test_robot = 2*(randi(2)-1.5);
%             if buy_sell_test_robot == 1
%                 quantity_test_robot = randi(20);
%                 price_test_robot = best_bid;
%             elseif buy_sell_test_robot == -1
%                 quantity_test_robot = randi(20);
%                 price_test_robot = best_ask;
%             end          
%         end
%         test_robot_order = [buy_sell_test_robot,price_test_robot,quantity_test_robot,t];
%         test_robot_order_reserve_total{i}(t,:) = test_robot_order;
%         if buy_sell_test_robot==1
%             test_robot_buy_order_reserve_total{i}(end,:)=test_robot_order;
%             test_robot_buy_order_reserve_total{i}=sortrows(test_robot_buy_order_reserve_total{i},[-2,4]);
%         elseif buy_sell_test_robot == -1
%             test_robot_sell_order_reserve_total{i}(end,:)=test_robot_order;
%             test_robot_sell_order_reserve_total{i}=sortrows(test_robot_sell_order_reserve_total{i},[2,4]);
%         end
%         godview_transac_mat = zeros(100,4);
%         god_view_indic = 1;
%         live_sell_orders_list_temp=live_sell_orders_list;
%         live_buy_orders_list_temp=live_buy_orders_list;
%         
%         % test robot matching engine
%         if buy_sell_test_robot==1
%             while test_robot_buy_order_reserve_total{i}(1,2)>=live_sell_orders_list_temp(1,3) && test_robot_buy_order_reserve_total{i}(1,2)~=0
%             
%                 while test_robot_buy_order_reserve_total{i}(1,2)>=live_sell_orders_list_temp(1,3) && test_robot_buy_order_reserve_total{i}(1,3)>live_sell_orders_list_temp(1,4)&& test_robot_buy_order_reserve_total{i}(1,2)~=0
%                     godview_transac_mat(god_view_indic,:)=[buy_sell_test_robot,live_sell_orders_list_temp(1,3),live_sell_orders_list_temp(1,4),t];
%                     test_robot_buy_order_reserve_total{i}(1,3) = test_robot_buy_order_reserve_total{i}(1,3)-live_sell_orders_list_temp(1,4);
%                     live_sell_orders_list_temp(1,:)=[];
%                     god_view_indic = god_view_indic + 1;
%                 end
%                 if test_robot_buy_order_reserve_total{i}(1,2)>=live_sell_orders_list_temp(1,3) && test_robot_buy_order_reserve_total{i}(1,3)<=live_sell_orders_list_temp(1,4) && test_robot_buy_order_reserve_total{i}(1,3)>0&& test_robot_buy_order_reserve_total{i}(1,2)~=0
%                     godview_transac_mat(god_view_indic,:)=[buy_sell_test_robot,live_sell_orders_list_temp(1,3),test_robot_buy_order_reserve_total{i}(1,3),t];
%                     god_view_indic = god_view_indic+1;
%                     live_sell_orders_list_temp(1,4)=live_sell_orders_list_temp(1,4)-test_robot_buy_order_reserve_total{i}(1,3);
%                     test_robot_buy_order_reserve_total{i}(1,:)=[ ];
%                 end
%                 
%             end
%             
%         elseif buy_sell_test_robot == -1
%             while test_robot_sell_order_reserve_total{i}(1,2)<=live_buy_orders_list_temp(1,3) && test_robot_sell_order_reserve_total{i}(1,2)~=1000000
%             
%                 while test_robot_sell_order_reserve_total{i}(1,2)<=live_buy_orders_list_temp(1,3) && test_robot_sell_order_reserve_total{i}(1,3)>live_buy_orders_list_temp(1,4)&& test_robot_sell_order_reserve_total{i}(1,2)~=1000000
%                     godview_transac_mat(god_view_indic,:)=[buy_sell_test_robot,live_buy_orders_list_temp(1,3),live_buy_orders_list_temp(1,4),t];
%                     test_robot_sell_order_reserve_total{i}(1,3) = test_robot_sell_order_reserve_total{i}(1,3)-live_buy_orders_list_temp(1,4);
%                     live_buy_orders_list_temp(1,:)=[];
%                     god_view_indic = god_view_indic + 1;
%                 end
%                 if test_robot_sell_order_reserve_total{i}(1,2)<=live_buy_orders_list_temp(1,3) && test_robot_sell_order_reserve_total{i}(1,3)<=live_buy_orders_list_temp(1,4) && test_robot_sell_order_reserve_total{i}(1,3)~=1000000 && test_robot_sell_order_reserve_total{i}(1,3)>0
%                     godview_transac_mat(god_view_indic,:)=[buy_sell_test_robot,live_buy_orders_list_temp(1,3), test_robot_sell_order_reserve_total{i}(1,3),t];
%                     god_view_indic = god_view_indic+1;
%                     live_buy_orders_list_temp(1,4)=live_buy_orders_list_temp(1,4)-test_robot_sell_order_reserve_total{i}(1,3);
%                     test_robot_sell_order_reserve_total{i}(1,:)=[ ];
%                 end
%                 
%             end
%         end
%         test_robot_trading_volume_total(i) = test_robot_trading_volume_total(i)+sum(godview_transac_mat(:,3));
%         test_robot_cum_inventory_total(i) = test_robot_cum_inventory_total(i)+sum(godview_transac_mat(:,1).*godview_transac_mat(:,3));
%         test_robot_cum_inventory_position = test_robot_cum_inventory_total(i)*transaction_price_volume_stor_mat(find(transaction_price_volume_stor_mat(:,3),1,'last'),3);
%         test_robot_cash_position_total(i) = test_robot_cash_position_total(i)-sum(godview_transac_mat(:,1).*godview_transac_mat(:,2).*godview_transac_mat(:,3));
%         test_robot_trading_profit = test_robot_cum_inventory_position+test_robot_cash_position_total(i);
%         test_robot_trading_profit_plot_total(t,i)= test_robot_trading_profit;
%         test_robot_inventory_position_plot_total(t,i) = test_robot_cum_inventory_position;
%         test_robot_cash_position_plot_total(t,i) = test_robot_cash_position_total(i);
%         test_robot_compare_mat_total(:,i)=[vol_mark;test_robot_trading_volume_total(i);test_robot_cum_inventory_total(i);test_robot_cum_inventory_position;test_robot_cash_position_total(i); test_robot_trading_profit];
%     end
% end
% 
% % NAIVE IC%
% if t>burn_in_period+observe_period && partic_test<=test_robot_activity_fraction
%     if test_robot_cum_inventory_naive>0
%         buy_sell_test_robot=-1;
%         quantity_test_robot=randi(20);
%         price_test_robot=best_bid;
%         
%     elseif test_robot_cum_inventory_naive<0
%         buy_sell_test_robot=1;
%         quantity_test_robot=randi(20);
%         price_test_robot=best_ask;
%     else
%         buy_sell_test_robot = 2*(randi(2)-1.5);
%         if buy_sell_test_robot == 1
%             quantity_test_robot = randi(20);
%             price_test_robot = best_bid;
%         elseif buy_sell_test_robot == -1
%             quantity_test_robot = randi(20);
%             price_test_robot = best_ask;
%         end          
%     end
%     test_robot_order_naive = [buy_sell_test_robot,price_test_robot,quantity_test_robot,t];
%     test_robot_order_reserve_naive(t,:) = test_robot_order_naive;
%     if buy_sell_test_robot==1
%         test_robot_buy_order_reserve_naive(end,:)=test_robot_order_naive;
%         test_robot_buy_order_reserve_naive=sortrows(test_robot_buy_order_reserve_naive,[-2,4]);
%     elseif buy_sell_test_robot == -1
%         test_robot_sell_order_reserve_naive(end,:)=test_robot_order_naive;
%         test_robot_sell_order_reserve_naive=sortrows(test_robot_sell_order_reserve_naive,[2,4]);
%     end
%     godview_transac_mat = zeros(100,4);
%     god_view_indic = 1;
%     live_sell_orders_list_temp=live_sell_orders_list;
%     live_buy_orders_list_temp=live_buy_orders_list;
% 
%     % test robot matching engine
%     if buy_sell_test_robot==1
%         while test_robot_buy_order_reserve_naive(1,2)>=live_sell_orders_list_temp(1,3) && test_robot_buy_order_reserve_naive(1,2)~=0
% 
%             while test_robot_buy_order_reserve_naive(1,2)>=live_sell_orders_list_temp(1,3) && test_robot_buy_order_reserve_naive(1,3)>live_sell_orders_list_temp(1,4)
%                 godview_transac_mat(god_view_indic,:)=[buy_sell_test_robot,live_sell_orders_list_temp(1,3),live_sell_orders_list_temp(1,4),t];
%                 test_robot_buy_order_reserve_naive(1,3) = test_robot_buy_order_reserve_naive(1,3)-live_sell_orders_list_temp(1,4);
%                 live_sell_orders_list_temp(1,:)=[];
%                 god_view_indic = god_view_indic + 1;
%             end
%             if test_robot_buy_order_reserve_naive(1,2)>=live_sell_orders_list_temp(1,3) && test_robot_buy_order_reserve_naive(1,3)<=live_sell_orders_list_temp(1,4) && test_robot_buy_order_reserve_naive(1,3)>0
%                 godview_transac_mat(god_view_indic,:)=[buy_sell_test_robot,live_sell_orders_list_temp(1,3),test_robot_buy_order_reserve_naive(1,3),t];
%                 god_view_indic = god_view_indic+1;
%                 live_sell_orders_list_temp(1,4)=live_sell_orders_list_temp(1,4)-test_robot_buy_order_reserve_naive(1,3);
%                 test_robot_buy_order_reserve_naive(1,:)=[ ];
%             end
% 
%         end
% 
%     elseif buy_sell_test_robot == -1
%         while test_robot_sell_order_reserve_naive(1,2)<=live_buy_orders_list_temp(1,3) && test_robot_sell_order_reserve_naive(1,2)~=1000000
% 
%             while test_robot_sell_order_reserve_naive(1,2)<=live_buy_orders_list_temp(1,3) && test_robot_sell_order_reserve_naive(1,3)>live_buy_orders_list_temp(1,4)
%                 godview_transac_mat(god_view_indic,:)=[buy_sell_test_robot,live_buy_orders_list_temp(1,3),live_buy_orders_list_temp(1,4),t];
%                 test_robot_sell_order_reserve_naive(1,3) = test_robot_sell_order_reserve_naive(1,3)-live_buy_orders_list_temp(1,4);
%                 live_buy_orders_list_temp(1,:)=[];
%                 god_view_indic = god_view_indic + 1;
%             end
%             if test_robot_sell_order_reserve_naive(1,2)<=live_buy_orders_list_temp(1,3) && test_robot_sell_order_reserve_naive(1,3)<=live_buy_orders_list_temp(1,4) && test_robot_sell_order_reserve_naive(1,3)~=1000000 && test_robot_sell_order_reserve_naive(1,3)>0
%                 godview_transac_mat(god_view_indic,:)=[buy_sell_test_robot,live_buy_orders_list_temp(1,3), test_robot_sell_order_reserve_naive(1,3),t];
%                 god_view_indic = god_view_indic+1;
%                 live_buy_orders_list_temp(1,4)=live_buy_orders_list_temp(1,4)-test_robot_sell_order_reserve_naive(1,3);
%                 test_robot_sell_order_reserve_naive(1,:)=[ ];
%             end
% 
%         end
%     end
%     test_robot_trading_volume_naive = test_robot_trading_volume_naive+sum(godview_transac_mat(:,3));
%     test_robot_cum_inventory_naive = test_robot_cum_inventory_naive+sum(godview_transac_mat(:,1).*godview_transac_mat(:,3));
%     test_robot_cum_inventory_position_naive = test_robot_cum_inventory_naive*transaction_price_volume_stor_mat(find(transaction_price_volume_stor_mat(:,3),1,'last'),3);
%     test_robot_cash_position_naive = test_robot_cash_position_naive-sum(godview_transac_mat(:,1).*godview_transac_mat(:,2).*godview_transac_mat(:,3));
%     test_robot_trading_profit_naive = test_robot_cum_inventory_position_naive+test_robot_cash_position_naive;
%     test_robot_trading_profit_plot_naive(t)= test_robot_trading_profit_naive;
%     test_robot_inventory_position_plot_naive(t) = test_robot_cum_inventory_position_naive;
%     test_robot_cash_position_plot_naive(t) = test_robot_cash_position_naive;
%     test_robot_compare_mat_naive=[test_robot_trading_volume_naive;test_robot_cum_inventory_naive;test_robot_cum_inventory_position_naive;test_robot_cash_position_naive; test_robot_trading_profit_naive];
% end
end

test_robot_trading_profit_plot(~any(test_robot_trading_profit_plot, 2), : ) = [ ];
test_robot_inventory_position_plot(~any(test_robot_inventory_position_plot,2),:)=[ ];
test_robot_cash_position_plot(~any(test_robot_cash_position_plot,2),:)=[ ];

test_robot_trading_profit_plot_total(~any(test_robot_trading_profit_plot_total, 2), : ) = [ ];
test_robot_inventory_position_plot_total(~any(test_robot_inventory_position_plot_total,2),:)=[ ];
test_robot_cash_position_plot_total(~any(test_robot_cash_position_plot_total,2),:)=[ ];

test_robot_inventory_position_plot_naive(~any(test_robot_inventory_position_plot_naive,2),:)=[];
test_robot_cash_position_plot_naive(~any(test_robot_cash_position_plot_naive,2),:)=[];
test_robot_trading_profit_plot_naive(~any(test_robot_trading_profit_plot_naive,2),:)=[];

% for p=1:vol_cnt-1
%     
%     subplot(8,5,p);
%     plot(test_robot_trading_profit_plot(:,p+1));
%     hold on;
%     plot(test_robot_inventory_position_plot(:,p+1),'r');
%     hold on;
%     plot(test_robot_cash_position_plot(:,p+1),'y');
%     
% end

% %% Back Test Part %%
% if run_main_script_independently_indic==1
% 
%     t_max=16322;
%     burn_in_period=1322;
%     num_bgt=20;
%     smart_robot_activity_fraction=.2;
%     max_quantity=19;
%     max_price=1000;
%     min_price=1;
%     price_flex=2;
%     prob_last_order_price_resets=0.03;
%     plopr_intercept=0.025;
%     plopr_ordersize_param=0.05;
%     perm_price_impact_slope_coeff=plopr_ordersize_param*((1-plopr_intercept)/max_quantity);
% 
% end
% 
% 
% live_buy_orders_list=zeros(t_max*2,7);
% live_sell_orders_list=zeros(t_max*2,7);
% 
% bid_ask_stor_mat=zeros(t_max*2,2);
% bid_ask_depth_stor_mat=zeros(t_max*2,2);
% 
% transaction_price_volume_stor_mat=zeros(t_max*2,7);
% transaction_price_volume_stor_mat=[ones(1,7);transaction_price_volume_stor_mat];
% 
% ao_sign_stor_vec=zeros(t_max*2,1);
% 
% smart_robot_cum_net_inventory=zeros(1,number_of_smart_robots);
% 
% smart_robot_order_entry_times=zeros(t_max*2,1);
% 
% last_order_price_stor_vec=zeros(t_max*2,1);
% entered_order_price_stor_vec=zeros(t_max*2,1);
% entered_order_quantity_stor_vec=zeros(t_max*2,1);
% 
% back_test_time=t_max;
% t=1;
% i=1;
% g=0;
% while i<=t_max
%     
%     robot_j_acct_id = back_test_data(i,1);
%     price_robot_j = back_test_data(i,3);
%     buy_sell_robot_j = back_test_data(i,2);
%     quantity_robot_j = back_test_data(i,4);
%     FAK_indic = back_test_data(i,5);
%     message_type=1;
%     order_id=t;
%     
%     entered_order_price_stor_vec(t)=price_robot_j;
%     entered_order_quantity_stor_vec(t)=quantity_robot_j;
%     
%     eval(matching_engine_algo)
%     
%     if (number_of_execution_records>start_of_time_t_num_execu_recs)
%     
%         prob_last_order_price_resets=plopr_intercept+perm_price_impact_slope_coeff*entered_order_quantity_stor_vec(t);
%     
%         test_for_last_order_price_choice_j=rand(1);
%  
%         if test_for_last_order_price_choice_j<prob_last_order_price_resets
%             last_order_price=price_robot_j; 
%         end
%     end
%     ao_sign_stor_vec(t)=AO_indic_with_sign;
% 
%     eval(orderbook_construction_code);
%     
%     last_order_price_stor_vec(t)=last_order_price;
%     
%     t=t+1;
%     i=i+1;
%     
%     if t>=burn_in_period
%         g=g+1;
%         test_robot_partic=rand(1);
%         if test_robot_partic<1 && rem(g,10)==0
%             
%             robot_j_acct_id=8;
%             
%             eval(test_robot_commands);
%             
%             entered_order_price_stor_vec(t)=price_robot_j;
%             
%             entered_order_quantity_stor_vec(t)=quantity_robot_j;
%         
%             smart_robot_order_entry_times(t)=robot_j_acct_id;
%    
%             eval(matching_engine_algo);
%         
%             ao_sign_stor_vec(t)=AO_indic_with_sign;
% 
%             eval(orderbook_construction_code);
%         
%             last_order_price_stor_vec(t)=last_order_price;
%         
%             t=t+1;
%         end
%         
%     end
%     
% end


%% Summarise The Statistics %%

transaction_price_volume_stor_mat(1,:)=[];
meach_sim_transac_price(:,l)=transaction_price_volume_stor_mat(:,3);

% %% ----------------
% Number of Transactions
number_of_trades=nnz(transaction_price_volume_stor_mat(:,1));

transaction_price_volume_stor_mat((number_of_trades+1):end,:)=[];


post_burn_in_transactions_start=find((transaction_price_volume_stor_mat(:,1)>burn_in_period),1,'first');
number_of_post_burn_in_transactions=number_of_trades-post_burn_in_transactions_start;

% %%---------------
% Bid-Ask Spread
bid_ask_spread_stor_vec=bid_ask_stor_mat(:,2)-bid_ask_stor_mat(:,1);
mean_bid_ask_spread=mean(bid_ask_spread_stor_vec((burn_in_period+1):end));
bid_ask_midpoint_stor_vec=mean(bid_ask_stor_mat,2);



% %%---------------
% Tracking P&L, Cash, and Inventory
aggressor_changes_in_net_cash=(-1)*transaction_price_volume_stor_mat(:,2).*transaction_price_volume_stor_mat(:,4).*transaction_price_volume_stor_mat(:,3);
aggressor_changes_in_net_inventory=transaction_price_volume_stor_mat(:,2).*transaction_price_volume_stor_mat(:,4);

passor_changes_in_net_cash=(-1)*aggressor_changes_in_net_cash;
passor_changes_in_net_inventory=(-1)*aggressor_changes_in_net_inventory;

positions_changes_mat=[transaction_price_volume_stor_mat(:,1),aggressor_changes_in_net_cash,aggressor_changes_in_net_inventory,transaction_price_volume_stor_mat(:,7),passor_changes_in_net_cash,passor_changes_in_net_inventory,transaction_price_volume_stor_mat(:,6),transaction_price_volume_stor_mat(:,3)];

% %%

for z=1:number_of_smart_robots
    
robot_account_id=z;

robot_z_aggressor_indic=(transaction_price_volume_stor_mat(:,7)==z);
robot_z_passor_indic=(transaction_price_volume_stor_mat(:,6)==z);
robot_z_indic=(robot_z_aggressor_indic|robot_z_passor_indic);

robot_z_aggressive_trades=positions_changes_mat(robot_z_aggressor_indic,[1:3,7]);
robot_z_passive_trades=positions_changes_mat(robot_z_passor_indic,[1,5,6,7]);

robot_z_positions_change_history=[robot_z_aggressive_trades;robot_z_passive_trades];
robot_z_positions_change_history=sortrows(robot_z_positions_change_history,1);
robot_z_mark_to_market_prices=positions_changes_mat(robot_z_indic,8);

cum_robot_z_positions=cumsum(robot_z_positions_change_history(:,2:3),1);
[b,m,n]=unique(robot_z_positions_change_history(:,1),'last');

cum_robot_z_positions_history=[robot_z_positions_change_history(m,1),cum_robot_z_positions(m,:),robot_z_mark_to_market_prices(m)];
mark_to_market_inventory_value_robot_z=cum_robot_z_positions_history(:,3).*cum_robot_z_positions_history(:,4);
robot_z_mark_to_market_P_and_L=mark_to_market_inventory_value_robot_z+cum_robot_z_positions_history(:,2);


robot_z_total_trading_profit=robot_z_mark_to_market_P_and_L(end);
robot_z_total_trading_volume=sum(abs(robot_z_positions_change_history(:,3)));

robot_z_final_inventory_position=mark_to_market_inventory_value_robot_z(end);
robot_z_final_cash_position=cum_robot_z_positions_history(end,2);

robot_z_max_inventory_position_dollars=max(abs(mark_to_market_inventory_value_robot_z));
robot_z_max_inventory_position_shares=max(abs(cum_robot_z_positions_history(:,3)));

%


% %%-----------------------------------
% % Collecting all of the key results
meta_profits_comparison_matrix(l,z)=robot_z_total_trading_profit;
meta_volume_comparison_matrix(l,z)=robot_z_total_trading_volume;

end
    
for w=1:vol_cnt
    meta_test_robot_profits_comparison_matrix(l,w)= test_robot_compare_mat(6,w);
    meta_test_robot_trading_volume(l,w) = test_robot_compare_mat(2,w);
    meta_test_robot_final_inventory_inshare(l,w)=test_robot_compare_mat(3,w);
    meta_test_robot_final_inventory_position(l,w)=test_robot_compare_mat(4,w);
    meta_test_robot_final_cash_position(l,w)=test_robot_compare_mat(5,w);
end

toc
end


%% Meta Statistics %%
