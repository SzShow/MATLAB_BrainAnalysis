classdef LDAMod < BCI_Module.BCIOutputModule
    %UNTITLED2 ���̃N���X�̊T�v�������ɋL�q
    %   �ڍא����������ɋL�q
    
	properties
		isEnableClusttering %�N���X�^�����O�ɂ��w�K�f�[�^�I�����g����
		Feature
        Classifier%���ފ�
    end
    
	methods
	
		function obj = LDAMod(clusten, feature)
		obj.isEnableClusttering = clusten;
		obj.Feature = feature;
			
		end

        function obj=train(obj, input)
            X=obj.JointFeature(input);	%�P���f�[�^�̃t�H�[�}�b�e�B���O
			Y=obj.epochtrigger(input);	%�������x���̃t�H�[�}�b�e�B���O
			
			if obj.isEnableClusttering == true
				F = obj.ExtractFeature(X,...
					input{1}.FeatureInfo, obj.Feature, input{1}.SignalNum);
				Y = obj.Clustering(F, Y);
			end

            obj.Classifier=fitcdiscr(X,Y);	%�w�K�̎��s�J�n
        end
        
        function [o,Y]=test(obj, i)
            X=obj.JointFeature(i);	%�e�X�g�f�[�^�̃t�H�[�}�b�e�B���O
            Y=obj.epochtrigger(i);	%�e�X�g�f�[�^�̃t�H�[�}�b�e�B���O
            o=predict(obj.Classifier, X);	%�R�}���h�o�͂̎��s�J�n
        end
        
	end
	
	methods (Access = protected, Static)

		function output = ExtractFeature(X, info, feature, signalnum)
			%�T�C�Y�̌v�Z�Əo�͂̊m��
			outputSize = 0;
			for index = 1:size(info, 1)
				if info.FeatureName(index) == feature
					outputSize = outputSize + info.FeatureLength(index);
				end
			end
			output = zeros(size(X, 1), outputSize*signalnum);

			%�����ʂ̓���
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
		
		%K-Mean�@�ɂ��N���X�^�����O�Ɋ�Â���
		%�w�K�f�[�^�̕���
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

