close all; clear all; clc;


idx = 1;


% should change this to just dump all the motor pages where it reads them 
mkdir('gears')

% 121 for recommended
% 244 for all 

for i = 1:244 % for india version  


    data = fileread(sprintf('./gearbox_pages/gearboxpage_%0.3d.html', i));
    data_split = split(data, "articleDesc");

    
    for k = 3:length(data_split)
        fprintf('Grabbing data for gearbox %d.........................\n', idx); 

        % Find the first occurence of href 
        gear_data = char(data_split{k});
        ref_idx = strfind(gear_data, 'href'); 
 
        url_idx_start = ref_idx+6;
        url_idx_end = url_idx_start + find(gear_data(url_idx_start:end) == '"', 1, 'first') - 2; 
        spec_url = ['https://www.maxongroup.com', gear_data(url_idx_start:url_idx_end), '?_=1']; 
        system(['curl ', spec_url, sprintf(' > ./gears/gear_%0.4d.html', idx)]); 
        idx = idx + 1;
    end 
    
end 

%https://www.mathworks.com/matlabcentral/answers/44049-extract-numbers-from-mixed-string
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