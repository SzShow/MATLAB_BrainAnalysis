classdef BCI
	%BCI　脳波からコマンドを出力するクラス
    properties
        epochDivider	%エポック分割を実行するクラス
        processingModules	%前処理・特徴量抽出をするクラス
        outputModule	%抽出された特徴からコマンドを出力するクラス
    end
	
	%public関数
	methods (Access=public)
	
        %コンストラクタ
        function obj=BCI(varargin)
            %各モジュールが適切にセッティングされているかをチェック
            obj.IsEpochDivider(varargin)
            obj.IsProcessingModule(varargin)
            obj.IsOutputModule(varargin)
                        
            %入力されたモジュールをそれぞれBCIにセットする
            obj.epochDivider=varargin{1};
            obj.processingModules=varargin{2:nargin-1};
            obj.outputModule=varargin{nargin};
        end
        
        %BCIの学習
		function [obj, S]=train(obj,input)
			%入力された信号から特徴量を抽出する
			S=obj.preprocess(input);
			%抽出された特徴量を基に学習を実行
            obj.outputModule=obj.outputModule.train(S);
            
        end
        
        %コマンド出力
		function [cmd, S, Y]=test(obj,input)
			%入力された信号から特徴量を抽出する
			S=obj.preprocess(input);
			%抽出された特徴量からコマンドを抽出し，
			%各エポックの正解ラベルも返す
            [cmd, Y]=obj.outputModule.test(S);
        end

		%k-分割交差検証
        function score=crossevaluate(obj, input)
			%パッケージからBCI評価用のクラスをインポート
			import BCI_Module.BCIEvaluator

			%必要な変数の初期設定をする
			S=obj.preprocess(input);	%特徴量抽出
            trainData=cell(length(S)-1, 1);	%訓練用データを貯める配列
            index=1;	%訓練用データの入れ替えに用いるカウンタ
			score=zeros(length(S), 1);	%各テストデータを対象にした正答率
			
			%n番目のデータをテスト用とする
            for n=1:length(S)
				%trial(≠n)番目のデータ全てを訓練用とする
                for trial=1:length(S)
                    if n~=trial
                        trainData{index}=S{trial};
                        index=index+1;
                    end
                end
				
				%n番目以外の全てのデータを用いて学習させてから
				%n番目のデータよりコマンドを出力する
				obj.outputModule=obj.outputModule.train(trainData);
				[cmd, Y]=obj.outputModule.test({S{n}});
				
				%コマンドと正解ラベルを比較した図の表示と
				%正答率の計算を行う
                BCIEvaluator.CompareCorrectCommand({S{n}}, Y, cmd);	
				score(n)=BCIEvaluator.CalclateCorrectRate(Y, cmd);
				
				%カウンタと分類器をリセットする
                index=1;	
                obj.outputModule.Classifier=[];
            end
        end
    end

	%private関数
    methods (Access= private)
		
		%特徴抽出の実行
		function output = preprocess(obj, input) 
			%入力されたデータが全て適切なデータかをチェック
            obj.IsExperimentData(input);
			
			%脳波をセル配列Sに展開
			%（脳波はEEGクラスのインスタンスとして表現する）
            S = cell(length(input), 1);
            for n = 1:length(input)
                tmp = input{n};
                S{n} = tmp.ExpandEEG;
            end
			
			%エポックの分割を実行
            S = obj.epochDivider.EpochDivide(S);
			
			%信号S内のデータを脳波から特徴量に変換
            for n = 1:length(obj.processingModules)	
                %n番目のprocessingModuleを取り出す
                mod = obj.processingModules{n};	
                %processingModule内に記述された処理を脳波に実行
                S = mod.process(S);	
            end
            output = S;
        end

    end
	
	%Static変数
    methods (Access = private, Static = true)
		
		%入力された実験データの正常性の評価
        function IsExperimentData(i)
            for n=1:length(i)
                if ~strcmp(superclasses(i{n}), 'BCI_Module.ExperimentData')
                    error('ExperimentDataで無いデータが発見されました')
                end
            end
        end
		
		%最初に入力用モジュールがセットされているかの評価
        function IsEpochDivider(i)
            obmeta=metaclass(i{1});
            if ~strcmp(obmeta.Name, 'BCI_Module.EpochDivider')
                error(['最初の引数がEpochDividerクラス' ...
                    'として認識されませんでした'])
            end
        end
		
		%最初と最後以外に信号処理モジュールがセットされているかの評価
        function IsProcessingModule(i)
            for n=2:length(i)-1
                if ~strcmp(superclasses(i{n}),...
                        'BCI_Module.ProcessingModule')
                    error(['最初と最後以外の引数にProcessingModuleクラス' ...
                        '以外の入力が見られました'])
                end
            end
        end
		
		%最後に出力モジュールがセットされているかの評価
        function IsOutputModule(i)
            if ~strcmp(superclasses(i{length(i)}),...
                    'BCI_Module.BCIOutputModule')
                error(['最後の引数がOutputModuleクラス' ...
                    'として認識されませんでした'])
            end
        end
        
    end
    
end

