classdef SSVEPCNNLayer2 < nnet.layer.Layer

    properties
        % (Optional) Layer properties

        % Layer properties go here
        Nfft=1024;
        Fs
        F
    end

    properties (Learnable)
        % (Optional) Layer learnable parameters

        % Layer learnable parameters go here
    end
    
    methods
        function layer = SSVEPCNNLayer2()
            % (Optional) Create a myLayer
            % This function must have the same name as the layer

            % Layer constructor function goes here
        end
        
        function Z = predict(layer, X)
            % Forward input data through the layer at prediction time and
            % output the result
            %
            % Inputs:
            %         layer    -    Layer to forward propagate through
            %         X        -    Input data
            % Output:
            %         Z        -    Output of layer forward function
            
            % Layer forward function for prediction goes here
            
            [Nt, ~, Ncom]=size(X);
            Nf=length(layer.F);
            T=(1:Nt)/layer.Fs;
            Ym=zeros(Nf, 1, Ncom);
            x2mf=zeros(Nf, 1, Ncom);
            s2mf=zeros(Nf, 1, Ncom);
            
            for m=1:Ncom
                e=exp(1i*-2*pi*u*T/layer.Nfft);
                Ym=(1/layer.Nfft)*dot(X(:,1,m),e);
                x2mf=abs(Ym(f, 1, m));
                s2mf=angle(Ym(f,1,m));
            end
            Z=x2mf;
            
        end

        function [Z, memory] = forward(layer, X)
            % (Optional) Forward input data through the layer at training
            % time and output the result and a memory value
            %
            % Inputs:
            %         layer  - Layer to forward propagate through
            %         X      - Input data
            % Output:
            %         Z      - Output of layer forward function
            %         memory - Memory value which can be used for
            %                  backward propagation

            % Layer forward function for training goes here
        end

        function [dLdX, dLdW1, dLdWn] = backward(layer, X, Z, dLdZ, memory)
            % Backward propagate the derivative of the loss function through 
            % the layer
            %
            % Inputs:
            %         layer             - Layer to backward propagate through
            %         X                 - Input data
            %         Z                 - Output of layer forward function            
            %         dLdZ              - Gradient propagated from the deeper layer
            %         memory            - Memory value which can be used in
            %                             backward propagation
            % Output:
            %         dLdX              - Derivative of the loss with respect to the
            %                             input data
            %         dLdW1, ..., dLdWn - Derivatives of the loss with respect to each
            %                             learnable parameter
            
            % Layer backward function goes here
        end
    end
end