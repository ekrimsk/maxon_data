
txt = fileread('./get_combos/motor_gb_combos.txt');
f = fopen('combos.txt', 'w'); 
lines = strsplit(txt, '\n');

num_unknown = 1; 

for i = 1:(numel(lines) - 1)    % last line empty 

    cur_line = lines{i}; 

    split = strsplit(cur_line, ';'); 
    if ~isempty(strfind(split{1}, 'unknown'))
        split{1} = ['unknown_', num2str(num_unknown)];
        num_unknown = num_unknown + 1; 
    end 
    new_line = strjoin(split, ';'); 
    fprintf(f, [new_line, '\n']);
end 
fclose(f); 


