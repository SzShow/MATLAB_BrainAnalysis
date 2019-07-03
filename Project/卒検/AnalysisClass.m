classdef AnalysisClass
    %UNTITLED このクラスの概要をここに記述
    %   詳細説明をここに記述
    
    properties
        %I:解析条件
        Method
        Tw
        Nw
        ZeroP
        
        TRSpan
        TRRepeat
        
        SNRFrequency
        SNRNh
        StasticMode
        
        FrequencySpan
        
        R
        
        T1
        T2
        T3
        T4
        
        AnalysisTime
        
        DetectionMode
        SSVEPFrequency
        thr
        Combination
        
        SNR
        
        NoiseNh
        WhitenFilter
        Vw
        
    end
    properties(Dependent)

    end
    
    methods
        %%
        function [ Noise, e ]=investigatenoise(obj, E, C, p)
            if E.Fp(p)==0
                tmp=C.S;
            else
                X=zeros(E.Nw, 2*obj.NoiseNh);
                for k=1:obj.NoiseNh
                    X(:,2*(k-1)+1)=sin(2*pi*k*E.Fp(p)*(1/E.Fs:1/E.Fs:E.Tw));
                    X(:,2*(k-1)+2)=cos(2*pi*k*E.Fp(p)*(1/E.Fs:1/E.Fs:E.Tw));
                end

                tmp=C.S-(X*inv(X'*X)*(X'*C.S));                
            end
            
            if obj.WhitenFilter==1
                ARp=15;
                [~,e]=aryule(tmp(:,1),ARp);
            end
            
            Noise=tmp(:, 1);
        end
        
        %%
        function [ obj ]=operate2(obj, E, C, V)
            tic
            
            switch obj.Method
                case 3
                    obj.R=zeros(E.Nw, E.Np);
                    obj.Vw=zeros(E.Np, 1);
            end
            
            for p=1:E.Np
                C=C.prepro(E, p);   
                switch obj.Method
                    case 1
                        TASK=zeros(obj.Nw, C.Ns);
                        REST=zeros(obj.Nw, C.Ns);

                        for x=1:C.Ns
                            for n=1:TRRepeat
                               %TASK
                                tmp=C.S(E.Fs*TRSpan*(2*n-2)+(1:E.Fs*TRSpan),x);       %x番目のモンタージュから点滅時の波形のみを切り出す
                                tmp=tmp - mean(tmp);                            %直流成分の除去
                                tmp=tmp .* hamming(length(tmp));                %ハミング窓をかける
                                TASK(:,x)=TASK(:,x)+abs(fft(tmp,ZeroP)).^2;       %fftしたデータの絶対値の二乗をTASKへ保存

                                %非点滅時データの処理
                                tmp=C.S(E.Fs*TRSpan*(2*n-1)+(1:E.Fs*TRSpan),x);       %x番目のモンタージュから点滅時の波形のみを切り出す
                                tmp=tmp - mean(tmp);                            %直流成分の除去
                                tmp=tmp .* hamming(length(tmp));                %ハミング窓をかける
                                REST(:,x)=REST(:,x)+abs(fft(tmp,ZeroP)).^2;       %fftしたデータの絶対値の二乗をTASKへ保存
                            end

                            TASK(:,x)=TASK(:,x)./TRRepeat;
                            REST(:,x)=REST(:,x)./TRRepeat;

                            figure('Name','FFT')
                            hold on
                            subplot(floor(C.Ns/2)+1,2)
                            stem(spec.f,TASK(:,x));xlim(Frange);%ylim([0,1e7])
                            hold on
                            stem(spec.f,REST(:,x));xlim(Frange);%ylim([0,1e7])
                            legend('TASK','REST')
                            set(gca,'FontSize',20)
                            str={'All Electrodes Average'};
                            title(char(str(x)),'FontSize',28)
                            if x==floor((C.Ns/2))*2-1
                                    xlabel('Frequency[Hz]','FontSize',24)
                                    ylabel('Power[μV^2]','FontSize',24)
                                    legend({'TASK','REST'},'FontSize',18)
                            end

                        end
                        
                    case 2
                        
                    case 3
                        [Noise, e]=obj.investigatenoise(E, C, p);
                        obj.R(:, p)=Noise;
                        obj.Vw(p)=e;
                    case 4
                        
                    case 5
                        
                    case 6
                        
                    
                end
            end
            
            V.operate(E, C, obj);
            
        end
        %%
        function [ obj ]=operate(obj, E, C, V)
            
            tic
            
            obj.Tw=1;
            obj.Nw=obj.Tw*E.Fs;
            TSlide=0.5;
            Frange=[2 20];
            
            %スペクトルの周波数プロットの位置
            spec.f = E.Fs*(0:(obj.Nw*obj.ZeroP)-1)/(obj.Nw*obj.ZeroP);
            %スペクトルの時間プロットの位置
            spec.t = obj.Tw/2:TSlide:(E.Nt/E.Fs)-obj.Tw/2;
            %スペクトルの強さを示す行列
