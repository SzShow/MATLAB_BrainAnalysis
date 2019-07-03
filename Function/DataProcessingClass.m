classdef DataProcessingClass
    %UNTITLED ���̃N���X�̊T�v�������ɋL�q
    %   �ڍא����������ɋL�q
    
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
        %% [�R���X�g���N�^�[]
        function obj = DataProcessingClass(TDC, PPC, EDC)
            %UNTITLED ���̃N���X�̃C���X�^���X���쐬
            %   �ڍא����������ɋL�q
            global tdc;
            global ppc;
            global edc;
            tdc=TDC;
            ppc=PPC;
            edc=EDC;
        end
        
        %% [�O����]
        function obj=preprocess(obj)
            %�ϐ����
            %W:     ��ԃt�B���^
            %Ff:    �������ɒ񎦂����_�Ŏ��g��
            %Nf:    �_�Ŏ��g���̐�
            %Y:     �e�X�g�f�[�^
            global ppc;
            global tdc;
            global edc;
            W=ppc.SpatialFilter;
            Ff=tdc.FlickerFrequency;
            Nf=tdc.NumberOfFrequency;
            Y=edc.TestData;
            
            %�O�������s
            for f=1:Nf
                %�_�Ŏ��g��0�̓X�L�b�v
                if Ff(f)==0
                    obj.ZeroFrequencyFlag=1;
                    continue;
                end
                s=string({'f', round(Ff(f))});%���̃e�[�u�����ݒ�
                s=join(s,"");%string�����z��̘A�� 
                s=char(s);
                S.(s)=Y*W.(s);
            end
            
            obj.PreprocessedData=S;

        end
        
        %% [�����ʒ��o]
        
        %�@[�P�[�X�P]
        function obj=featureextraction(obj)
            %�ϐ����
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
            
            %�_�Ŏ��g���̓����ʒ��o
            for f=1:Nf
                if Ff(f)==0                  
                    continue;
                end
                
                s=string({'f', round(Ff(f))});%���̃e�[�u�����ݒ�
                s=join(s,"");%string�����z��̘A�� 
                s=char(s);
                [S.(s), Np]=persedata(obj, S.(s), Tw, Ti);
                F.(s)=zeros(Np,1);
                
                for t=1:Np
                     F.(s)(t)=ssvepsnr(S.(s)(:, :, t), Ff(f), Nh, Fs);
                end
            end
            
            obj.ExtractedFeature=F;
            
        end
        
        % [�P�[�X�Q]
        function obj=featureextraction2(obj)
            %�ϐ����
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
            
            %�_�Ŏ��g���̓����ʒ��o
            for f=1:Nf
                if Ff(f)==0
                    [S, Np]=persedata(obj, Y, Tw, Ti);                   
                    continue;
                end
                
                s=string({'f', round(Ff(f))});%���̃e�[�u�����ݒ�
                s=join(s,"");%string�����z��̘A�� 
                s=char(s);
                [S, Np]=persedata(obj, Y, Tw, Ti);
                F.(s)=zeros(Np,1);
                
            end
            
            %�_�Ŏ��g���f�[�^�̃T���v���_�ړ�
            T=Tw:Ti:Tm;
            Fc=zeros(length(T), 1);
            for t=1:length(T)
                Fc(t)=Lf(floor(T(t)));
            end
            
            %���o�̎��s
            for t=1:Np
                %�v����
                for f=1:Nf
                    s=string({'f', round(Ff(f))});%���̃e�[�u�����ݒ�
                    s=join(s,"");%string�����z��̘A�� 
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
        
        % [CCA�P�[�X�P]
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
            
            %�_�Ŏ��g���̓����ʒ��o
            for f=1:Nf
                if Ff(f)==0                  
                    continue;
                end
                
                s=string({'f', round(Ff(f))});%���̃e�[�u�����ݒ�
                s=join(s,"");%string�����z��̘A�� 
                s=char(s);
                [S.(s), Np]=persedata(obj, S.(s), Tw, Ti);
                F.(s)=zeros(Np,1);
                
                for t=1:Np
                     [~,~,F.(s)(t)]=ssvepcca(S.(s)(:, :, t), Ff(f), Nh, Fs);
                end
            end
            
            obj.ExtractedFeature=F;
        end
        
        % [CCA�P�[�X�Q]
        function obj=featureextractcca2(obj)
            %�ϐ����
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
            
            %�_�Ŏ��g���̓����ʒ��o
            for f=1:Nf
                if Ff(f)==0
                    [S, Np]=persedata(obj, Y, Tw, Ti);                   
                    continue;
                end
                
                s=string({'f', round(Ff(f))});%���̃e�[�u�����ݒ�
                s=join(s,"");%string�����z��̘A�� 
                s=char(s);
                [S, Np]=persedata(obj, Y, Tw, Ti);
                F.(s)=zeros(Np,1);
                
            end
            
            %�_�Ŏ��g���f�[�^�̃T���v���_�ړ�
            T=Tw:Ti:Tm;
            Fc=zeros(length(T), 1);
            for t=1:length(T)
                Fc(t)=Lf(floor(T(t)));
            end
            
            %���o�̎��s
            for t=1:Np
                %�v����
                for f=1:Nf
                    s=string({'f', round(Ff(f))});%���̃e�[�u�����ݒ�
                    s=join(s,"");%string�����z��̘A�� 
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
            
            %�_�Ŏ��g���̓����ʒ��o
            for f=1:Nf
                if Ff(f)==0                  
                    continue;
                end
                
                s=string({'f', round(Ff(f))});%���̃e�[�u�����ݒ�
                s=join(s,"");%string�����z��̘A�� 
                s=char(s);
                [S.(s), Np]=persedata(obj, S.(s), Tw, Ti);
                F.(s)=zeros(Np,1);
                
                for t=1:Np
                     F.(s)(t)=ssvepdft(S.(s)(:, :, t), Ff(f), Nh, Fs);
                end
            end
            
            obj.ExtractedFeature=F;
        end
        
        %�g�`����
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
        
        %% [�p�^�[���F��]
        function obj=decidepatern(obj)
            global tdc;
            F=obj.ExtractedFeature;
            Ff=tdc.FlickerFrequency;
            Nf=tdc.NumberOfFrequency;
            
            %�O���������g���̎Z�o
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
            
            %�\���̂���s��ւ̕ϊ�
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
        
        %�������̃`�F�b�N
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
        
        %% [���C��]
        
        function obj = operate(obj)
            %METHOD1 ���̃��\�b�h�̊T�v�������ɋL�q
            %   �ڍא����������ɋL�q
            
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

