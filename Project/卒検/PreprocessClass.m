classdef PreprocessClass
    %UNTITLED3 ���̃N���X�̊T�v�������ɋL�q
    %   �ڍא����������ɋL�q
    
    properties(Constant)
        
        
        %Bipolar�p�v���Z�b�g
        BipPreset_15={   'P5',   'PO7';
                         'P3',   'PO3';
                         'PO3',  'O1' ;
                         'P3',   'O1';
                         'P3',   'P1' ;
                         'P1',   'Pz' ;
                         'Pz',   'POz' ;
                         'Pz',   'Oz' ;
                         'POz',   'Oz' ;
                         'Pz',   'P2' ;
                         'P2',   'P4' ;
                         'P4',   'PO4' ;
                         'P4',   'O2' ;
                         'PO4',   'O2' ;
                         'P6',   'PO8' ;};
        
        %Laplacian�p�v���Z�b�g
        LapPreset_15={  'PO3',   'P3',   'POz',   'O1',   'PO7';
                        'POz',   'Pz',   'PO4',   'Oz',   'PO3';
                        'PO4',   'P4',   'PO8',   'O2',   'POz';};
    end
    
    properties
        Method  %�O�����@
        SpatialFilter       %��ԃt�B���^
        EigenValue          %�ŗL�l
        DoLater
        
        %MEC, MCC�p�p�����[�^
        
        MECNh  %�����g�̐�
    end
    
    methods
        %% [�R���X�g���N�^�[]
        %�C���X�^���X�����Ɠ����Ɏ����p�����[�^����
        function [obj]=PreprocessClass(TDC)
%            obj.ExperimentProperties=get(TDC, 'default');
        global tdc;
        tdc=TDC;
            
        end
        
        %% [MEC�t�B���^�[�̐݌v]
        function [obj]=calibrate(obj)
            global tdc;
            Dt=tdc.TrainingData;
            Ff=tdc.FlickerFrequency;
            Fs=tdc.SamplingFrequency;
            Ne=tdc.NumberOfElectrode;
            
            for f=1:tdc.NumberOfFrequency
                if Ff(f)==0
                    continue;
                end
                
                s=string({'f', round(Ff(f))});%���̃e�[�u�����ݒ�
                s=join(s,"");%string�����z��̘A��
                
                switch obj.Method
                    case 'MEC'
                        [~, W, e]=mec(Dt.(char(s)), Ff(f), obj.MECNh, Fs);
                    case 'MCC'
                        [~, W, e]=mcc(Dt.(char(s)), Ff(f), obj.MECNh, Fs);
                    otherwise
                        W=eye(Ne);
                        e=ones(Ne);
                end
                
                

                Mf.(char(s))=W;
                Ve.(char(s))=e;
                
            end
            
            obj.SpatialFilter=Mf;
            obj.EigenValue=Ve;
            
        end
        

        
    end
    
end

