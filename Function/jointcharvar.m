function [CharArg] = jointcharvar(CellArg)
%UNTITLED2 ���̊֐��̊T�v�������ɋL�q
%   �ڍא����������ɋL�q
    str=string(CellArg);     %�X�g�����O�^�̃Z���z��̍쐬
    str=join(str, '');          %�Z���z����󔒂Ȃ��ň�̃Z���ɓ���
    CharArg=char(str);              %�X�g�����O�z���char�z��ɕϊ�
end

