classdef EEG
    %EEG BCI�ɓ��͂���]�g�̃f�[�^
    %   �ڍא����������ɋL�q
    
    properties
        Signal    %�M��
         %�M���̐�
        WavePos    %�g�`�f�[�^�̈ʒu
        SamplingFreq
        Trigger
        Rabel
        EpochTimeList
		Specification    
		FeatureInfo
    end
    
    
    properties (Dependent)
        ChanelNum
        SamplePerEpoch
        EpochNum
        SignalNum
    end
    
    methods
        
        function val=get.EpochNum(obj)
            val=size(obj.Signal, 3);
        end
        
        function val=get.ChanelNum(obj)
            val=size(obj.Signal, 2);
        end
        
        function val=get.SamplePerEpoch(obj)
            val=length(obj.Signal);
        end

        function val=get.SignalNum(obj)
            val=length(obj.Signal);
        end
        
    end
    
    methods(Access=public)
        function o  = getEEG(obj)
			%myFun - Description
			%
			% Syntax: o = getEEG(obj)
			%
			% Long description

			o=obj.Signal(obj.WavePos, :);
            
		end
		function o = getFeature(obj, feature)
			
		end

		function obj = savefeatureinfo(obj, name, len)
				
				
		end
    end
    
end

