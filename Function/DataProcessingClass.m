classdef DataProcessingClass
    %UNTITLED このクラスの概要をここに記述
    %   詳細説明をここに記述
    
    properties
        PreprocessedData;
        
        SNR_NumberOfHarmonics;
        WindowTime;
        IntervalTime;
        ExtractedFeature;
        ExtractFeatureModeIs;
        
        Classification;
        ZeroFrequencyFlag;
        ClassList;
    end
    
    methods
        %% [コンストラクター]
        function obj = DataProcessingClass(TDC, PPC, EDC)
            %UNTITLED このクラスのインスタンスを作成
            %   詳細説明をここに記述
            global tdc;
            global ppc;
            global edc;
            tdc=TDC;
            ppc=PPC;
            edc=EDC;
        end
        
        %% [前処理]
        function obj=preprocess(obj)
            %変数代入
            %W:     空間フィルタ
            %Ff:    実験中に提示した点滅周波数
            %Nf:    点滅周波数の数
            %Y:     テストデータ
            global ppc;
            global tdc;
            global edc;
            W=ppc.SpatialFilter;
            Ff=tdc.FlickerFrequency;
            Nf=tdc.NumberOfFrequency;
            Y=edc.TestData;
            
            %前処理実行
            for f=1:Nf
                %点滅周波数0はスキップ
                if Ff(f)==0
                    obj.ZeroFrequencyFlag=1;
                    continue;
                end
                s=string({'f', round(Ff(f))});%次のテーブル名設定
                s=join(s,"");%string文字配列の連結 
                s=char(s);
                S.(s)=Y*W.(s);
            end
            
            obj.PreprocessedData=S;

        end
        
        %% [特徴量抽出]
        
        %　[ケース１]
        function obj=featureextraction(obj)
            %変数代入
            global tdc;
            global edc;
            Nf=tdc.NumberOfFrequency;
            Ff=tdc.FlickerFrequency;
            S=obj.PreprocessedData;
            Nh=obj.SNR_NumberOfHarmonics;
            Tw=obj.WindowTime;
            Ti=obj.IntervalTime;
            Fs=edc.SamplingFrequency;
            Y=edc.TestData;
            
            %点滅周波数の特徴量抽出
            for f=1:Nf
                if Ff(f)==0                  
                    continue;
                end
                
                s=string({'f', round(Ff(f))});%次のテーブル名設定
                s=join(s,"");%string文字配列の連結 
                s=char(s);
                [S.(s), Np]=persedata(obj, S.(s), Tw, Ti);
                F.(s)=zeros(Np,1);
                
                for t=1:Np
                     F.(s)(t)=ssvepsnr(S.(s)(:, :, t), Ff(f), Nh, Fs);
                end
            end
            
            obj.ExtractedFeature=F;
            
        end
        
        % [ケース２]
        function obj=featureextraction2(obj)
            %変数代入
            global tdc;
            global edc;
            global ppc;
            Nf=tdc.NumberOfFrequency;
            Ff=tdc.FlickerFrequency;
            Tm=edc.MeasurementTime;
            Lf=edc.FlickerList;
            %S=obj.PreprocessedData;
            Nh=obj.SNR_NumberOfHarmonics;
            Tw=obj.WindowTime;
            Ti=obj.IntervalTime;
            Fs=edc.SamplingFrequency;
            Y=edc.TestData;
            m=ppc.Method;
            
            %点滅周波数の特徴量抽出
            for f=1:Nf
                if Ff(f)==0
                    [S, Np]=persedata(obj, Y, Tw, Ti);                   
                    continue;
                end
                
                s=string({'f', round(Ff(f))});%次のテーブル名設定
                s=join(s,"");%string文字配列の連結 
                s=char(s);
                [S, Np]=persedata(obj, Y, Tw, Ti);
                F.(s)=zeros(Np,1);
                
            end
            
            %点滅周波数データのサンプル点移動
            T=Tw:Ti:Tm;
            Fc=zeros(length(T), 1);
            for t=1:length(T)
                Fc(t)=Lf(floor(T(t)));
            end
            
            %抽出の実行
            for t=1:Np
                %要整理
                for f=1:Nf
                    s=string({'f', round(Ff(f))});%次のテーブル名設定
                    s=join(s,"");%string文字配列の連結 
                    s=char(s);
                    if Fc(t)~=0
                        switch m
                            case 'MEC' 
                                [~, W, ~]=mec(S(:,:,t), Fc(t), Nh, Fs);
                            case 'MCC'
                                [~, W, ~]=mcc(S(:,:,t), Fc(t), Nh, Fs);
                            otherwise
                                W=eye(length(S(1,:,t)));
                        end
                        Signal=S(:,:,t)*W;
                    else
                        Signal=S(:,:,t);
                    end
                    
                    if Ff(f)==0
                        continue;
                    end

                    F.(s)(t)=ssvepsnr(Signal, Ff(f), Nh, Fs);

                end
            end
            
            obj.ExtractedFeature=F;
            
        end
        
        % [CCAケース１]
        function obj=featureextractcca(obj)
            global tdc;
            global edc;
            Nf=tdc.NumberOfFrequency;
            Ff=tdc.FlickerFrequency;
            S=obj.PreprocessedData;
            Nh=obj.SNR_NumberOfHarmonics;
            Tw=obj.WindowTime;
            Ti=obj.IntervalTime;
            Fs=edc.SamplingFrequency;
            Y=edc.TestData;
            
            %点滅周波数の特徴量抽出
            for f=1:Nf
                if Ff(f)==0                  
                    continue;
                end
                
                s=string({'f', round(Ff(f))});%次のテーブル名設定
                s=join(s,"");%string文字配列の連結 
                s=char(s);
                [S.(s), Np]=persedata(obj, S.(s), Tw, Ti);
                F.(s)=zeros(Np,1);
                
                for t=1:Np
                     [~,~,F.(s)(t)]=ssvepcca(S.(s)(:, :, t), Ff(f), Nh, Fs);
                end
            end
            
            obj.ExtractedFeature=F;
        end
        
        % [CCAケース２]
        function obj=featureextractcca2(obj)
            %変数代入
            global tdc;
            global edc;
            global ppc;
            Nf=tdc.NumberOfFrequency;
            Ff=tdc.FlickerFrequency;
            Tm=edc.MeasurementTime;
            Lf=edc.FlickerList;
            %S=obj.PreprocessedData;
            Nh=obj.SNR_NumberOfHarmonics;
            Tw=obj.WindowTime;
            Ti=obj.IntervalTime;
            Fs=edc.SamplingFrequency;
            Y=edc.TestData;
            m=ppc.Method;
            
            %点滅周波数の特徴量抽出
            for f=1:Nf
                if Ff(f)==0
                    [S, Np]=persedata(obj, Y, Tw, Ti);                   
                    continue;
                end
                
                s=string({'f', round(Ff(f))});%次のテーブル名設定
                s=join(s,"");%string文字配列の連結 
                s=char(s);
                [S, Np]=persedata(obj, Y, Tw, Ti);
                F.(s)=zeros(Np,1);
                
            end
            
            %点滅周波数データのサンプル点移動
            T=Tw:Ti:Tm;
            Fc=zeros(length(T), 1);
            for t=1:length(T)
                Fc(t)=Lf(floor(T(t)));
            end
            
            %抽出の実行
            for t=1:Np
                %要整理
                for f=1:Nf
                    s=string({'f', round(Ff(f))});%次のテーブル名設定
                    s=join(s,"");%string文字配列の連結 
                    s=char(s);
                    if Fc(t)~=0
                        switch m
                            case 'MEC' 
                                [~, W, ~]=mec(S(:,:,t), Fc(t), Nh, Fs);
                            case 'MCC'
                                [~, W, ~]=mcc(S(:,:,t), Fc(t), Nh, Fs);
                            otherwise
                                W=eye(length(S(1,:,t)));
                        end
                        Signal=S(:,:,t)*W;
                    else
                        Signal=S(:,:,t);
                    end
                    
                    if Ff(f)==0
                        continue;
                    end

                    [~,~,F.(s)(t)]=ssvepcca(Signal, Ff(f), Nh, Fs);

                end
            end
            
            obj.ExtractedFeature=F;
            
        end
        
        function obj=featureextractdft(obj)
            global tdc;
            global edc;
            Nf=tdc.NumberOfFrequency;
            Ff=tdc.FlickerFrequency;
            S=obj.PreprocessedData;
            Nh=obj.SNR_NumberOfHarmonics;
            Tw=obj.WindowTime;
            Ti=obj.IntervalTime;
            Fs=edc.SamplingFrequency;
            Y=edc.TestData;
            
            %点滅周波数の特徴量抽出
            for f=1:Nf
                if Ff(f)==0                  
                    continue;
                end
                
                s=string({'f', round(Ff(f))});%次のテーブル名設定
                s=join(s,"");%string文字配列の連結 
                s=char(s);
                [S.(s), Np]=persedata(obj, S.(s), Tw, Ti);
                F.(s)=zeros(Np,1);
                
                for t=1:Np
                     F.(s)(t)=ssvepdft(S.(s)(:, :, t), Ff(f), Nh, Fs);
                end
            end
            
            obj.ExtractedFeature=F;
        end
        
        %波形分割
        function [Data, Np]=persedata(~, S, Tw, Ti)
            global edc
            
            Tm=edc.MeasurementTime;
            Fs=edc.SamplingFrequency;
            Ns=length(S(1,:));
            
            Np=length(Tw:Ti:Tm);
            Data=zeros(Tw*Fs, Ns, Np);
            try
                for i=0:Np-1
                    SET=i*Fs*Ti;
                    START=SET + 1;
                    END=SET + Tw*Fs;
                    Data(:,:,i+1)=S(START:END, :);
                end
            catch
            end  
        end
        
        %% [パターン認識]
        function obj=decidepatern(obj)
            global tdc;
            F=obj.ExtractedFeature;
            Ff=tdc.FlickerFrequency;
            Nf=tdc.NumberOfFrequency;
            
            %０を除く周波数の算出
            if obj.ZeroFrequencyFlag==1
                A=zeros(length(Ff)-1, 1);
                n=0;
                for f=1:Nf
                    if Ff(f)==0
                        continue;
                    end
                    n=n+1;
                    A(n)=Ff(f);
                end
                clear Ff
                Ff=A;
                Nf=Nf-1;
                obj.ClassList=Ff;
            end
            
            %構造体から行列への変換
            F=struct2cell(F);
            F=cell2mat(F);
            F=reshape(F,[],Nf);
            Np=length(F);
            
            C=zeros(Np, 1);
            for t=1:Np
                [~, C(t)]=max(F(t,:));
                C(t)=Ff(C(t));
            end
            
            obj.Classification=C;
            
            
        end
        
        %正答率のチェック
        function [count, rate]=checkcorrectssvep(obj)
            global tdc;
            global edc;
            Lf=edc.FlickerList;
            Tm=tdc.MeasurementTime;
            Tw=obj.WindowTime;
            Ti=obj.IntervalTime;
            C=obj.Classification;
            
            T=Tw:Ti:Tm;
            
            Fc=zeros(length(T), 1);
            for t=1:length(T)
                Fc(t)=Lf(floor(T(t)));
            end
            
            count=0;
            z=0;
            for t=1:length(T)
                if Fc(t)==0
                    z=z+1;
                    continue;
                end
                if C(t)==Fc(t)
                    count=1+count;
                end
            end
            
            rate=100*(count/(length(T)-z));
            
        end
        
        %% [メイン]
        
        function obj = operate(obj)
            %METHOD1 このメソッドの概要をここに記述
            %   詳細説明をここに記述
            
            obj=preprocess(obj);
            switch obj.ExtractFeatureModeIs
                case 1
                    obj=featureextraction(obj);
                case 2
                    obj=featureextraction2(obj);
                case 3
                    obj=featureextractcca(obj);
                case 4
                    obj=featureextractcca2(obj);
                case 5
                    obj=featureextractdft(obj);
            end
            
            obj=decidepatern(obj);
            
            
            
        end
    end
end

