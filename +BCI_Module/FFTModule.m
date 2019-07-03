classdef FFTModule < BCI_Module.ProcessingModule
    %UNTITLED このクラスの概要をここに記述
    %   詳細説明をここに記述
    
    properties
        OutputFreq
    end

    properties(SetAccess=immutable)
        FreqBand
        Window
        SignalRule
    end

    methods (Access=public)
        function obj=FFTModule(f, varargin)
            obj.FreqBand=f;
            if nargin==2
                obj.Window=varargin{1};
            end
        end
    end

    methods (Access=protected)
        function o = operate(obj, i)
            o=i;
            S=i.getEEG();
            Fs=i.SamplingFreq;
            Fb=obj.FreqBand;

            for num = 1:length(S)
                n=2^nextpow2(length(S{num}));
                tmp=fft(obj.setwindow(S{num}), n);
            
                F=Fs*(0:(n/2))/n;
                if obj.OutputFreq==[]
                    obj.OutputFreq=F;
                end
    
                for index=1:(n/2)-1
                    if F(index)>Fb(1)
                        low=index;
                        break
                    end
                end
                for index=low:(n/2)-1
                    if F(index)>Fb(2)
                        high=index;
                        break
                    end
                    if index==(n/2)-1
                        high=index;
                    end
                end
                
                o.Signal{i.WavePos, num}=tmp(low:high, :, :);
            end

        end
    end

end

