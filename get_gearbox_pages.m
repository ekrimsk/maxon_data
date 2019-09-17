close all; clear all; clc;

% Recommended
%string_start="curl 'https://www.maxongroup.in/maxon/view/category/prodfilter/gear?pn_id=ProductSearch&pn_p=";
%string_end ="&pn_ok=&_=1564524905271' -H 'Cookie: isSdEnabled=false; JSESSIONID=61868A78D4AC21C6617CAF9EFA773E01.node1; TS01c7a627=01f8768e72946f98ad913f6722732bd51dcb869511e44f0dbcbf7b054da26b4d5ec60ff2ff4e844c1429c0c7b6983370b569c10547c1af68396d5e7b79ee54af7efbc88572; BT_ctst=101; atuserid=%7B%22name%22%3A%22atuserid%22%2C%22val%22%3A%22ca7c53ee-af47-410d-b8ae-d4293e250275%22%2C%22options%22%3A%7B%22end%22%3A%222020-08-29T22%3A42%3A03.820Z%22%2C%22path%22%3A%22%2F%22%7D%7D; BT_sdc=eyJldF9jb2lkIjoiTkEiLCJyZnIiOiIiLCJ0aW1lIjoxNTY0NDQwMTI0MDAxLCJwaSI6MCwiZXVybCI6Imh0dHBzOi8vd3d3Lm1heG9uZ3JvdXAuaW4vbWF4b24vdmlldy9jb250ZW50L2luZGV4IiwicmV0dXJuaW5nIjowLCJldGNjX2NtcCI6Ik5BIiwic21zIjpudWxsLCJub1dTIjoidDliUnIzIn0%3D; _et_coid=6a2dfd84c83ed8b4a390b2f620dcff9f; BT_pdc=eyJ2aWQiOiJOQSIsImV0Y2NfY3VzdCI6MCwiZWNfb3JkZXIiOjAsImV0Y2NfbmV3c2xldHRlciI6MCwic21zIjpudWxsLCJub19zaWduYWxpemUiOmZhbHNlfQ%3D%3D; cookieBarAgreement=true; TS01780029=01f8768e72c41be699c99a20a97d433e3e85d02ee093bed14517403f526f7e8a130574a24527828f036277998a3c938b039ec4ea26' -H 'Accept-Encoding: gzip, deflate, br' -H 'Accept-Language: en-US,en;q=0.9,he-IL;q=0.8,he;q=0.7,es-US;q=0.6,es;q=0.5' -H 'User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/75.0.3770.100 Safari/537.36' -H 'Accept: */*' -H 'Referer: https://www.maxongroup.in/maxon/view/category/gear?etcc_cu=onsite&etcc_med_onsite=Product&etcc_cmp_onsite=GPX+Planetary+Gearheads&etcc_plc=Overview-Page-Gears&etcc_var=%5bin%5d%23en%23_d_&target=filter&filterCategory=planetary&q=GPX' -H 'X-Requested-With: XMLHttpRequest' -H 'Connection: keep-alive' --compressed";


% All 
string_start = "curl 'https://www.maxongroup.in/maxon/view/category/prodfilter/gear?pn_id=ProductSearch&pn_p=";
string_end = "&pn_ok=&_=1564630429005' -H 'Cookie: isSdEnabled=false; isSdEnabled=true; JSESSIONID=B82F212B2A668D4E4ED9AF634B088741.node1; TS01c7a627=01f8768e72f803d6d245b818923b96e245d2dc0afe1cb83a927899aa97cbbd6185b30f42c2d79098220dd9a05fbb243868287cb700d050378e9ec18aff2c81fbdab983f976; atuserid=%7B%22name%22%3A%22atuserid%22%2C%22val%22%3A%22ca7c53ee-af47-410d-b8ae-d4293e250275%22%2C%22options%22%3A%7B%22end%22%3A%222020-08-29T22%3A42%3A03.820Z%22%2C%22path%22%3A%22%2F%22%7D%7D; _et_coid=6a2dfd84c83ed8b4a390b2f620dcff9f; BT_pdc=eyJ2aWQiOiJOQSIsImV0Y2NfY3VzdCI6MCwiZWNfb3JkZXIiOjAsImV0Y2NfbmV3c2xldHRlciI6MCwic21zIjpudWxsLCJub19zaWduYWxpemUiOmZhbHNlfQ%3D%3D; BT_ctst=101; BT_sdc=eyJldF9jb2lkIjoiTkEiLCJyZnIiOiIiLCJ0aW1lIjoxNTY0NjI3MTgyMTIwLCJwaSI6MCwiZXVybCI6Imh0dHBzOi8vd3d3Lm1heG9uZ3JvdXAuaW4vbWF4b24vdmlldy9jb250ZW50L2luZGV4IiwicmV0dXJuaW5nIjowLCJldGNjX2NtcCI6Ik5BIiwic21zIjpudWxsLCJub1dTIjoidDliUnIzIn0%3D; TS01780029=01f8768e726a7e04a1d07e019e8cea0e5749688170d76080e44d12d6111c505846c08d4940fb70b863251037e29bddf3b98bd1b37a' -H 'Accept-Encoding: gzip, deflate, br' -H 'Accept-Language: en-US,en;q=0.9,he-IL;q=0.8,he;q=0.7,es-US;q=0.6,es;q=0.5' -H 'User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/75.0.3770.100 Safari/537.36' -H 'Accept: */*' -H 'Referer: https://www.maxongroup.in/maxon/view/product/gear/planetary/gp52/223112' -H 'X-Requested-With: XMLHttpRequest' -H 'Connection: keep-alive' --compressed"

mkdir('gearbox_pages')



% first just loop through pages and save from maxon india 


% 121 pages if only use reccomnended 
% 244 if use all 


for i = 1:244   % planetary and spur 
    fprintf('Gearbox list page %d.............\n', i); 
    str = [char(string_start), num2str(i), char(string_end), sprintf('> ./gearbox_pages/gearboxpage_%0.3d.html', i)]; 
    [status, res] = system(str);
end 


