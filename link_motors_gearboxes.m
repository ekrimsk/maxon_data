close all; clear all; clc; 

% Create all the valid combos 



% load in the motor data 

motor_table = readtable('motors.csv'); 
num_motors = size(motor_table, 1); 
motors = table2struct(motor_table);

gear_table = readtable('gears.csv'); 
gears = table2struct(gear_table); 

combos = fileread('combos.txt'); 
combo_lines = strsplit(combos, '\n'); 



gb_list = cell(num_motors, 1); 


fprintf('\nMotor: ');
disp_txt = []; 
for i = 1:num_motors
    fprintf(repmat('\b', 1, length(disp_txt))); 
    disp_txt = sprintf('%d of %d', i, num_motors); 
    fprintf(disp_txt); 

    % get the gear lists 
    tmp = strsplit(combo_lines{i}, ';');    % first is  
    if numel(tmp) > 1
        gear_list = cellfun(@strtrim, tmp(2:end-1), 'UniformOutput', false); % remove any leading whtespace 

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
    motor_table.('gearboxes')(i) = gb_list(i);   % add to table 
end 
fprintf('\n'); 
save('maxon_motor_gb_data.mat');