%            spec.dat = zeros(length(spec.t), length(spec.f),C.Ns)*NaN;
            
            switch obj.Method
                case 1

                    
                %2.SSVEP_SNR
                case 2  
                    %SNRの計算
                    SNRData=zeros(E.Np, 1);
                    SNRTime=E.T;
                    for a=1:E.Np
                        t=ceil(a*E.Ti);
                        C.f=E.Stimulus(t-E.To);
                        if C.f>0
                            [C, Signal]=C.prepro(E, a);
                        end
                        [~, SNRData(a)]=CulclateSSVEPSNR(Signal, E.Stimulus(t-E.To), obj.SNRNh, E.Fs, E.Ts, E);
                        clear C.S
                    end
                    
                    %グラフの表示
                    figure('Name','SNR');
                    hold on;
                    stem(E.T,SNRData);
%                     h1=stem(60:0.5:69.5,SNRData(121:140));%60s~70s
%                     h1.Color='red';h1.MarkerSize=10;h1.MarkerFaceColor='red';
%                     h2=stem(80:0.5:89.5,SNRData(161:180));%80s~90s
%                     h2.Color='red';h2.MarkerSize=10;h2.MarkerFaceColor='red';
%                     h3=stem(100:0.5:109.5,SNRData(201:220));%100s~110s
%                     h3.Color='red';h3.MarkerSize=10;h3.MarkerFaceColor='red';
                    ylim([0 100]);
                    set(gca,'FontSize',20)
                    str=string({C.MethodName, '_', E.Subject, obj.SNRFrequency, 'Hz'});
                    title(char(str),'FontSize',28)
                    xlabel('Time[s]','FontSize',24)
                    ylabel('SNR[dB]','FontSize',24)
                    obj.SNR.Time=SNRTime;
                    obj.SNR.Data=SNRData;
                    
                    [STime, NonSTime, h, p, STimeData NonSTimeData]=CategolizeData(SNRData);
                    obj.T1=struct2table(STime);
                    obj.T2=struct2table(NonSTime);
                    obj.T3=struct2table(h);
                    obj.T4=struct2table(p);
                    
