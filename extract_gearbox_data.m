close all; clear all; clc;


% get the list of pages 
gears = dir('./gears/*.html'); 

num_gears = numel(gears);
%num_motors = 2; 

% loop through the pages 
num_unknown = 1;     % just check these after other code finishes running 


%T = table(Product_Number, Description, Voltage, Stall_torque, Resistance, Inductance, Shaft_size, Torque_Constant, Price); 
 

% Things we want 
Product_Number = strings(num_gears, 1);
Description = strings(num_gears, 1);
Gearhead_type = strings(num_gears, 1); 
alpha = nan(num_gears, 1);     % Gear Ratio
eta = nan(num_gears, 1); 
mass = nan(num_gears, 1); 
inertia = nan(num_gears, 1); 

Stages = nan(num_gears, 1); 
Max_cont_torque = nan(num_gears, 1); 
Max_int_torque = nan(num_gears, 1); 
Direction = strings(num_gears, 1);
Price = nan(num_gears, 1);
Recommended = zeros(num_gears, 1);  % 1 = rec, 0 = no rec 

skip_idxs = {}; % pages where the html give no info 

fprintf('Gearbox: '); 
disp_txt = [];
for i = 1:num_gears
    fprintf(repmat('\b', 1, length(disp_txt))); 
    disp_txt = sprintf('%d of %d', i, num_gears);
    fprintf(disp_txt); 

    gear_text = fileread(fullfile(gears(i).folder, gears(i).name)); 

    if isempty(strfind(gear_text, 'recommended'))  % lower case because sometimes Recommended temperature
        Recommended(i) = 1;
    else 
        Recommended(i) = 0; 
    end 

    % OLD HTML 
    header_start = strfind(gear_text, '<h1><strong>') + 12;
    header_end = strfind(gear_text, '</strong> </h1>') - 1;


    if isempty(header_start)
        header_start = strfind(gear_text, '<h1 class=') + 17;
        header_end = strfind(gear_text, '|') - 1; 
        if isempty(header_end)
            header_end = strfind(gear_text, '</h1>') - 1; 
        end 
    end 

    description = gear_text(header_start:header_end);

    if isempty(description)
        keyboard
    end 

    part_number_idx = strfind(gear_text, 'Part number'); 


    % get description too 
    if isempty(part_number_idx)
        part_number = sprintf('unknown_%d', num_unknown);
        num_unknown = num_unknown + 1;
    else 
        part_number = gear_text(part_number_idx + 12: part_number_idx + 17) ;
    end 

    table_starts = strfind(gear_text, '<table'); % removed '> '
    table_ends = strfind(gear_text, '</table>');

    %table_ends = min(table_starts - 1 + strfind(gear_text(table_starts:end), '</table>'));

    % First table gets pricing
    if length(table_starts) > 1     % sometimes there is no pricing talbe 
        price_table = gear_text(table_starts(1):table_ends(1));
        spec_table = gear_text(table_starts(2):table_ends(2));

        % get price 
        price_tree = htmlTree(price_table); 
        price_body = findElement(price_tree, 'tbody');
        price_rows = findElement(price_body, 'tr');
        price_row = findElement(price_rows(1), 'td'); 

        %{
        for kk = 1:numel(price_row)
            txt = price_row(kk).extractHTMLText;
            keyboard
            if contains(txt, 'unitPrice')
                price = price_row(kk).extractHTMLText;
                price_num = get_num(price);
                keyboard
                break; 
            end 
        end
        %}
        price_num =  get_num(price_row(end).extractHTMLText);    
    else 
        spec_table = gear_text(table_starts:table_ends);
        price_num = inf;
    end 


    % convert to html to extract
    spec_tree = htmlTree(spec_table); 
    spec_rows = findElement(spec_tree, 'tr');

    % get all the data elements we want 
    num_rows = numel(spec_rows);
    for k = 1:num_rows
        gg = findElement(spec_rows(k), 'td');
        if (numel(gg) >= 2)
            txt = gg(1).extractHTMLText; 
            val = gg(2).extractHTMLText; 

            switch txt
                case 'Gearhead type'
                    Gearhead_type(i) = val; 
                case 'Absolute reduction'
                     tmp = get_num(val); % 2x1 - [numerator, denominator]
                     alpha(i) = tmp(1)/tmp(2);
                case 'Number of stages'
                    Stages(i) = get_num(val); 
                case 'Max. continuous torque'
                    Max_cont_torque(i) = get_num(val); 
                case 'Max. intermittent torque'
                    Max_int_torque(i) = get_num(val); 
                case 'Max. efficiency'
                    eta(i) = get_num(val)/100; 
                case 'Mass inertia'
                    inertia(i) = get_num(val) * 1e-7;  % kg m^2 
                case 'Direction of rotation, drive to output'
                    Direction(i) = val; 
                case 'Weight'
                    mass(i) = get_num(val) * 1e-3;  % convert to kg  
            end 

        end 
    end 
    Product_Number(i) = part_number; 
    Description(i) = description;
    Price(i) = price_num; 



    % dead links with no info 
    if contains(part_number, '416711') || contains(part_number, '144049') || ...    
            contains(part_number, '144052') || contains(part_number, '144054') || ...
            contains(part_number, '144072') ||  contains(part_number, '144078') || ...
            contains(part_number, '305148')  || contains(part_number, '312908') || ...
            contains(part_number, '312909')  || contains(part_number, '312911') 
        skip_idxs{end + 1} = i;  
    else 


        if isnan(alpha(i))
            skip_idxs{end + 1} = i; 
            %error('Bad HTML. No gear ratio')
        end 
    end 
end 

skip_idxs = cell2mat(skip_idxs); 



T_all = table(Product_Number, Description, Gearhead_type, alpha, eta,...
                     inertia, Stages, Max_cont_torque, Max_int_torque,...
                     Direction, mass, Recommended, Price); 


T_all(skip_idxs, :) = []; 

% Split into screw drive and regular 

screw_idxs = contains(T_all.Description, "Screw"); 
other_idxs = not(screw_idxs); 

T_screw = T_all(screw_idxs, :); 
T_other = T_all(other_idxs, :); 


%% There are some repetitions for example with GPX models where there 
% sterilizable, sterilizable with seals, etc., only difference is price 

% writing out smaller version that removes rows that have same data 

% numeric just for repetitions 
T_num = T_other(:, {'alpha', 'eta', 'inertia', 'mass', 'Max_cont_torque', 'Max_int_torque'}); 
M_num = T_num{:, :}; 
M_num(isnan(M_num)) = 0; % nan dont compare as equailes for unique 

% NOTE: could change to spefically pick row with lowest price
[M_unique, unique_rows] = unique(M_num, 'rows', 'first'); 
T_other_unique = T_other(unique_rows, :); 


fprintf('\n'); 
writetable(T_screw,'screw_gears.csv','WriteRowNames',true);  
writetable(T_other,'gears_with_rep.csv','WriteRowNames',true);
writetable(T_other_unique,'gears.csv','WriteRowNames',true);  


function num = get_num(str)
    num = str2num( regexprep( str, {'\D*([\d\.]+\d)[^\d]*',...
                                    '[^\d\.]*'}, {'$1 ', ' '} ) );
end 


function num = get_num2(str)
    B = regexp(str,'\d*','Match');
    display(B)
    gg = cell2mat(B)
    num = str2num(gg); 
end 