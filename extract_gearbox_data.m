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
Reduction = strings(num_gears, 1); 
Stages = nan(num_gears, 1); 
Max_cont_torque = nan(num_gears, 1); 
Max_int_torque = nan(num_gears, 1); 
Max_eff = nan(num_gears, 1); 
Inertia = nan(num_gears, 1); 
Direction = strings(num_gears, 1);
Weight = nan(num_gears, 1); 
Price = nan(num_gears, 1);
Recommended = zeros(num_gears, 1);  % 1 = rec, 0 = no rec 

for i = 1:num_gears
    fprintf('Gearbox %d..........................................................\n', i); 

    gear_text = fileread(fullfile(gears(i).folder, gears(i).name)); 

    if isempty(strfind(gear_text, 'recommended'))  % lower case because sometimes Recommended temperature
        Recommended(i) = 1;
    else 
        Recommended(i) = 0; 
    end 

    header_start = strfind(gear_text, '<h1><strong>') + 12;
    header_end = strfind(gear_text, '</strong> </h1>') - 1;

    description = gear_text(header_start:header_end);
    part_number_idx = strfind(gear_text, 'Part number'); 


    % get description too 
    if isempty(part_number_idx)
        part_number = sprintf('unknown_%d', num_unknown);
        num_unknown = num_unknown + 1;
    else 
        part_number = gear_text(part_number_idx + 12: part_number_idx + 17) ;
    end 

    table_starts = strfind(gear_text, '<table>');
    table_ends = strfind(gear_text, '</table>');

    % First table gets pricing
    if length(table_starts) > 1     % sometimes there is no pricing talbe 
        price_table = gear_text(table_starts(1):table_ends(1));
        spec_table = gear_text(table_starts(2):table_ends(2));

        % get price 
        price_tree = htmlTree(price_table); 
        price_body = findElement(price_tree, 'tbody');
        price_rows = findElement(price_body, 'tr');
        price_row = findElement(price_rows(1), 'td'); 
        price = price_row(1).extractHTMLText;

        price_num = get_num(price); 
    else 
        spec_table = gear_text(table_starts:table_ends);
        price_num = 0;
    end 


    % convert to html to extract
    spec_tree = htmlTree(spec_table); 
    spec_rows = findElement(spec_tree, 'tr');

    % get all the data elements we want 
    num_rows = numel(spec_rows);
    for k = 1:num_rows
        gg = findElement(spec_rows(k), 'td');
        if (numel(gg) > 0)
            txt = gg(2).extractHTMLText; 
            val = gg(3).extractHTMLText; 
            %fprintf('%s: %s\n', txt, val); 
            switch txt
                case 'Gearhead type'
                    Gearhead_type(i) = val; 
                case 'Reduction'    % may want "absolute reduction" instead 
                    Reduction(i) = val; 
                case 'Number of stages'
                    Stages(i) = get_num(val); 
                case 'Max. continuous torque'
                    Max_cont_torque(i) = get_num(val); 
                case 'Max. intermittent torque'
                    Max_int_torque(i) = get_num(val); 
                case 'Max. efficiency'
                    Max_eff(i) = get_num(val); 
                case 'Mass inertia'
                    Inertia(i) = get_num(val);
                case 'Direction of rotation, drive to output'
                    Direction(i) = val; 
                case 'Weight'
                    Weight(i) = get_num(val); 

            end 

        end 
    end 

    Product_Number(i) = part_number; 
    Description(i) = description;
    Price(i) = price_num; 

end 


T = table(Product_Number, Description, Gearhead_type, Reduction, Stages,...
                     Max_cont_torque, Max_int_torque, Max_eff, Inertia,...
                     Direction, Weight, Recommended, Price); 
writetable(T,'gears.csv','WriteRowNames',true);  


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