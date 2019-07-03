classdef SSVEPAnalyseHelper2
    %UNTITLED このクラスの概要をここに記述
    %   詳細説明をここに記述
    
    properties
        EEG(:, :) double
        Ts(:, 1) single
        Fs(1, 1) single
        Offset(1, 1) single
        Type(1, 1) SSVEPDataType
        
        Win
        
        RecEEG
        Trigger
        
        LabelSize=40;
        AxesSize=24;
        Rx

    end
    
    properties(Dependent)
        T(:, 1) double
        Ns(1, 1) uint64
        Ne(1, 1) uint8
    end
    
    properties(Constant)

    end
    
    
    methods(Access=private)
        %% [private]
        
        
    end
    
    methods
        
        %% [get]
        function val = get.T(obj)
            val=(1:obj.Ts*obj.Fs)'/obj.Fs;
        end
        function val = get.Ns(obj)
            val=obj.Fs*obj.Ts;
        end
        function val = get.Ne(obj)
            val = length(obj.RecEEG(1,:));
        end
        
        %% [set]
        
        
        %% [public：データ操作]
         
        function obj=SSVEPAnalyseHelper2(eeg, TriggerTable, fs, ts, offset)
            [nele, nt]=size(eeg);
            %load('TrrigerTable.mat');
            
            %プロパティ代入
            obj.Fs=fs;
            obj.Ts=ts;
            obj.Offset=offset;
            
            %波形分割
            for t=1:obj.Ns
                if eeg(nele, t)==1
                    Trigger1=t;
                    break;
                end
            end
            Start=Trigger1-obj.Offset*obj.Fs;

            obj.RecEEG=eeg(1:nele-1, Start:Start+obj.Ns-1)';
            trigger=eeg(nele,Start:Start+obj.Ns-1)';
            
            %トリガの作成
            n=1;
            Trigger=zeros(size(trigger));
            for t=1:obj.Ns
                if trigger(t)==1
                    if TriggerTable(n, 3)~=0
                        o=obj.Fs*TriggerTable(n, 2);
                        d=obj.Fs*TriggerTable(n, 3)-1;
                        Trigger(t+o:t+o+d)=TriggerTable(n,1);
                    end
                    
                    n=n+1;
                end
                if TriggerTable(n,1)==-2
                    break;
                end
            end
            obj.Trigger=Trigger;
        end
        %エポック分割
        function [Output, Tepo]=divepoch(obj, Input, Etime, Olap)
            
            %入力データの長さ抽出
            [Tlen, ChanelNum]=size(Input);
            %エポックの数を計算
            EpochNum=floor((Tlen-Etime*obj.Fs)/(Olap*obj.Fs));
            %出力のサイズを計算
            Output=zeros(Etime*obj.Fs, ChanelNum, EpochNum);
            %エポックの終了位置の配列
            Tepo=zeros(EpochNum, 1);
            
            %エポック分割の開始
            for e=1:EpochNum
                %切り取りのスタート位置を設定
                st=(e-1)*Olap*obj.Fs;
                %e番目のエポックに切り取ったデータを代入
                Output(:,:,e)=Input(st+1:st+Etime*obj.Fs, :);
                Tepo(e)=st+Etime*obj.Fs;
            end
        end
        
        function Output=chooseepochs(obj, Input, f, Tepo, trigger)
            [~,~,Nepo]=size(Input);
            tmp=zeros(size(Input));
            Nchosen=0;
            for n=1:Nepo
                if trigger(Tepo(n))==f
                    Nchosen=Nchosen+1;
                    tmp(:,:,Nchosen)=Input(:,:,n);
                end
            end
            
            Output=tmp(:,:,1:Nchosen);
        end
        
        function Output=epochtrigger(obj, Tepo, trigger)
            Output=zeros(length(Tepo), 1);
            for n=1:length(Tepo)
                Output(n)=trigger(Tepo(n));
            end
        end
        
        %% [前処理]
        %エポック分割されたデータに対する前処理
        function [Output]=preproepochs(obj, Epochs, Method, f, Nh)
            %オブジェクトの作成
            Output=CleanedEpoch(f, Method);
            
            %入力のサイズを簡略化
            [TimeNum, ChaNum, EpochNum]=size(Epochs);
            
            switch Method
                case 'CCA'
                    %CCAの解の個数
                    CCANum=min(ChaNum, 2*Nh);
                    
                    %出力サイズの確保
                    Output.Data.A=zeros(ChaNum, CCANum, EpochNum);
                    Output.Data.B=zeros(2*Nh, CCANum, EpochNum);
                    Output.Data.r=zeros(1, CCANum, EpochNum);
                    Output.Data.U=zeros(TimeNum, CCANum, EpochNum);
                    Output.Data.V=zeros(TimeNum, CCANum, EpochNum);
                    
                    %前処理の実行
                    for n=1:EpochNum
                        [A,B,r,U,V]=obj.cca(Epochs(:,:,n), f, Nh);
                        Output.Data.A(:,:,n)=A;
                        Output.Data.B(:,:,n)=B;
                        Output.Data.r(:,:,n)=r;
                        Output.Data.U(:,:,n)=U;
                        Output.Data.V(:,:,n)=V;
                    end
                case 'WCCA'
                    %CCAの解の個数
                    CCANum=min(ChaNum, 2*Nh);
                    
                    %出力サイズの確保
                    Output.Data.A=zeros(ChaNum, CCANum, EpochNum);
                    Output.Data.B=zeros(2*Nh, CCANum, EpochNum);
                    Output.Data.r=zeros(1, CCANum, EpochNum);
                    Output.Data.U=zeros(TimeNum, CCANum, EpochNum);
                    Output.Data.V=zeros(TimeNum, CCANum, EpochNum);
                    
                    %前処理の実行
                    for n=1:EpochNum
                        [A,B,r,U,V]=obj.wcca(Epochs(:,:,n), f, Nh);
                        Output.Data.A(:,:,n)=A;
                        Output.Data.B(:,:,n)=B;
                        Output.Data.r(:,:,n)=r;
                        Output.Data.U(:,:,n)=U;
                        Output.Data.V(:,:,n)=V;
                    end
                case 'MCC'                  
                    %出力サイズの確保
                    Output.Data.S=zeros(TimeNum, ChaNum, EpochNum);
                    Output.Data.V=zeros(ChaNum, ChaNum, EpochNum);
                    Output.Data.e=zeros(ChaNum, 1, EpochNum);
                    
                    %前処理の実行
                    for n=1:EpochNum
                        [S, V, e]=obj.mcc(Epochs(:,:,n), f, Nh);
                        Output.Data.S(:,:,n)=S;
                        Output.Data.V(:,:,n)=V;
                        Output.Data.e(:,:,n)=e;
                    end
                otherwise
                    Output.Data=Epochs;
            end
            

        end
        
        function [S, V, e, Ns]=mec(obj, Y, f, Nh)
            [S, V, e]=mec(Y, f, Nh, obj.Fs);
            Ns=length(S(1, :));
        end
        function [S, V, e, Ns]=mcc(obj, Y, f, Nh)
            [S, V, e]=mcc(Y, f, Nh, obj.Fs);
            Ns=length(S(1, :));
        end
        function [A, B, r, U, V, Ns]=cca(obj, Y, f, Nh)
            [A, B, r, U, V]=ssvepcca(Y, f, Nh, obj.Fs);
            Ns=length(U(1, :));
        end
        function [A, B, r, U, V, Ns]=wcca(obj, Y, f, Nh)
            [A, B, r, U, V]=waveletcca(Y, f, Nh, obj.Fs, obj.Win);
            Ns=length(U(1, :));
        end
        
        %% [特徴量抽出]
        
        %% [public：データ図示]
        function plotrawdata(obj, Data, Trigger, name)
            figure('Name', name)
            
            sublength=ceil((obj.Ne+1)/2);
            for n=1:obj.Ne
                subplot(sublength, 2, n)            
                plot(obj.T, Data(:, n))            
            %   str=jointcharvar({'Ch.', n});
            %   title(str,'FontSize',24)    
                set(gca,'FontSize',obj.AxesSize)      
                if n==ceil(obj.Ne/2)*2-1        
                    xlabel('frequency[Hz]','FontSize',obj.LabelSize)    
                    ylabel('Voltage[μV]','FontSize',obj.LabelSize)     
                end
            end

            if length(Trigger)==length(Data)
                subplot(sublength, 2, obj.Ne+1)
                plot(obj.T, Trigger)                %トリガーデータの描画
                title('Trigger','FontSize',24) 
                xlabel('Time[s]','FontSize',24)
                set(gca,'FontSize',12)
            end
        end     
        
        function ccattest2(obj, p, Trigger)
            Nepo=length(p);
            Nt=length(Trigger);
            
            for n=1:Nepo
                
            end
        end
        
        function doubleperiod(obj, Data1, Data2)
            [pxx1, F]=periodogram(Data1, hamming(length(Data1)),...
                length(Data1), obj.Fs, 'power');
            pxx2=periodogram(Data2, hamming(length(Data2)),...
                length(Data2), obj.Fs, 'power');
            figure()
            subplot(2, 1, 1)
            plot(F, pxx1);
            xlim([5 20]);
            set(gca,'FontSize',obj.AxesSize)
            subplot(2, 1, 2)
            plot(F, pxx2);
            xlim([5 20]);
            set(gca,'FontSize',obj.AxesSize)
            
        end
        
        function C=cossim(obj, v1, v2)
            n1=norm(v1);
            n2=norm(v2);
            C=dot(v1, v2)/(n1*n2);
        end
        
        %% [窓関数]
        function win=gausswin(obj, Length, d)
            Alpha=floor(2*(Length-1)/(2*d*obj.Fs));
            win=gausswin(Length,Alpha);
        end

        %% [Neural Network関連]
        function [C]=trainclassifier(obj, Mehod, varargin)
            C=SSVEPClassifier(Method);
            
            switch Mehod
                case 'CNN'
                    C.training();
                    
            end
            
        end
        
    end
end

