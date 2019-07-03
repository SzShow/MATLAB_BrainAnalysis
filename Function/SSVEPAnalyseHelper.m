classdef SSVEPAnalyseHelper
    %UNTITLED ���̃N���X�̊T�v�������ɋL�q
    %   �ڍא����������ɋL�q
    
    properties
        Y
        Ts
        Fs
        Fssvep
        Nh
        Offset
        
        LabelSize
        AxesSize
        Rx
        
        OnSignalTime
        OffSignalTime
        Np
        
        
        S
    end
    
    properties(Dependent)
        T
        Ns
        Ne
    end
    
    properties(Constant)

        Preset_15={ 'P5', 'P3', 'P1', 'Pz', 'P2', ...
                    'P4', 'P6', 'PO7', 'PO3', 'POz', ...
                    'PO4', 'PO8', 'O1', 'Oz', 'O2'};
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
            val = length(obj.Y(:,1))-1;
        end
        
        %% [set]
        
        
        %% [public�F�f�[�^����]
        
        function Data=getbipolar(obj, Data)
            
        end    
        function [Data, Trigger]=cutdata(obj, eeg)
            for t=1:obj.Ns
                if eeg(16, t)==1
                    Trigger1=t;
                    break;
                end
            end
            Start=Trigger1-obj.Offset*obj.Fs;

            Data=eeg(1:obj.Ne, Start:Start+obj.Ns-1)';
            Trigger=eeg(obj.Ne+1,Start:Start+obj.Ns-1)';
        end
        function [Output1, Output2]=addavr(obj, Input)
            Period=obj.OnSignalTime+obj.OffSignalTime;
            
            tmp2=zeros(obj.OnSignalTime*obj.Fs, 1);
            for n=1:obj.Np              %�_�ŏ�Ԃ̃X�y�N�g���̍쐬
                t=(obj.Offset+(n-1)*Period)*obj.Fs;
                tmp1=Input(t:t+obj.OnSignalTime*obj.Fs-1, :);
                tmp2=tmp2+tmp1;
            end
            Output1=tmp2./obj.Np; 
            
            tmp2=zeros(obj.OffSignalTime*obj.Fs, 1);    
            for n=1:obj.Np              %�_�ŏ�Ԃ̃X�y�N�g���̍쐬
                t=(obj.Offset+obj.OffSignalTime+(n-1)*Period)*obj.Fs;
                tmp1=Input(t:t+obj.OffSignalTime*obj.Fs-1, :);
                tmp2=tmp2+tmp1;
            end
            Output2=tmp2./obj.Np;
        end
        function [Output1, Output2]=collectonoff(obj, Input)
            Period=obj.OnSignalTime+obj.OffSignalTime;
            
            tmp=zeros(obj.OnSignalTime*obj.Fs*obj.Np, obj.Ne);
            for n=1:obj.Np              %�_�ŏ�Ԃ̃X�y�N�g���̍쐬
                t=(obj.Offset+(n-1)*Period)*obj.Fs;
                tmp((1:obj.OnSignalTime*obj.Fs)+(n-1)*Period, :)=...
                    Input(t:t+obj.OnSignalTime*obj.Fs-1, :);
            end
            Output1=tmp; 
            
            tmp=zeros(obj.OnSignalTime*obj.Fs*obj.Np, obj.Ne); 
            for n=1:obj.Np              %�_�ŏ�Ԃ̃X�y�N�g���̍쐬
                t=(obj.Offset+obj.OffSignalTime+(n-1)*Period)*obj.Fs;
                tmp((1:obj.OffSignalTime*obj.Fs)+(n-1)*Period, :)=...
                    Input(t:t+obj.OffSignalTime*obj.Fs-1, :);
            end
            Output2=tmp;
        end
        function [Pon, Fon, Poff, Foff]=addavrspec(obj, Input)
            Period=obj.OnSignalTime+obj.OffSignalTime;
            
            for n=1:obj.Np              %�_�ŏ�Ԃ̃X�y�N�g���̍쐬
                t=(obj.Offset+(n-1)*Period)*obj.Fs;
                tmp1=Input(t:t+obj.OnSignalTime*obj.Fs-1, :);
                [P,Fon] = periodogram(tmp1(:, n),hamming(length(tmp1)),...
                    length(tmp1),obj.Fs,'power');
                if n==1
                    Pon=zeros(length(P), 1);
                end
                Pon=Pon+P;
            end
            Pon=Pon./obj.Np; 
            
            for n=1:obj.Np              %�_�ŏ�Ԃ̃X�y�N�g���̍쐬
                t=(obj.Offset+obj.OffSignalTime+(n-1)*Period)*obj.Fs;
                tmp1=Input(t:t+obj.OffSignalTime*obj.Fs-1, :);
                [P,Foff] = periodogram(tmp1(:, n),hamming(length(tmp1)),...
                    length(tmp1),obj.Fs,'power');
                if n==1
                    Poff=zeros(length(P), 1);
                end
                Poff=Poff+P;
            end
            Poff=Poff./obj.Np;
        end
        %�G�|�b�N����
        function [Output, EpochNum]=divepoch(obj, Input, Etime)
            
            %���̓f�[�^�̒������o
            [Tlen, ChanelNum]=size(Input);
            %�G�|�b�N�̐����v�Z
            EpochNum=floor(Tlen/(Etime*obj.Fs));
            %�o�͂̃T�C�Y���v�Z
            Output=zeros(Etime*obj.Fs, ChanelNum, EpochNum);
            
            %�G�|�b�N�����̊J�n
            for e=1:EpochNum
                %�؂���̃X�^�[�g�ʒu��ݒ�
                st=(e-1)*Etime*obj.Fs;
                %e�Ԗڂ̃G�|�b�N�ɐ؂������f�[�^����
                Output(:,:,e)=Input(st+1:st+Etime*obj.Fs, :);
            end
        end
        
        %% [�O����]
        %�G�|�b�N�������ꂽ�f�[�^�ɑ΂���O����
        function [Output]=preproepochs(obj, Epochs, Method, Nh)
            %���͂̃T�C�Y���ȗ���
            [TimeNum, ChaNum, EpochNum]=size(Epochs);
            
            switch Method
                case 'CCA'
                    %CCA�̉��̌�
                    CCANum=min(ChaNum, 2*Nh);
                    
                    %�o�̓T�C�Y�̊m��
                    Output.A=zeros(ChaNum, CCANum, EpochNum);
                    Output.B=zeros(2*Nh, CCANum, EpochNum);
                    Output.r=zeros(1, ChaNum, EpochNum);
                    Output.U=zeros(TimeNum, CCANum, EpochNum);
                    Output.V=zeros(TimeNum, CCANum, EpochNum);
                    
                    %�O�����̎��s
                    for n=1:EpochNum
                        [A,B,r,U,V]=obj.cca(Epochs(:,:,n));
                        Output.A(:,:,n)=A;
                        Output.B(:,:,n)=B;
                        Output.r(:,:,n)=r;
                        Output.U(:,:,n)=U;
                        Output.V(:,:,n)=V;
                    end
            end
            

        end
        
        function [S, V, e, Ns]=mec(obj, Y)
            [S, V, e]=mec(Y, obj.Fssvep, obj.Nh, obj.Fs);
            Ns=length(S(1, :));
        end
        function [S, V, e, Ns]=mcc(obj, Y)
            [S, V, e]=mcc(Y, obj.Fssvep, obj.Nh, obj.Fs);
            Ns=length(S(1, :));
        end
        function [A, B, r, U, V, Ns]=cca(obj, Y)
            [A, B, r, U, V]=ssvepcca(Y, obj.Fssvep, obj.Nh, obj.Fs);
            Ns=length(U(1, :));
        end
        
        %% [�����ʒ��o]
        
        %% [public�F�f�[�^�}��]
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
                    ylabel('Voltage[��V]','FontSize',obj.LabelSize)     
                end
            end

            if length(Trigger)==length(Data)
                subplot(sublength, 2, obj.Ne+1)
                plot(obj.T, Trigger)                %�g���K�[�f�[�^�̕`��
                title('Trigger','FontSize',24) 
                xlabel('Time[s]','FontSize',24)
                set(gca,'FontSize',12)
            end
        end      
        function plotonoffdata(obj, Data, name)
            figure('Name', name)
            
            Time=(1:length(Data))'/obj.Fs;
            
            sublength=ceil(obj.Ne/2);
            for n=1:obj.Ne
                subplot(sublength, 2, n)            
                plot(Time, Data(:, n))            
            %   str=jointcharvar({'Ch.', n});
            %   title(str,'FontSize',24)    
                set(gca,'FontSize',obj.AxesSize)      
                if n==ceil(obj.Ne/2)*2-1        
                    xlabel('frequency[Hz]','FontSize',obj.LabelSize)    
                    ylabel('Voltage[��V]','FontSize',obj.LabelSize)     
                end
            end
        end
        function plotprocesseddata(obj, Data, Ns, name)
            figure('Name', name)
            
            Time=(1:length(Data))'/obj.Fs;
            
            sublength=ceil(Ns/2);
            for n=1:Ns
                subplot(sublength, 2, n)            
                plot(Time, Data(:, n))            
            %   str=jointcharvar({'Ch.', n});
            %   title(str,'FontSize',24)    
                set(gca,'FontSize',obj.AxesSize)      
                if n==ceil(Ns/2)*2-1        
                    xlabel('frequency[Hz]','FontSize',obj.LabelSize)    
                    ylabel('Voltage[��V]','FontSize',obj.LabelSize)     
                end
            end
        end
        function [P, F]=periodogram(obj, Y, Name)
            figure('Name', Name);
            
            N=length(Y(1, :));
            for n=1:N
                subplot(ceil(N/2), 2, n)
                [P,F] = periodogram(Y(:, n),hamming(length(Y)),...
                    length(Y),obj.Fs,'power');
                plot(F, P);
                xlim(obj.Rx);
                set(gca,'FontSize',obj.AxesSize)
            end
        end
        function [TF, Pa, An, Freq, Time]=spectrogram(obj, Y, Tw, Tov)

            
%             figure('Name', Name);
            % ���ԃt�[���G�ϊ�
            [Nx ,Enum]=size(Y);
            win=hamming(Tw*obj.Fs);
            nov=Tov*obj.Fs;
            nff=max(256, 2^nextpow2(Tw*obj.Fs));
            
            Lf=(nff/2)+1;
            Lt=floor(((Nx-nov)/(length(win)-nov)));
            TF=zeros(Lf, Lt, Enum);
            
            for n=1:Enum
                [s, Freq, Time]=spectrogram(Y(:, n), win, ...
                    nov, nff, obj.Fs);
                TF(:,:,n)=s;
            end
            
            %�U���E�ʑ��̌v�Z
            Pa=pow2db(abs(TF).^2);
            An=angle(TF);
            
            Flim=ceil(20/((obj.Fs/2)/(Lf-1)))+1;
            SURFy=repmat(Freq(1:Flim), 1, length(Time));
            SURFx=repmat(Time, Flim, 1);
            SURFpa=Pa(1:Flim, :, :);
            SURFan=An(1:Flim, :, :);
            
            figure()
            for n=1:Enum
                subplot(ceil(Enum/2), 2, n)
                h1=pcolor(SURFx, SURFy, SURFpa(:,:,n));
                set(h1, 'EdgeColor', 'none')
                %set(gca,'FontSize',obj.AxesSize)
            end
            
            figure()
            F15=ceil(15/((obj.Fs/2)/(Lf-1)))+1;
            Angle15=squeeze(SURFan(F15-1, :, :)+SURFan(F15, :, :))./2;
            for n=1:Enum
                subplot(ceil(Enum/2), 2, n)
                plot(Time', Angle15(:, n).*(180/pi))
                %set(gca,'FontSize',obj.AxesSize)
            end
        end
        function [PLOTy]=plv(obj, An, Freq, Time, f)
            F=ceil(f/((obj.Fs/2)/(length(Freq)-1)))+1;
            temp=squeeze(An(F-1, :, :)+An(F, :, :))./2;
            PLOTy=abs(sum(exp(1j*temp*pi), 2)./obj.Ne);
            PLOTx=Time;
            
            figure()
            plot(PLOTx, PLOTy);
        end

        %% [Neural Network�֘A]
        
    end
end

