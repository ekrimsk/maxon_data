close all; clear all; clc; 

% Create all the valid combos 



% load in the motor data 

motor_table = readtable('motors.csv'); 

% Convert every column to plan si units 
motor_table.Stall_torque = motor_table.Stall_torque/1000; % Now Nm 
motor_table.Inductance = motor_table.Inductance/1000;       % now Henrys 
motor_table.Rotor_inertia = motor_table.Rotor_inertia  * 1e-7;    %  kg m^2 
motor_table.Torque_constant = motor_table.Torque_constant/1000;     % Nm/A
motor_table.Weight = motor_table.Weight/1000;   % kg 
motor_table.No_load_current = motor_table.No_load_current/1000;     % convert mA to A 



[num_motors, ~] = size(motor_table); 
motors = table2struct(motor_table);



gear_table = readtable('gears.csv'); 
gear_table.Inertia = gear_table.Inertia * 1e-7; % kgm^2 

gears = table2struct(gear_table); 

combos = fileread('combos.txt'); 
combo_lines = strsplit(combos, '\n'); 



gb_list = cell(num_motors, 1); 
for i = 1:num_motors
    fprintf('Motor %d.................\n', i); 

    % get the gear lists 

    tmp = strsplit(combo_lines{i}, ';');    % first is  

    if numel(tmp) > 1
        gear_list = cellfun(@strtrim, tmp(2:end-1), 'UniformOutput', false); % remove any leading whtespace 

        % TODO -- factor out any screw drive options 

        num_gear = numel(gear_list); 

        % Find by product number 
        indices_prod_num = find(ismember(gear_table.Product_Number, gear_list));
        indices_desc = find(ismember(gear_table.Description, gear_list));
        indices = unique([indices_prod_num; indices_desc]); 

        gb_list{i} = indices; 
    else 
        gb_list{i} = [];
    end 
    motors(i).gb_list = gb_list{i};  
end 

save('motor_gb_data.mat');

% This is just a list but maybe thats fine -- want some good way to save this, load, select, and filter 

