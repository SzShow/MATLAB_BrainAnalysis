classdef EEG
    %EEG BCIに入力する脳波のデータ
    %   詳細説明をここに記述
    
    properties
        Signal    %信号
         %信号の数
        WavePos    %波形データの位置
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

