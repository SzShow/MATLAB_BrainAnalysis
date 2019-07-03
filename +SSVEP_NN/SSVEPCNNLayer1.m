classdef SSVEPCNNLayer1 < nnet.layer.Layer
    %UNTITLED このクラスの概要をここに記述
    %   詳細説明をここに記述
    
    properties
        % (Optional) Layer properties

        % Layer properties go here
        Ih;
        Iw;
        Oh;
        Ow;
        b%Bias
    end

    properties (Learnable)
        % (Optional) Layer learnable parameters

        % Layer learnable parameters go here
        W%Weigh
        
    end
    
    methods
        function layer = SSVEPCNNLayer1(ih,iw,ow)
            % (Optional) Create a myLayer
            % This function must have the same name as the layer
            
            % Layer constructor function goes here
%             layer.h=nt;
%             layer.w=nele;
            layer.Ih=ih;
            layer.Iw=iw;
            layer.Oh=ih;
            layer.Ow=ow;
            layer.W=rand(iw, ow);
            layer.b=rand(ow, 1);
        end
        
        %出力の高さ=信号帳，出力の幅
        function Z = predict(layer, X)
            N=size(X, 4);
            
            if isa(X, 'single')
                Z=zeros(layer.Oh, layer.Ow, 1, N, 'single');
            else
                Z=zeros(layer.Oh, layer.Ow, 1, N, 'double');
            end
            
            for batch=1:N %ミニバッチごとに繰り返す
                for node=1:layer.Ow%ノードごとに畳み込み＋tanh適用
                    Z(:, node, :, batch)=...
                        tanh(X(:,:,:,batch)*layer.W(:, node)+...
                        layer.b(node));
                end
            end
            

        end

        function [Z, memory] = forward(layer, X)
            N=size(X, 4);
            
            if isa(X, 'single')
                Z=zeros(layer.Oh, layer.Ow, 1, N, 'single');
                memory=zeros(layer.Oh, layer.Ow, 1, N, 'single');
            else
                Z=zeros(layer.Oh, layer.Ow, 1, N, 'double');
                memory=zeros(layer.Oh, layer.Ow, 1, N, 'double');
            end
            
            for batch=1:N %ミニバッチごとに繰り返す
                for node=1:layer.Ow%ノードごとに畳み込み＋tanh適用
                    memory(:, node, :, batch)=...
                        X(:,:,:,batch)*layer.W(:, node)+layer.b(node);
                    Z(:, node, :, batch)=...
                        tanh(memory(:, node, :, batch));
                end
            end
            
        end

        function [dLdX, dLdW] = backward(layer, X, Z, dLdZ, memory)
            
            N=size(X, 4);
            
            %入力と出力の型(singleかdouble)は必ず一致しないといけないので，
            %この時点で出力の型を入力に合わせる．
            if isa(X, 'single')
                dLdw=zeros(layer.Iw, layer.Ow, 1, N, 'single');
                dLdx=zeros(layer.Ih, layer.Iw, 1, N, 'single');
            else
                dLdw=zeros(layer.Iw, layer.Ow,1, N,  'double');
                dLdx=zeros(layer.Ih, layer.Iw, 1, N, 'double');
            end
            

            
            %パラメータ更新
            %後方レイヤからの誤差伝播にはまだ非線形関数の微分が
            %かかっていないことに注意
            temp=(4./((exp(memory)+exp(-memory)).^2));%tanhの微分計算
            dLdY=dLdZ.*temp;
            for batch=1:N %ミニバッチごとに繰り返す
                dLdw(:,:,:,batch)=X(:,:,:,batch)'*dLdY(:,:,:,batch);
            end            
            dLdW=sum(dLdw, 4);
            
            %誤差関数伝播
            for batch=1:N %ミニバッチごとに繰り返す
                dLdx(:,:,:,batch)=(dLdY(:,:,:,batch)*layer.W');
            end
            dLdX=dLdx;
        end
    end
end

