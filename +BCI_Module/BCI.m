classdef BCI
	%BCI�@�]�g����R�}���h���o�͂���N���X
    properties
        epochDivider	%�G�|�b�N���������s����N���X
        processingModules	%�O�����E�����ʒ��o������N���X
        outputModule	%���o���ꂽ��������R�}���h���o�͂���N���X
    end
	
	%public�֐�
	methods (Access=public)
	
        %�R���X�g���N�^
        function obj=BCI(varargin)
            %�e���W���[�����K�؂ɃZ�b�e�B���O����Ă��邩���`�F�b�N
            obj.IsEpochDivider(varargin)
            obj.IsProcessingModule(varargin)
            obj.IsOutputModule(varargin)
                        
            %���͂��ꂽ���W���[�������ꂼ��BCI�ɃZ�b�g����
            obj.epochDivider=varargin{1};
            obj.processingModules=varargin{2:nargin-1};
            obj.outputModule=varargin{nargin};
        end
        
        %BCI�̊w�K
		function [obj, S]=train(obj,input)
			%���͂��ꂽ�M����������ʂ𒊏o����
			S=obj.preprocess(input);
			%���o���ꂽ�����ʂ���Ɋw�K�����s
            obj.outputModule=obj.outputModule.train(S);
            
        end
        
        %�R�}���h�o��
		function [cmd, S, Y]=test(obj,input)
			%���͂��ꂽ�M����������ʂ𒊏o����
			S=obj.preprocess(input);
			%���o���ꂽ�����ʂ���R�}���h�𒊏o���C
			%�e�G�|�b�N�̐������x�����Ԃ�
            [cmd, Y]=obj.outputModule.test(S);
        end

		%k-������������
        function score=crossevaluate(obj, input)
			%�p�b�P�[�W����BCI�]���p�̃N���X���C���|�[�g
			import BCI_Module.BCIEvaluator

			%�K�v�ȕϐ��̏����ݒ������
			S=obj.preprocess(input);	%�����ʒ��o
            trainData=cell(length(S)-1, 1);	%�P���p�f�[�^�𒙂߂�z��
            index=1;	%�P���p�f�[�^�̓���ւ��ɗp����J�E���^
			score=zeros(length(S), 1);	%�e�e�X�g�f�[�^��Ώۂɂ���������
			
			%n�Ԗڂ̃f�[�^���e�X�g�p�Ƃ���
            for n=1:length(S)
				%trial(��n)�Ԗڂ̃f�[�^�S�Ă��P���p�Ƃ���
                for trial=1:length(S)
                    if n~=trial
                        trainData{index}=S{trial};
                        index=index+1;
                    end
                end
				
				%n�ԖڈȊO�̑S�Ẵf�[�^��p���Ċw�K�����Ă���
				%n�Ԗڂ̃f�[�^���R�}���h���o�͂���
				obj.outputModule=obj.outputModule.train(trainData);
				[cmd, Y]=obj.outputModule.test({S{n}});
				
				%�R�}���h�Ɛ������x�����r�����}�̕\����
				%�������̌v�Z���s��
                BCIEvaluator.CompareCorrectCommand({S{n}}, Y, cmd);	
				score(n)=BCIEvaluator.CalclateCorrectRate(Y, cmd);
				
				%�J�E���^�ƕ��ފ�����Z�b�g����
                index=1;	
                obj.outputModule.Classifier=[];
            end
        end
    end

	%private�֐�
    methods (Access= private)
		
		%�������o�̎��s
		function output = preprocess(obj, input) 
			%���͂��ꂽ�f�[�^���S�ēK�؂ȃf�[�^�����`�F�b�N
            obj.IsExperimentData(input);
			
			%�]�g���Z���z��S�ɓW�J
			%�i�]�g��EEG�N���X�̃C���X�^���X�Ƃ��ĕ\������j
            S = cell(length(input), 1);
            for n = 1:length(input)
                tmp = input{n};
                S{n} = tmp.ExpandEEG;
            end
			
			%�G�|�b�N�̕��������s
            S = obj.epochDivider.EpochDivide(S);
			
			%�M��S���̃f�[�^��]�g��������ʂɕϊ�
            for n = 1:length(obj.processingModules)	
                %n�Ԗڂ�processingModule�����o��
                mod = obj.processingModules{n};	
                %processingModule���ɋL�q���ꂽ������]�g�Ɏ��s
                S = mod.process(S);	
            end
            output = S;
        end

    end
	
	%Static�ϐ�
    methods (Access = private, Static = true)
		
		%���͂��ꂽ�����f�[�^�̐��퐫�̕]��
        function IsExperimentData(i)
            for n=1:length(i)
                if ~strcmp(superclasses(i{n}), 'BCI_Module.ExperimentData')
                    error('ExperimentData�Ŗ����f�[�^����������܂���')
                end
            end
        end
		
		%�ŏ��ɓ��͗p���W���[�����Z�b�g����Ă��邩�̕]��
        function IsEpochDivider(i)
            obmeta=metaclass(i{1});
            if ~strcmp(obmeta.Name, 'BCI_Module.EpochDivider')
                error(['�ŏ��̈�����EpochDivider�N���X' ...
                    '�Ƃ��ĔF������܂���ł���'])
            end
        end
		
		%�ŏ��ƍŌ�ȊO�ɐM���������W���[�����Z�b�g����Ă��邩�̕]��
        function IsProcessingModule(i)
            for n=2:length(i)-1
                if ~strcmp(superclasses(i{n}),...
                        'BCI_Module.ProcessingModule')
                    error(['�ŏ��ƍŌ�ȊO�̈�����ProcessingModule�N���X' ...
                        '�ȊO�̓��͂������܂���'])
                end
            end
        end
		
		%�Ō�ɏo�̓��W���[�����Z�b�g����Ă��邩�̕]��
        function IsOutputModule(i)
            if ~strcmp(superclasses(i{length(i)}),...
                    'BCI_Module.BCIOutputModule')
                error(['�Ō�̈�����OutputModule�N���X' ...
                    '�Ƃ��ĔF������܂���ł���'])
            end
        end
        
    end
    
end

