close all; clear all; clc;

string_start = "curl 'https://www.maxongroup.us/maxon/view/category/prodfilter/motor?pn_id=ProductSearch&pn_p=";
string_end = "&pn_ok=&_=1562705445546' -H 'Cookie: isSdEnabled=true; JSESSIONID=A38377D89B76E504B3AB3B90EA6731B1.node2; TS01c7a627=01f8768e725d19d66f63b9d093f4ec72260564868e605da907eb10a17cd8f2ffdcd0ba5b15b8e377a79288c6d0e688d1e7f0ffac26904caa542ee2eea0169bc8e71acfcc81; BT_ctst=101; atuserid=%7B%22name%22%3A%22atuserid%22%2C%22val%22%3A%22813fce16-d4b4-4387-95e1-cad7ab82e4eb%22%2C%22options%22%3A%7B%22end%22%3A%222020-08-02T15%3A59%3A00.097Z%22%2C%22path%22%3A%22%2F%22%7D%7D; _ga=GA1.2.1077307880.1562083140; _et_coid=6a2dfd84c83ed8b4a390b2f620dcff9f; BT_sdc=eyJldF9jb2lkIjoiTkEiLCJyZnIiOiJodHRwczovL3d3dy5nb29nbGUuY29tLyIsInRpbWUiOjE1NjIwODMxNDE3NTEsInBpIjowLCJldXJsIjoiaHR0cHM6Ly93d3cubWF4b25ncm91cC51cy9tYXhvbi92aWV3L2NvbnRlbnQvaW5kZXgiLCJyZXR1cm5pbmciOjAsImV0Y2NfY21wIjoiTkEiLCJzbXMiOm51bGwsIm5vV1MiOiJtOWdheEsifQ%3D%3D; BT_pdc=eyJ2aWQiOiJOQSIsImV0Y2NfY3VzdCI6MCwiZWNfb3JkZXIiOjAsImV0Y2NfbmV3c2xldHRlciI6MCwic21zIjpudWxsLCJub19zaWduYWxpemUiOmZhbHNlfQ%3D%3D; ASP.NET_SessionId=gagujq3y35p4ez4mo0t0pbli; _gid=GA1.2.1044723703.1562693225; cookieBarAgreement=true; TS01780029=01f8768e724273fcfddfe2d6f1c5e845d6e4d0cbcc9c7ee6650d0cd7cd0600910aebf8190b1ac3123209c879f4cc99fdd0e475ee9e3ea42a775972dddf7ff4a8a40df65184; _gat_UA-59797293-7=1; _gat_UA-59797293-1=1' -H 'Accept-Encoding: gzip, deflate, br' -H 'Accept-Language: en-US,en;q=0.9,he-IL;q=0.8,he;q=0.7,es-US;q=0.6,es;q=0.5' -H 'User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/74.0.3729.169 Safari/537.36' -H 'Accept: */*' -H 'Referer: https://www.maxongroup.us/maxon/view/category/motor?etcc_cu=onsite&etcc_med_onsite=Product&etcc_cmp_onsite=DCX+Program&etcc_plc=Overview-Page-DC-Motors&etcc_var=%5bus%5d%23en%23_d_&target=filter&filterCategory=DCX' -H 'X-Requested-With: XMLHttpRequest' -H 'Connection: keep-alive' --compressed > tmp_motor.html";

idx = 1; 


for i = 1:63 % 63 for usa 

    str = [char(string_start), num2str(i), char(string_end)]; 
    [status, res] = system(str);
    
    data = fileread('tmp_motor.html');
    data_split = split(data, "articleDesc");
    
    for k = 3:length(data_split)
        fprintf('Scraping data for motor %d\n', idx); 
        motor_data = data_split{k};
        
        
       
        next_split = split(motor_data, '</td>');
        description = next_split{1}(3:end-1);
        shaft_size = get_num(next_split{2});  % mm
        wattage = get_num(next_split{3});
        voltage = get_num(next_split{4});
        idle_speed = get_num(next_split{5});
        torque_constant = get_num(next_split{6});
        price = get_num(next_split{7});

        specs = next_split{8}; 
        spec_url_split = split(specs, 'href="'); 
        spec_url = spec_url_split{2}; 
        url_idx = find(spec_url == '"', 1, 'first'); 


        % From the specs 
        spec_url = ['https://www.maxongroup.com', spec_url(1:url_idx-1), '?_=1']; 
        spec_data = webread(spec_url); 


        spec_split = split(spec_data, '<td class="numberedCol"></td>'); 
       
        no_load_rpm = get_num(spec_split{3}); 
        no_load_current = get_num(spec_split{4}); 

        max_con_torque = get_num(spec_split{6});

        if isempty(max_con_torque)
            max_con_torque = get_num2(spec_split{6});
            display(spec_split{6})
            display(max_con_torque)
        end 

        stall_torque = get_num(spec_split{8});
        max_eff = get_num(spec_split{10}(1:65));

        j = 0;
        res_string = spec_split{11};
        if isempty( strfind(spec_split{11}, 'resistance'))
            j = 1; 
        end 
        resistance = get_num(spec_split{11+j}); % ohm 




        inductance = get_num(spec_split{12+j}); % mH
        inertia = get_num(spec_split{17+j}(1:75)); % gcm^2


        ms_string = spec_split{24 + j};
        if isempty( strfind(spec_split{24 + j}, 'Max. speed'))
            ms_string = spec_split{25 + j};
        end 
        max_speed = get_num(ms_string);


        No_load_RPM(idx) = no_load_rpm;
        No_load_current(idx) = no_load_current; 
        Max_cont_torque(idx) = max_con_torque; 
        Stall_torque(idx) = stall_torque;
        Max_efficiency(idx) = max_eff; 
        Resistance(idx) = resistance;
        Inductance(idx) = inductance;
        Inertia(idx) = inertia; 
        Max_speed(idx) = max_speed; 


        V(idx) = voltage;
        Watt(idx) = wattage; 
        Shaft(idx) = shaft_size; 
        Idle_speed(idx) = idle_speed;
        kt_mNm(idx) = torque_constant;
        Price(idx) = price; 
        Description(idx) = string(description); 
        idx = idx + 1;
    end 
    
end 


% price, wattage, voltage, rpm, torque constant, shaft size, description
No_load_RPM = No_load_RPM(:);
No_load_current = No_load_current(:);
Max_cont_torque = Max_cont_torque(:);
Stall_torque = Stall_torque(:); 
Max_efficiency = Max_efficiency(:); 
Resistance = Resistance(:);
Inductance = Inductance(:); 
Inertia = Inertia(:);
Max_speed = Max_speed(:); 

Description = Description(:);
V = V(:);
Watt = Watt(:);
kt_mNm = kt_mNm(:);
Price = Price(:); 
Idle_speed = Idle_speed(:);
Shaft = Shaft(:); 

T = table(Description, V, Watt, Resistance, Shaft, kt_mNm, Max_speed, ...
         No_load_RPM, No_load_current, Stall_torque, Inertia, Max_efficiency, Inductance, Price); 
writetable(T,'maxon_dc_motors.csv','WriteRowNames',true);  


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