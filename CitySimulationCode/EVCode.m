function evcharge_t = EVCode(appsched,appwatt,peak,ev_int_ch) % outputs the final EV energy charging operation using the appliance energy demand, the limits and the ev initial ccharge

tempvar = appsched.*appwatt; %appliance schedule and power rating
appenergy = sum(tempvar,1); %appliance energy demand
imbalance = peak-appenergy; %peak and energy demand differences

%% E-Trike Model: Mandaluyong Unit Model
ev_rating = 3300; % EV battery Capacity
limit=1200; % 25A*48V=1200W EV charge limit at high output voltage from BMS
% at DOD 80%, 20% Limit
% with 48V 70 AH 2000 cycles at 80%


%% Variable  and "Layers" Initialization
evcharge_t = zeros(1,12); % 6pm to 6am hour-time slots
HighThresh = 0.8*ev_rating-(ev_int_ch/100)*ev_rating; % Total EV Energy Demand
[sorted,sorted_index]=sort([imbalance(1,1:2) imbalance(1,15:24)],'descend'); % sort hourly (6pm to 6am) energy demand
layer = abs(diff([sorted 0])); % differences of each sorted hourly energy demand
ctr=12; % counter from 12 time-slot
excess=0; % initialization of excess energy demand


%% Default Working Code for Addding "Layer". EV Charging Code Block
%does not consider peak demand threshold and ev charge limit because the
%BPSO main code converges such that the EV energy demand per hour does not
%reach these limits. It is already optimized.
for a=1:12 % 
    if layer(1,a)>0 && (layer(1,a)*a)+sum(evcharge_t,2)<HighThresh % adds the layers, with visualization in the manuscript
        for k=1:a % from 1 to current stair
            evcharge_t(1,sorted_index(1,k))= evcharge_t(1,sorted_index(1,k))+layer(1,a);
        end
    elseif layer(1,a)>0 && (layer(1,a)*a)+sum(evcharge_t,2)>HighThresh % adds the final layer
        excess=HighThresh-sum(evcharge_t,2); 
        ctr=a;
        break
    end
end 

for a=1:ctr
    evcharge_t(1,sorted_index(1,a))= evcharge_t(1,sorted_index(1,a))+excess/ctr;
end


%% Peak Demand Threshold and Charge Limit Processing. Excess EV Energy Demand Check Block.

% proceses again if there is an excess from the EV Energy Demand
removed=0; 
lim = zeros(1,12);

for a=1:12 %Removed the excess from the limits
    if evcharge_t(1,a)>=limit
        removed = removed + (evcharge_t(1,a)-limit);
        evcharge_t(1,a)=limit;
        lim(1,a)=1;
    end
end

%% Excess EV Energy Demand Processing 
    % (Not Yet Optimized) because the operation has low probability on
    % having an excess due to the flattening of the charging time and BPSO 
    % optimization. It only occurs during the first generated particles
    % using a randomizer at the BPSO.
if removed>0
    app_and_ev = [appenergy(1,1:2) appenergy(1,15:24)]+evcharge_t; %ev charge + app energy, para macheck pa rin yung peak ng usage
    [x_s,x_s_i]=sort(app_and_ev,'ascend'); %ascending order 6pm to 6am, sort from lowest to peak pero 6pm to 6am lang
    x_lay = diff([x_s x_s(1,12)]); %rate of stairs, difference nung sortation
    
    ex_lim = zeros(1,12);
    for a=1:12
        ex_lim(a)=lim(x_s_i(a));
    end
    sum(ex_lim(1,1:a),2);
    for a=1:12 % for every x_layer
        
        % If may ascending stair, and yung idadagdag is mas mababa sa removed (yung binawas)
        if (x_lay(1,a)>0) && (x_lay(1,a)*(a-(sum(ex_lim(1,1:a),2)))<removed && a>(sum(ex_lim(1,1:a),2))) 
            for k=1:a %for every element at that level (stair)
                %If di malilimit, at di limited: add yung layer, bawas sa
                %removed
                if x_lay(1,a)+evcharge_t(1,x_s_i(1,k))<limit && not(ex_lim(1,k)) 
                    evcharge_t(1,x_s_i(1,k))=evcharge_t(1,x_s_i(1,k))+x_lay(1,a); %add yung x_layer(1,a)
                    removed=removed-x_lay(1,a);
                    
                %If malilimit, at di limited: gawing limit, bawas sa removed, 
                elseif x_lay(1,a)+evcharge_t(1,x_s_i(1,k))>limit && not(ex_lim(1,k))
                    removed=removed-(limit-evcharge_t(1,x_s_i(1,k)));
                    evcharge_t(1,x_s_i(1,k))=limit; %gawing limited yung ev charge na yon
                    ex_lim(1,k)=1; %gawing limited yung ev charge na yon
                    
                end
            end
    
         %if may ascending value, and yung idadagdag is mas mataas sa removed,
         %yung removed value ang gagamitin pang add
        elseif x_lay(1,a)>0 && (x_lay(1,a)*(a-sum(ex_lim(1,k),2))) > removed
            poss = a-sum(ex_lim(1,1:a),2); %yung value distribution ng removed, sa hindi pa limited na items
            
            for k=1:a %for every element sa level na yon
              
                if removed <=0 
                    %SHOULD NOT HAPPEN <0, only =0
                    break
                %if removed is 0 pa rin, and yung idagdag ay hindi maglimit,
                %add yung value distributed removed/poss
                elseif removed/poss + evcharge_t(1,x_s_i(1,k)) < limit && not(ex_lim(1,k)) 
                    evcharge_t(1,x_s_i(1,k))=evcharge_t(1,x_s_i(1,k))+removed/poss;
                    removed=removed-removed/poss;
                    
                %if malilimit: maging limit at ibawas
                elseif removed/poss + evcharge_t(1,x_s_i(1,k)) > limit && not(ex_lim(1,k)) %if sya malilimit, or di malilimit
                    removed=removed-(limit-evcharge_t(1,x_s_i(1,k)));
                    evcharge_t(1,x_s_i(1,k))=limit;
                    
                end
            end
        end
    end
end

evcharge_t=[evcharge_t(1,1:2) zeros(1,12) evcharge_t(1,3:12)]; % outputs the final EV energy charging operation
