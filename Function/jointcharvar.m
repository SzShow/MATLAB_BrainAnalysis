function [CharArg] = jointcharvar(CellArg)
%UNTITLED2 この関数の概要をここに記述
%   詳細説明をここに記述
    str=string(CellArg);     %ストリング型のセル配列の作成
    str=join(str, '');          %セル配列を空白なしで一つのセルに統合
    CharArg=char(str);              %ストリング配列をchar配列に変換
end

