classdef (Abstract) ExperimentData
    %ExprerimentData 実験データ．クラス継承より様々なデータに対応
    %   詳細説明をここに記述
    
    
    properties (SetAccess=public)
        File    %対応ファイル
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

