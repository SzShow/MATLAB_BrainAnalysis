function [data, header] = datfileopen(datfile, Nc)
%UNTITLED3 ���̊֐��̊T�v�������ɋL�q
%   �ڍא����������ɋL�q

 datID=fopen(datfile);
 data=fread(datID);
 %data=reshape(data, [], Nc);

end

