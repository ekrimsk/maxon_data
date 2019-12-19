close all; clear all; clc;


% get the list of pages 
motors = dir('./motors/*.html'); 

num_motors = numel(motors);
%num_motors = 2; 

% loop through the pages 
num_unknown = 1;     % just check these after other code finishes running 


%T = table(Product_Number, Description, Voltage, Stall_torque, Resistance, Inductance, Shaft_size, Torque_Constant, Price); 
 

% Things we want 
Product_Number = strings(num_motors, 1);
Description = strings(num_motors, 1);
Voltage = zeros(num_motors, 1); 
Stall_torque = nan(num_motors, 1); 
Resistance = nan(num_motors, 1); 
Inductance = nan(num_motors, 1); 
Shaft_size = zeros(num_motors, 1); 
Rotor_inertia = zeros(num_motors, 1);
Weight = zeros(num_motors, 1);
Torque_constant = zeros(num_motors, 1);
Nominal_current = zeros(num_motors, 1);
No_load_speed = zeros(num_motors, 1);
No_load_current = zeros(num_motors, 1);
Price = zeros(num_motors, 1);



for i = 1:num_motors % num_motors
    fprintf('Motor %d...\n', i); 

    motor_text = fileread(fullfile(motors(i).folder, motors(i).name)); 

    header_start = strfind(motor_text, '<h1><strong>') + 12;
    header_end = strfind(motor_text, '</strong> </h1>') - 1;

    description = motor_text(header_start:header_end);

    



    % get part number oif have 
    %pen rotor</span>Part number 625858</p>
    part_number_idx = strfind(motor_text, 'Part number'); 


    % get description too 

    if isempty(part_number_idx)
        part_number = sprintf('unknown_%d', num_unknown);
        num_unknown = num_unknown + 1;
    else 
        part_number = motor_text(part_number_idx + 12: part_number_idx + 17) ;
    end 

    table_starts = strfind(motor_text, '<table>');
    table_ends = strfind(motor_text, '</table>');

    % First table gets pricing
    price_table = motor_text(table_starts(1):table_ends(1));
    spec_table = motor_text(table_starts(2):table_ends(2));

    % get price 
    price_tree = htmlTree(price_table); 
    price_body = findElement(price_tree, 'tbody');
    price_rows = findElement(price_body, 'tr');
    price_row = findElement(price_rows(1), 'td'); 
    price = price_row(1).extractHTMLText;

    price_num = get_num(price); 


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
                case 'Nominal voltage'
                    Voltage(i) = get_num(val);
                case 'No load speed'
                    No_load_speed(i) = get_num(val);
                case 'No load current'
                    No_load_current(i) = get_num(val); 
                case 'Nominal speed'
                    Nominal_speed(i) = get_num(val); 
                case 'Terminal resistance'
                    Resistance(i) = get_num(val); 
                case 'Rotor inertia'
                    Rotor_inertia(i) = get_num(val); 
                case 'Terminal inductance'
                    Inductance(i) = get_num(val);
                case 'Weight'
                    Weight(i) = get_num(val); 
                case 'Torque constant'
                    Torque_constant(i) = get_num(val); 
                case 'Nominal current (max. continuous current)'
                    Nominal_current(i) = get_num(val);
                case 'Stall torque'
                    Stall_torque(i) = get_num(val); 
                %case 'Nominal torque (max. continuous torque)'
                %case 'Radial play'
            end 

        end 
    end 

    Product_Number(i) = part_number; 
    Description(i) = description;
    Price(i) = price_num; 

end 


T = table(Product_Number, Description, Voltage, Stall_torque, Resistance, Inductance, Rotor_inertia,...
                                         Torque_constant, Nominal_current, No_load_speed, No_load_current, Weight, Price); 
writetable(T,'motors.csv','WriteRowNames',true);  


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