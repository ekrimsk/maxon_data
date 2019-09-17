close all; clear all; clc; 




% get the list of pages 
combo_pages = dir('./combos/*.txt'); 

num_pages = numel(combo_pages);


system('touch motor_gb_combos.txt'); 

for i = 1:num_pages
    system(sprintf('cat %s >> motor_gb_combos.txt', fullfile(combo_pages(i).folder, combo_pages(i).name))); 
end 


