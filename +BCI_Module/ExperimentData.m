classdef (Abstract) ExperimentData
    %ExprerimentData �����f�[�^�D�N���X�p�����l�X�ȃf�[�^�ɑΉ�
    %   �ڍא����������ɋL�q
    
    
    properties (SetAccess=public)
        File    %�Ή��t�@�C��
        Amp
        Electrodes
        
        SamplingFreq
        BandPass
        Notch
        MeasureTime
        StartOffset=0
        TriggerTable
    end
    
    methods(Abstract)
        output=ExpandEEG(obj)
	end
	
	methods(Access = public, Static)
		function output=formatdata(amp)
			switch amp
				case EBioAmp.BrainAmp
					output = BrainAmpData;
					output.Amp = amp;
				case gUSBAmp
			end
		end
	end
    
end

