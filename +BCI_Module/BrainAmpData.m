classdef BrainAmpData < BCI_Module.ExperimentData
    %UNTITLED2 このクラスの概要をここに記述
    %   詳細説明をここに記述
    
    properties
    end
    
    methods (Access = public)
        %BrainAmpデータのフォーマット合わせ
        function o=ExpandEEG(obj)
           
            %EEGファイル作成
            o=obj.LoadBrainampFile();
            
            %波形分割
            o=obj.RemoveRedundantData(o);
            
            %トリガの確保
            o=obj.ExtractTrigger(o);
            
            %ラベルの作成
            o=obj.MakeRabelData(o);
            
        end
    end
    
    methods (Access = protected)
        function o=LoadBrainampFile(obj)
            o=BCI_Module.EEG;
            load(obj.File);
            o.Signal=eeg';   %この時点ではトリガと分けて無い事に注意
            o.WavePos=1;    %後で列挙体に変更
            o.SamplingFreq=obj.SamplingFreq;    
        end
        
        function o=RemoveRedundantData(obj, i)
            %ローカル変数生成
            o=i;
            S=i.Signal;
            Fs=i.SamplingFreq;
            Ns=size(S,1);
            Ne=i.ChanelNum;
            Tm=obj.MeasureTime;
            Offset=obj.StartOffset;
            
            %トリガ探索
            for t=1:Ns
                if S(t, Ne)==1
                    trg=t;
                    break;
                end
            end
            
            %開始位置の決定
            start=trg-Offset*Fs;
            
            %切り出し開始
            o.Signal=S(start:start+(Tm*Fs)-1,:);
            
        end
        
        function o=ExtractTrigger(obj, i)
            %ローカル変数生成
            o=i;
            Ne=i.ChanelNum;
            
            %トリガ分離
            o.Signal=i.Signal(:, 1:Ne-1);
            o.Trigger=i.Signal(:, Ne);
            
        end
        
        function o=MakeRabelData(obj, i)
            %ローカル変数生成
            o=i;
            n=1;
            T=i.Trigger;
            o.Rabel=zeros(size(i.Trigger));
            Ns=length(i.Trigger);
            load(obj.TriggerTable);
            Fs=i.SamplingFreq;
            
            %ラベル情報への変換
            for t=1:Ns
                if T(t)==1
                    if TriggerTable(n, 3)~=0
                        %記録開始時間の遅れ
                        delay=Fs*TriggerTable(n, 2);
                        %点滅継続時間
                        sus=(Fs*TriggerTable(n, 3))-1;
                        %ラベルデータ生成
                        o.Rabel(t+delay : t+delay+sus)=...
                            TriggerTable(n, 1);
                    end
                    n=n+1;
                end
                %終了の合図が出たらループ抜ける
                if TriggerTable(n,1)==-2
                    break;
                end
            end
            
        end
        
    end 
    
    
end

