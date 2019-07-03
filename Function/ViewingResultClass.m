classdef ViewingResultClass
    %UNTITLED2 ���̃N���X�̊T�v�������ɋL�q
    %   �ڍא����������ɋL�q
    
    properties
        ActiveViewWave;
        FlickeModeVisibleIs;
        StasticalCalclateMode
        
        ComparedFrequency
        
        StasticOutput;
    end
    
    methods
        function obj = ViewingResultClass(TDC, PPC, EDC, DPC)
            %UNTITLED2 ���̃N���X�̃C���X�^���X���쐬
            %   �ڍא����������ɋL�q
            global tdc;
            global ppc;
            global edc;
            global dpc;
            tdc=TDC;
            ppc=PPC;
            edc=EDC;
            dpc=DPC;
        end
        %% [�g�`�̕\��]
        function obj = viewwave(obj)
            %�ϐ��ݒ�
            global edc;
            global ppc;
            Fs=edc.SamplingFrequency;
            Tm=edc.MeasurementTime;
            Y=edc.TestData;
            PREPROCESS=ppc.Method;
            SUBJECT=edc.Subject;
            
            %���ԃv���b�g�̐���
            Td=1/Fs;
            T=Td:Td:Tm;
            
            %�e�X�g�f�[�^�̕\��
            if obj.ActiveViewWave(2)==1
                figure('Name', 'TestDataWave');
                plot(T, Y);
                xlabel('Time[s]','FontSize',24)
                ylabel('Voltage[��V]','FontSize',24)
%                 str=string({PREPROCESS, "  ", SUBJECT});
%                 str=join(str, "");
%                 str=char(str);
%                 title(str,'FontSize',28)            
                set(gca,'FontSize',24)
            end

        end
        
        %% [�����ʂ̕\��]
        function obj=viewfeature(obj)
            %�ϐ��ݒ�
            global edc;
            global ppc;
            global dpc;
            Tm=edc.MeasurementTime;
            PREPROCESS=ppc.Method;
            SUBJECT=edc.Subject;
            Tw=dpc.WindowTime;
            Ti=dpc.IntervalTime;
            F=dpc.ExtractedFeature;
            Lc=dpc.ClassList;
            
            %���ԃv���b�g�̐���
            T=Tw:Ti:Tm;
            
            %�����ʂ̕\��
            figure('Name', 'Feature');
            hold on
            
            for f=1:length(Lc)
                s=string({'f', round(Lc(f))});
                s=join(s, "");
                s=char(s);
                stairs(T, F.(s));
            end
            legend;

            xlabel('Time[s]','FontSize',24)
            ylabel('SNR[dB]','FontSize',24)
            str=string({PREPROCESS});
            str=join(str, "");
            str=char(str);
            title(str,'FontSize',28)            
            set(gca,'FontSize',24)
            
        end
        
        %% [�N���X���ތ��ʂ̕\��]
        
        function obj=viewclassification(obj)
            %�ϐ����
            global dpc;
            global edc;
            global tdc;
            Lf=edc.FlickerList;
            Tm=edc.MeasurementTime;
            C=dpc.Classification;
            Tw=dpc.WindowTime;
            Ti=dpc.IntervalTime;
            
            figure('Name', 'Feature');
            hold on
            
            T=Tw:Ti:Tm;
            scatter(T, C);
            
            

            xlabel('Time[s]','FontSize',24)
            ylabel('CLASS','FontSize',24)
%             str=string({PREPROCESS, "  ", SUBJECT});
%             str=join(str, "");
%             str=char(str);
%             title(str,'FontSize',28)            
            set(gca,'FontSize',24)
            
            if obj.FlickeModeVisibleIs==1
                Fc=zeros(length(T), 1);
                for t=1:length(T)
                    Fc(t)=Lf(floor(T(t)));
                end
                
                hold on
                stairs(T, Fc);
            end
            
            legend({'RESULT', 'CORRECT'}, 'FontSize', 30);
        end
        
        function obj=classificationstatistic(obj)
            
        end
        
        %% [���v�ʂ̌v�Z]
        
        function obj=calclatestastics(obj)
            global edc
            global dpc
            f=obj.ComparedFrequency;
            
            %�ϐ����
            switch obj.StasticalCalclateMode
                case 1
                    obj.StasticOutput=VRCCompareHistogram(dpc, edc, f);
            end
        end
        
        
        %% [���C���֐�]
        function obj = operate(obj)
            %METHOD1 ���̃��\�b�h�̊T�v�������ɋL�q
            %   �ڍא����������ɋL�q
            
            obj=viewwave(obj);
            obj=viewfeature(obj);
            obj=viewclassification(obj);
            obj=calclatestastics(obj);
        end
    end
end

