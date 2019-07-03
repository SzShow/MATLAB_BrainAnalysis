classdef ViewingResultClass
    %UNTITLED2 このクラスの概要をここに記述
    %   詳細説明をここに記述
    
    properties
        ActiveViewWave;
        FlickeModeVisibleIs;
        StasticalCalclateMode
        
        ComparedFrequency
        
        StasticOutput;
    end
    
    methods
        function obj = ViewingResultClass(TDC, PPC, EDC, DPC)
            %UNTITLED2 このクラスのインスタンスを作成
            %   詳細説明をここに記述
            global tdc;
            global ppc;
            global edc;
            global dpc;
            tdc=TDC;
            ppc=PPC;
            edc=EDC;
            dpc=DPC;
        end
        %% [波形の表示]
        function obj = viewwave(obj)
            %変数設定
            global edc;
            global ppc;
            Fs=edc.SamplingFrequency;
            Tm=edc.MeasurementTime;
            Y=edc.TestData;
            PREPROCESS=ppc.Method;
            SUBJECT=edc.Subject;
            
            %時間プロットの生成
            Td=1/Fs;
            T=Td:Td:Tm;
            
            %テストデータの表示
            if obj.ActiveViewWave(2)==1
                figure('Name', 'TestDataWave');
                plot(T, Y);
                xlabel('Time[s]','FontSize',24)
                ylabel('Voltage[μV]','FontSize',24)
%                 str=string({PREPROCESS, "  ", SUBJECT});
%                 str=join(str, "");
%                 str=char(str);
%                 title(str,'FontSize',28)            
                set(gca,'FontSize',24)
            end

        end
        
        %% [特徴量の表示]
        function obj=viewfeature(obj)
            %変数設定
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
            
            %時間プロットの生成
            T=Tw:Ti:Tm;
            
            %特徴量の表示
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
        
        %% [クラス分類結果の表示]
        
        function obj=viewclassification(obj)
            %変数代入
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
        
        %% [統計量の計算]
        
        function obj=calclatestastics(obj)
            global edc
            global dpc
            f=obj.ComparedFrequency;
            
            %変数代入
            switch obj.StasticalCalclateMode
                case 1
                    obj.StasticOutput=VRCCompareHistogram(dpc, edc, f);
            end
        end
        
        
        %% [メイン関数]
        function obj = operate(obj)
            %METHOD1 このメソッドの概要をここに記述
            %   詳細説明をここに記述
            
            obj=viewwave(obj);
            obj=viewfeature(obj);
            obj=viewclassification(obj);
            obj=calclatestastics(obj);
        end
    end
end

