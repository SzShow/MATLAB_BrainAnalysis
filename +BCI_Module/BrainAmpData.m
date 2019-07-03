classdef BrainAmpData < BCI_Module.ExperimentData
    %UNTITLED2 ���̃N���X�̊T�v�������ɋL�q
    %   �ڍא����������ɋL�q
    
    properties
    end
    
    methods (Access = public)
        %BrainAmp�f�[�^�̃t�H�[�}�b�g���킹
        function o=ExpandEEG(obj)
           
            %EEG�t�@�C���쐬
            o=obj.LoadBrainampFile();
            
            %�g�`����
            o=obj.RemoveRedundantData(o);
            
            %�g���K�̊m��
            o=obj.ExtractTrigger(o);
            
            %���x���̍쐬
            o=obj.MakeRabelData(o);
            
        end
    end
    
    methods (Access = protected)
        function o=LoadBrainampFile(obj)
            o=BCI_Module.EEG;
            load(obj.File);
            o.Signal=eeg';   %���̎��_�ł̓g���K�ƕ����Ė������ɒ���
            o.WavePos=1;    %��ŗ񋓑̂ɕύX
            o.SamplingFreq=obj.SamplingFreq;    
        end
        
        function o=RemoveRedundantData(obj, i)
            %���[�J���ϐ�����
            o=i;
            S=i.Signal;
            Fs=i.SamplingFreq;
            Ns=size(S,1);
            Ne=i.ChanelNum;
            Tm=obj.MeasureTime;
            Offset=obj.StartOffset;
            
            %�g���K�T��
            for t=1:Ns
                if S(t, Ne)==1
                    trg=t;
                    break;
                end
            end
            
            %�J�n�ʒu�̌���
            start=trg-Offset*Fs;
            
            %�؂�o���J�n
            o.Signal=S(start:start+(Tm*Fs)-1,:);
            
        end
        
        function o=ExtractTrigger(obj, i)
            %���[�J���ϐ�����
            o=i;
            Ne=i.ChanelNum;
            
            %�g���K����
            o.Signal=i.Signal(:, 1:Ne-1);
            o.Trigger=i.Signal(:, Ne);
            
        end
        
        function o=MakeRabelData(obj, i)
            %���[�J���ϐ�����
            o=i;
            n=1;
            T=i.Trigger;
            o.Rabel=zeros(size(i.Trigger));
            Ns=length(i.Trigger);
            load(obj.TriggerTable);
            Fs=i.SamplingFreq;
            
            %���x�����ւ̕ϊ�
            for t=1:Ns
                if T(t)==1
                    if TriggerTable(n, 3)~=0
                        %�L�^�J�n���Ԃ̒x��
                        delay=Fs*TriggerTable(n, 2);
                        %�_�Ōp������
                        sus=(Fs*TriggerTable(n, 3))-1;
                        %���x���f�[�^����
                        o.Rabel(t+delay : t+delay+sus)=...
                            TriggerTable(n, 1);
                    end
                    n=n+1;
                end
                %�I���̍��}���o���烋�[�v������
                if TriggerTable(n,1)==-2
                    break;
                end
            end
            
        end
        
    end 
    
    
end

