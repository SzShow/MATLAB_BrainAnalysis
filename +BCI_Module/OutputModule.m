classdef (Abstract)OutputModule
    %OutputModule 出力モジュールの基底クラス
    %   
    
    properties
        
    end
	
	%分類器の学習とテストを抽象メソッドとして定義
    methods (Abstract)
        obj=training(obj, varargin)
        cmd=test(obj, varargin)
    end
end

