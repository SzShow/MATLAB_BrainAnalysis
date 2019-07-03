classdef LDAMod < BCI_Module.BCIOutputModule
    %UNTITLED2 このクラスの概要をここに記述
    %   詳細説明をここに記述
    
	properties
		isEnableClusttering %クラスタリングによる学習データ選択を使うか
		Feature
        Classifier%分類器
    end
    
	methods
	
		function obj = LDAMod(clusten, feature)
		obj.isEnableClusttering = clusten;
		obj.Feature = feature;
			
		end

        function obj=train(obj, input)
            X=obj.JointFeature(input);	%訓練データのフォーマッティング
			Y=obj.epochtrigger(input);	%正解ラベルのフォーマッティング
			
			if obj.isEnableClusttering == true
				F = obj.ExtractFeature(X,...
					input{1}.FeatureInfo, obj.Feature, input{1}.SignalNum);
				Y = obj.Clustering(F, Y);
			end

            obj.Classifier=fitcdiscr(X,Y);	%学習の実行開始
        end
        
        function [o,Y]=test(obj, i)
            X=obj.JointFeature(i);	%テストデータのフォーマッティング
            Y=obj.epochtrigger(i);	%テストデータのフォーマッティング
            o=predict(obj.Classifier, X);	%コマンド出力の実行開始
        end
        
	end
	
	methods (Access = protected, Static)

		function output = ExtractFeature(X, info, feature, signalnum)
			%サイズの計算と出力の確保
			outputSize = 0;
			for index = 1:size(info, 1)
				if info.FeatureName(index) == feature
					outputSize = outputSize + info.FeatureLength(index);
				end
			end
			output = zeros(size(X, 1), outputSize*signalnum);

			%特徴量の入力
			oneFilterSize = size(X, 2)/signalnum;
			Nout=1;
			for mul = 0: signalnum-1
				Nx=1;
				for index = 1:size(info, 1)
					if info.FeatureName(index) == feature
						offset = oneFilterSize*mul;
						output(:, Nout:Nout+...
							(info.FeatureLength(index)-1)) = ...
							X(:, offset+Nx:offset+Nx+...
							(info.FeatureLength(index)-1));
						Nout = Nout + info.FeatureLength(index);
					end
					Nx = Nx + info.FeatureLength(index);
				end
			end

			
		end
		
		%K-Mean法によるクラスタリングに基づいた
		%学習データの分類
		function altrabel = Clustering(X,Y)
			import BCI_Module.LDAMod
			
			[idx, C] = kmeans(X, 2);
			winner = 1;

			if(C(1, :) < C(2, :))
				winner = 2;
			end
			altrabel = LDAMod.changerabel(Y, idx, winner);
			
		end

		function output = changerabel(Y, idx, winner)
			for index = 1:length(idx)
				if idx(index) ~= winner
					Y(index) = 0;
				end
			end
			output = Y;
			
		end
	end



end

