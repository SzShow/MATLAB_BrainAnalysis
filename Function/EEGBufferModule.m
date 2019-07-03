classdef EEGBufferModule
    %UNTITLED このクラスの概要をここに記述
    %   詳細説明をここに記述
    
    properties
        WinLength
        Overlap
    end
    
    methods
        function obj = EEGBufferModule(winLen, olap)
            %UNTITLED このクラスのインスタンスを作成
            %   詳細説明をここに記述
            obj.WinLength=winLen;
            obj.Overlap=olap;

            
        end
        
        function [Output, Tepo]=divepoch(obj, Input, Ref)
            Fs=Ref.Fs;
            WinLen=obj.WinLength;
            OLap=obj.Overlap;
            [DLen, Nch]=size(Input);
            Nepo=floor((DLen-WinLen*Fs)/(Olap*Fs));
            %出力のサイズを計算
            Output=zeros(WinLen*Fs, Nch, Nepo);
            %エポックの終了位置の配列
            Tepo=zeros(Nepo, 1);
            
            %エポック分割の開始
            for e=1:Nepo
                %切り取りのスタート位置を設定
                st=(e-1)*OLap*Fs;
                %e番目のエポックに切り取ったデータを代入
                Output(:,:,e)=Input(st+1:st+WinLen*Fs, :);
                Tepo(e)=st+WinLen*Fs;
            end
        end
    end
end

