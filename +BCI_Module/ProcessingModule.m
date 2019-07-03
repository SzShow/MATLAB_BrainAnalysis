classdef (Abstract)ProcessingModule
    %ProcessingModule 信号処理用モジュールの基底クラス
    %   詳細説明をここに記述
	
	%
	properties (Abstract, SetAccess=immutable)
		%今回は未使用
        %SignalRule
    end
	
	methods
		%個別の信号処理用の関数を呼び出す関数
        function o=process(obj, i)
            o=cell(length(i), 1);
            for index=1:length(i)%実験データごとの処理
                o{index}=obj.operate(i{index});
            end

        end
        
        
    end
    
    methods (Static=true)
		%入力データの並べ替え
		%(今回は未使用)
        function o=DataPermute(i, rule)
            
            %ローカル変数生成
            o=i;
            order=[0 0 0];
            S=i.Specification;
            
            %n次元目の配列の移転先を決定
            for n=1:3
                %i番目の列挙体との比較
                for index=1:3
                    if uint32(S(n))==rule(index)
                        order(n)=index;
                    end
                end

            end
            
            %permute実行
            o.Signal=permute(i.Signal, order);
            
        end
    end
    
	methods(Access=protected)
		%入力配列の次元入れ替え
		%今回は未使用
        function o=InputReshape(obj, i)
            %各実験データに分割
            for n=1:length(i)
                for index=1:4
                    %各次元を何番目の次元にすれば良いのかを探索
                    temp=i{n};
                    o{n}=temp.Specification;
                    
                end
            end
            
            
            %permuteより次元の再配列を実行
        end
		
		%出力配列の次元入れ替え
		%今回は未使用
        function o=OutputReshape(obj, varargin)
            %各実験データに分割
            
            %各次元を何番目の次元にすれば良いのかを探索
            
            %permuteより次元の再配列を実行
        end
		
		%今回は未使用
        function o=SignalNumControll(obj, i)
        end
		
		%窓関数の適用
        function o= setwindow(obj, S)
			%窓関数の列挙体のインポート
			import BCI_Module.EWindowList

			%winに入力された脳波Sと同じ長さの窓関数を入力
			%（今回はサポートがコンパクトかつ，脳波の両端の振動を見ない
			%　ハン窓を使用しております．）
            switch obj.Window
                case EWindowList.Gauss	%ガウス窓
                    win=gausswin(length(S));
                case EWindowList.Hamming	%ハミング窓
                    win=hamming(length(S));
                case EWindowList.Hann	%ハン窓
                    win=hann(length(S));
                case EWindowList.Rect	%矩形窓
                    o=S;
                    return;	%実質脳波に何もしないのと一緒なので処理を終了
                
            end

			%出力サイズの確保
			o= zeros(size(S));
			
			%窓関数の適用
            for x=1:size(S, 2)	%x番目のチャネルを対象
                for y = 1:size(S, 3)	%y番目のエポックを対象
                    o(:,x,y)=S(:,x,y).*win; %y番目のエポックのx番目のチャネル
                                            %の脳波と窓関数で内積を取る
                end
            end
		end

    end
    
    methods(Abstract, Access=protected)
        o=operate(obj, i)
    end
end

