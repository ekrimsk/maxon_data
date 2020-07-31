close all; clear all; clc;


% get the list of pages 
motors = dir('./motors/*.html'); 

num_motors = numel(motors);
%num_motors = 2; 

% loop through the pages 
num_unknown = 1;     % just check these after other code finishes running 


%T = table(Product_Number, Description, Voltage, Stall_torque, Resistance, Inductance, Shaft_size, Torque_Constant, Price); 
 
% NEED TO SKIP COMPACT DRIVES 

% Things we want 
Product_Number = strings(num_motors, 1);
Description = strings(num_motors, 1);
V = nan(num_motors, 1); 
Stall_torque = nan(num_motors, 1); 
R = nan(num_motors, 1); 
L = nan(num_motors, 1); 
inertia = zeros(num_motors, 1);
mass = zeros(num_motors, 1);
k_t = zeros(num_motors, 1);
I_nom = zeros(num_motors, 1);
omega_nl = zeros(num_motors, 1);
I_nl = zeros(num_motors, 1);
Price = zeros(num_motors, 1);

omega_max = zeros(num_motors, 1); 
R_wh = zeros(num_motors, 1);
R_ha = zeros(num_motors, 1);
Temp_max = zeros(num_motors, 1); % Temperature, NOT torque 
%Shaft_size = zeros(num_motors, 1); 


rpm2rads = 2*pi/60; % to convert RPM to rad/s


skip_list = {}; % things to skip  

fprintf('\nMotor: ');
disp_txt = []; 
for i = 1:num_motors % num_motors
    fprintf(repmat('\b', 1, length(disp_txt))); 
    disp_txt = sprintf('%d of %d', i, num_motors); 
    fprintf(disp_txt); 
    
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
                    V(i) = get_num(val);
                case 'No load speed'
                    omega_nl(i) = rpm2rads * get_num(val);
                case 'No load current'
                    I_nl(i) = get_num(val) * 1e-3; % A (NOT mA) 
                case 'Nominal speed'
                    Nominal_speed(i) = rpm2rads * get_num(val); 
                case 'Terminal resistance'
                    R(i) = get_num(val); 
                case 'Rotor inertia'
                    inertia(i) = get_num(val) * 1e-7;  % kg m^2 
                case 'Terminal inductance'
                    L(i) = get_num(val) * 1e-3; % Henrys 
                case 'Weight'
                    mass(i) = get_num(val) * 1e-3; % kg  
                case 'Torque constant'
                    k_t(i) = get_num(val) * 1e-3; 
                case 'Nominal current (max. continuous current)'
                    I_nom(i) = get_num(val);
                case 'Stall torque'
                    Stall_torque(i) = get_num(val) * 1e-3; 
                case 'Max. speed'
                    omega_max(i) = get_num(val) * rpm2rads; 
                case 'Thermal resistance housing-ambient'
                    R_ha(i) = get_num(val); 
                case 'Thermal resistance winding-housing'
                    R_wh(i) = get_num(val);
                case 'Max. winding temperature'
                    Temp_max(i) = get_num(val);
                %case 'Nominal torque (max. continuous torque)'
                %case 'Radial play'
            end 

        end 
    end 

    Product_Number(i) = part_number; 
    Description(i) = description;
    Price(i) = price_num; 

    if isnan(R(i))
        skip_list{end + 1, 1} = i; 
    end 

end 

skip_list = cell2mat(skip_list); 
k_e = k_t; % Redundancy to make code more readable 

T = table(Product_Number, Description, V,  R, L, inertia, mass, ...
                        k_t, k_e, I_nom, omega_nl, I_nl, R_wh, R_ha,...
                        omega_max, Stall_torque, Price); 

T(skip_list, :) = []; % remove rows with nan values (corresponding to compact drive)

writetable(T,'motors.csv','WriteRowNames', true);  


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