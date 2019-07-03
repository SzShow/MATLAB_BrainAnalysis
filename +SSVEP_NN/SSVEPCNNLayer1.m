classdef SSVEPCNNLayer1 < nnet.layer.Layer
    %UNTITLED ���̃N���X�̊T�v�������ɋL�q
    %   �ڍא����������ɋL�q
    
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
        
        %�o�͂̍���=�M�����C�o�͂̕�
        function Z = predict(layer, X)
            N=size(X, 4);
            
            if isa(X, 'single')
                Z=zeros(layer.Oh, layer.Ow, 1, N, 'single');
            else
                Z=zeros(layer.Oh, layer.Ow, 1, N, 'double');
            end
            
            for batch=1:N %�~�j�o�b�`���ƂɌJ��Ԃ�
                for node=1:layer.Ow%�m�[�h���Ƃɏ�ݍ��݁{tanh�K�p
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
            
            for batch=1:N %�~�j�o�b�`���ƂɌJ��Ԃ�
                for node=1:layer.Ow%�m�[�h���Ƃɏ�ݍ��݁{tanh�K�p
                    memory(:, node, :, batch)=...
                        X(:,:,:,batch)*layer.W(:, node)+layer.b(node);
                    Z(:, node, :, batch)=...
                        tanh(memory(:, node, :, batch));
                end
            end
            
        end

        function [dLdX, dLdW] = backward(layer, X, Z, dLdZ, memory)
            
            N=size(X, 4);
            
            %���͂Əo�͂̌^(single��double)�͕K����v���Ȃ��Ƃ����Ȃ��̂ŁC
            %���̎��_�ŏo�͂̌^����͂ɍ��킹��D
            if isa(X, 'single')
                dLdw=zeros(layer.Iw, layer.Ow, 1, N, 'single');
                dLdx=zeros(layer.Ih, layer.Iw, 1, N, 'single');
            else
                dLdw=zeros(layer.Iw, layer.Ow,1, N,  'double');
                dLdx=zeros(layer.Ih, layer.Iw, 1, N, 'double');
            end
            

            
            %�p�����[�^�X�V
            %������C������̌덷�`�d�ɂ͂܂�����`�֐��̔�����
            %�������Ă��Ȃ����Ƃɒ���
            temp=(4./((exp(memory)+exp(-memory)).^2));%tanh�̔����v�Z
            dLdY=dLdZ.*temp;
            for batch=1:N %�~�j�o�b�`���ƂɌJ��Ԃ�
                dLdw(:,:,:,batch)=X(:,:,:,batch)'*dLdY(:,:,:,batch);
            end            
            dLdW=sum(dLdw, 4);
            
            %�덷�֐��`�d
            for batch=1:N %�~�j�o�b�`���ƂɌJ��Ԃ�
                dLdx(:,:,:,batch)=(dLdY(:,:,:,batch)*layer.W');
            end
            dLdX=dLdx;
        end
    end
end

