function [data, header] = datfileopen(datfile, Nc)
%UNTITLED3 この関数の概要をここに記述
%   詳細説明をここに記述

 datID=fopen(datfile);
 data=fread(datID);
 %data=reshape(data, [], Nc);

end