%                     figure('Name','STimeData');
%                     histogram(STimeData, 7);
%                     set(gca,'FontSize',20)
%                     str=string({C.Method, '_', E.Subject, obj.SNRFrequency, 'Hz'});
%                     title(char(str),'FontSize',28)
%                     xlabel('SNR[dB][s]','FontSize',24)
%                     %ylabel('','FontSize',24)
%                     
%                     figure('Name','NonSTimeData');
%                     histogram(NonSTimeData, 10);
%                     set(gca,'FontSize',20)
%                     str=string({C.Method, '_', E.Subject, obj.SNRFrequency, 'Hz'});
%                     title(char(str),'FontSize',28)
%                     xlabel('SNR[dB][s]','FontSize',24)
%                     %ylabel('','FontSize',24)
                    
                case 3
                    [Signal, Noise]=snperge(C.S, 15, 2, E.Fs);
                    p.time=(0:E.Nt-1)/E.Fs;
                    
                    subplot(2, 1, 1)
                    plot(p.time, Signal(:, 1))
                    xlabel('Time[s]','FontSize',24)
                    ylabel('Voltage[μV]','FontSize',24)
                    set(gca,'FontSize',24)
                    str='Signal';
                    title(char(str),'FontSize',24)
                    
                    subplot(2, 1, 2)
                    plot(p.time, Noise(:, 1))
                    xlabel('Time[s]','FontSize',24)
                    ylabel('Voltage[μV]','FontSize',24)
                    set(gca,'FontSize',24)
                    str='Noise';
                    title(char(str),'FontSize',24)
                    

                case 4
                    FTime=length(obj.FrequencySpan);
                    SNRData=zeros(E.Np, FTime);
                    SNRTime=E.Tw:E.Ti:E.Ts-E.Tw;
                    
                    for a=1:E.Np
                        t=ceil(a*E.Ti);
                        for x=1:FTime
                            C.f=obj.FrequencySpan(x);
                            if C.f==E.Fp(a)
                                [C, Signal]=C.prepro(E, a);
                                [~, SNRData(a, x)]=CulclateSSVEPSNR(Signal, obj.FrequencySpan(x), obj.SNRNh, E.Fs, E.Ts, E);
                            else
                                [~, SNRData(a, x)]=CulclateSSVEPSNR(E.Y(:, :, a), obj.FrequencySpan(x), obj.SNRNh, E.Fs, E.Ts, E);
                            end
                            
                        end
                    end
                    

                    X = repmat(E.T', 1, length(obj.FrequencySpan));           %spect.t3の転移行列（列ベクトル）をspec.f3のデータ数分コピーする
                    Y = repmat(obj.FrequencySpan,  length(E.T), 1);           %spect.f3をspec.t3のデータ数分コピーする
                    Z = SNRData;
                    
                    figure('Name','TimeSNR');
                    pcolor(X, Y, Z)
                    colormap(jet)
                    c=colorbar;
                    c.Label.String='SNR[dB]';
                    c.Label.FontSize=28;
                    axis tight, shading flat, grid on, axis on
                    caxis([min(Z(:)) max(Z(:))])
                    str=string({C.Method, '_', E.Subject});
                    set(gca,'FontSize',24)
                    title(char(str),'FontSize',32)
                    xlabel('Time[s]','FontSize',28)
                    ylabel('Frequency[Hz]','FontSize',28)
                    
                case 5
                    switch obj.DetectionMode
                        case 1
                            Nf=length(E.Ff);
                            CTime=E.Np;
                            SNRTime=E.Tw:E.Ti:E.Ts-E.Tw;
                            SNRData=zeros(E.Np, Nf);
                            SSVEPFrequency=zeros(CTime, 1);
                            MatchNumber=0;
                            
                            for a=1:E.Np
                                t=ceil(a*E.Ti);
                                for x=1:Nf
                                    %C.f=E.Ff(x);
                                    [C, Signal]=C.prepro(E, a);
                                    [~, SNRData(a, x)]=CulclateSSVEPSNR(Signal, E.Ff(x), obj.SNRNh, E.Fs, E.Ts, E);
                                end
                                clear C.S
                            end
                                
                            for a=1:E.Np
                                [~, I]=max(SNRData(a, :));
                                SSVEPFrequency(a)=E.Ff(I);
                                if SSVEPFrequency(a)==E.Fp(a) && E.Fp(a)~=0
                                    MatchNumber=MatchNumber+1;
                                end
                            end
                            obj.SSVEPFrequency=SSVEPFrequency;
                            
                        case 2
                            Nf=length(E.Ff);
                            CTime=E.Np;
                            SNRTime=E.Tw:E.Ti:E.Ts-E.Tw;
                            SNRData=zeros(E.Np, Nf);
                            SSVEPFrequency=zeros(CTime, 1);
                            MatchNumber=0;

                            for a=1:E.Np
                                t=ceil(a*E.Ti);
                                for x=1:Nf
                                    %C.f=E.Ff(x);
                                    [C, Signal]=C.prepro(E, a);
                                    [~, SNRData(a, x)]=CulclateSSVEPSNR(Signal, E.Ff(x), obj.SNRNh, E.Fs, E.Ts, E);
                                end
                                clear C.S
                            end
                            
                            for a=1:E.Np
                                [M, I]=max(SNRData(a, :));
                                if M>obj.thr*mean(SNRData(a, :))
                                    SSVEPFrequency(a)=E.Ff(I);
                                else
                                    SSVEPFrequency(a)=0;
                                    
                                end
                            end
                            obj.SSVEPFrequency=SSVEPFrequency;
                            
                        case 4
                            Nf=length(E.Ff);
                            CTime=E.Np;
                            CCAData=zeros(E.Np, Nf);
                            SNRTime=E.Tw:E.Ti:E.Ts-E.Tw;
                            SSVEPFrequency=zeros(E.Np, 1);
                            MatchNumber=0;
                            
                            for a=1:E.Np
                                for i=1:Nf
                                    [C, Signal]=C.prepro(E, a);
                                    [~, CCAData(a,i)]=ssvepcca(Signal, E.Ff(i), obj.SNRNh, E.Fs, E.Ts, E);
                                end
                            end
                            for a=1:E.Np
                                [~, I]=max(CCAData(a, :));
                                SSVEPFrequency(a)=E.Ff(I);
                                if SSVEPFrequency(a)==E.Fp(a) & E.Fp(a)~=0
                                    MatchNumber=MatchNumber+1;
                                end
                            end
                            obj.SSVEPFrequency=SSVEPFrequency;
                    end
                            
                            
                    figure('Name','SNR');
                    hold on;
                    scatter(E.T,SSVEPFrequency);
%                     h1=scatter(60:0.5:69.5,SSVEPFrequency(119:138));%60s~70s
%                     h1.MarkerFaceColor='red';
%                     h2=scatter(80:0.5:89.5,SSVEPFrequency(159:178));%80s~90s
%                     h2.MarkerFaceColor='red';
%                     h3=scatter(100:0.5:109.5,SSVEPFrequency(199:218));%100s~110s
%                     h3.MarkerFaceColor='red';
                    %ylim([0 100]);
                    set(gca,'FontSize',20)
                    str=string({C.MethodName, '_', E.Subject, obj.SNRFrequency, 'Hz'});
                    title(char(str),'FontSize',28)
                    xlabel('Time[s]','FontSize',24)
                    ylabel('Frequency','FontSize',24)
                    

            end
            obj.AnalysisTime=toc;
        end
    end
end

function [SNRTime, SNRData]=CulclateSSVEPSNR(S, f, Nh, Fs, Ts, E)
    Slide=E.Ti;
    Tw=E.Tw;
    CTimes=((Ts-Tw)/Slide)+1;
    SNRTime=zeros(CTimes,1);
    Np=length(S(1, 1, :));
%     SNRData=zeros(Np,1);
    n=0;
    
    n=n+1;
    tmp=S;
    if f==0
        tmp=0;
    else
        tmp=ssvepsnr(tmp,f,Nh,Fs);
        %tmp=mag2db(tmp);
    end
    SNRData=tmp;
end

function [CCATime, CCAData]=ssvepcca(S, f, Nh, Fs, Ts, E)
    Tw=E.Tw;
    Time=1/Fs:1/Fs:Tw;
    CCATime=zeros(E.Np,1);
    
    Y=zeros(Tw*Fs, 2*Nh);
    for k=1:Nh
        Y(:,2*(k-1)+1)=sin(2*pi*k*f*Time);
        Y(:,2*(k-1)+2)=cos(2*pi*k*f*Time);
    end
    
    n=0;
    tmp=S;
    if f==0
        tmp=0;
    else
        [~,~,tmp]=canoncorr(tmp, Y);
    end
    CCAData=max(tmp);
end

function [STime, NonSTime, h, p, STimeData, NonSTimeData]=CategolizeData(SNRData)
    STimeData=[SNRData(1:20); SNRData(41:60); SNRData(81:100)];
    NonSTimeData=[SNRData(21:40); SNRData(61:80); SNRData(101:117)];
    STime.avr=mean(STimeData);
    STime.var=var(STimeData);
    STime.std=std(STimeData);
    STime.min=min(STimeData);
    STime.max=max(STimeData);
    STime.med=median(STimeData);
    STime.mode=mode(round(STimeData));
    NonSTime.avr=mean(NonSTimeData);
    NonSTime.var=var(NonSTimeData);
    NonSTime.min=min(NonSTimeData);
    NonSTime.max=max(NonSTimeData);
    NonSTime.med=median(NonSTimeData);
    NonSTime.mode=mode(round(NonSTimeData));
    
    pd1=fitdist(STimeData, 'Normal');
    pd2=fitdist(NonSTimeData, 'Normal');
    ci1=paramci(pd1);
    ci2=paramci(pd2);
    
    h.vartest=vartest2(STimeData, NonSTimeData);
    
    if h.vartest==1
        [h.ttest, p.ttest]=ttest2(STimeData, NonSTimeData, 'Vartype', 'unequal');
    end
    if h.vartest==0
        [h.ttest, p.ttest]=ttest2(STimeData, NonSTimeData, 'Vartype', 'equal');
    end
    
    [p.ranksum, h.ranksum]=ranksum(STimeData, NonSTimeData);
end

function [Signal, Noise]=snperge(S, f, Nh, Fs)
    mat_X=zeros(10000,2*Nh);
    Ny=length(S(1,:));
    Nt=length(S);
    
    Signal=zeros(Nt, Ny);
    Noise=zeros(Nt, Ny);
    
    for k=1:Nh
        for t=1:10000
            mat_X(t,(2*k)-1)=sin(2*pi*k*f*(t/Fs));
            mat_X(t,2*k)=cos(2*pi*k*f*(t/Fs));
        end
    end
    for t=0:11
        Signal((1:10000)+t*10000, :)=mat_X*inv(mat_X'*mat_X)*(mat_X'*S((1:10000)+t*10000, :));
        Noise((1:10000)+t*10000, :)=S((1:10000)+t*10000, :)-(mat_X*inv(mat_X'*mat_X)*(mat_X'*S((1:10000)+t*10000, :)));
    end
end
