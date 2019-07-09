close all; clear all; clc;


string_start = "curl 'https://www.maxongroup.com/maxon/view/category/prodfilter/gear?pn_id=ProductSearch&pn_p=";
string_end ="&pn_ok=&_=1562696640268' -H 'Cookie: isSdEnabled=true; JSESSIONID=3206956DFF1653EFA5890CA026973095.node1; TS01c7a627=01f8768e72935505fe0be3c74c39879f50f2ac317bb2dd46b7d41ff046a185eb3e35b1bd9efca596bb39b61c18bc6aa4e2279b76b7fac202bdbf5ff1ed54b5790b04fb007b; BT_ctst=101; atuserid=%7B%22name%22%3A%22atuserid%22%2C%22val%22%3A%2230c595ec-b2c8-41ac-b96c-637a01753d73%22%2C%22options%22%3A%7B%22end%22%3A%222020-08-09T04%3A42%3A42.988Z%22%2C%22path%22%3A%22%2F%22%7D%7D; _ga=GA1.2.1284092474.1562647363; _gid=GA1.2.503805160.1562647363; BT_sdc=eyJldF9jb2lkIjoiTkEiLCJyZnIiOiJodHRwczovL3d3dy5nb29nbGUuY29tLyIsInRpbWUiOjE1NjI2NDczNjM3NDUsInBpIjowLCJldXJsIjoiaHR0cHM6Ly93d3cubWF4b25ncm91cC5jb20vbWF4b24vdmlldy9jb250ZW50L2luZGV4IiwicmV0dXJuaW5nIjowLCJldGNjX2NtcCI6Ik5BIiwic21zIjpudWxsLCJub1dTIjoiUzU5cjZtIn0%3D; _et_coid=6a2dfd84c83ed8b4a390b2f620dcff9f; BT_pdc=eyJ2aWQiOiJOQSIsImV0Y2NfY3VzdCI6MCwiZWNfb3JkZXIiOjAsImV0Y2NfbmV3c2xldHRlciI6MCwic21zIjpudWxsLCJub19zaWduYWxpemUiOmZhbHNlfQ%3D%3D; TS01780029=01f8768e72d7c3428471e9379192f439ae10786710919147393c0ce4c666af37336415bd5708a3b1d463ddce4c8d67b6d02aa5c5fc; _dc_gtm_UA-59797293-1=1' -H 'Accept-Encoding: gzip, deflate, br' -H 'Accept-Language: en-US,en;q=0.9,he-IL;q=0.8,he;q=0.7,es-US;q=0.6,es;q=0.5' -H 'User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/74.0.3729.169 Safari/537.36' -H 'Accept: */*' -H 'Referer: https://www.maxongroup.com/maxon/view/category/gear?etcc_cu=onsite&etcc_med_onsite=Product&etcc_cmp_onsite=Planetary+Gearheads+(GP)&etcc_plc=Overview-Page-Gears&etcc_var=%5bcom%5d%23en%23_d_&target=filter&filterCategory=planetary' -H 'X-Requested-With: XMLHttpRequest' -H 'Connection: keep-alive' --compressed > ./tmp.html";



idx = 1; 


for i = 1:119   % all planetary 
    str = [char(string_start), num2str(i), char(string_end)]; 
    system(str);

    data = fileread('tmp.html');
    data_split = split(data, "articleDesc");
    
    
    for k = 3:length(data_split)



        gear_data = data_split{k};
        
        
        next_split = split(gear_data, '</td>');
        
        description = next_split{1}(3:end-1);
        shaft_size = get_num(next_split{2});  % mm
        
        ratio = next_split{3};
        start_idx = find(ratio == '>', 1, 'first');
        ratio =  ratio(start_idx+1:end-1);

        max_torque = get_num(next_split{4});

        price = get_num(next_split{6});


        % split 7 might contrain data sheet 
        specs = next_split{7}; 
        spec_url_split = split(specs, 'href="'); 
        spec_url = spec_url_split{2}; 
        url_idx = find(spec_url == '"', 1, 'first'); 

        spec_url = ['https://www.maxongroup.com', spec_url(1:url_idx-1), '?_=1']; 
        spec_data = webread(spec_url); 

        spec_split = split(spec_data, '</td>'); 


        eff_str = '<td>Max. efficiency</td>';
        weight_str = '<td>Weight</td>'; % g 
        inertia_str = '<td>Mass inertia</td>'; % gcm^2 
        
        k = strfind(spec_data, eff_str);
        eff = str2num(spec_data(k+41:k+42)); 

        k2 = strfind(spec_data, weight_str);
        %weight = str2num(spec_data(k2+31:k2+35)); 
        weight = get_num(spec_data(k2+31:k2+35)); 

        k3 = strfind(spec_data, inertia_str);       
        %inertia = str2num(spec_data(k3+38:k3+41)); 
        inertia = get_num(spec_data(k3+35:k3+44));



        %display(eff)
        %display(inertia)
        %display(weight)
 
        Efficiency(idx) = eff; 
        Weight(idx) = weight; 
        Inertia(idx) = inertia; 
        Description(idx) = string(description);         
        Shaft(idx) = shaft_size; 
        %RPM(idx) = rpm;
        Ratio(idx) = string(ratio);
        Torque(idx) = max_torque;
        Price(idx) = price; 
        idx = idx + 1;
        
    end 
    
    
end 


% price, wattage, voltage, rpm, torque constant, shaft size, description
Description = Description(:);
Torque = Torque(:);
Price = Price(:); 
Ratio = Ratio(:);
Shaft = Shaft(:); 
Efficiency = Efficiency(:);
Weight = Weight(:); 
Inertia = Inertia(:); 

T = table(Description, Torque, Ratio, Efficiency, Weight, Inertia, Shaft, Price); 
writetable(T,'maxon_gears.csv','WriteRowNames',true);  




%https://www.mathworks.com/matlabcentral/answers/44049-extract-numbers-from-mixed-string
function num = get_num(str)
    num = str2num( regexprep( str, {'\D*([\d\.]+\d)[^\d]*',...
                                    '[^\d\.]*'}, {'$1 ', ' '} ) );
end 