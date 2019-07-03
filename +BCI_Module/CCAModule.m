classdef CCAModule < BCI_Module.ProcessingModule
    %CCAModule ���͂��ꂽ�]�g��CCA��K�p
    %   ���͂��ꂽ�]�g��SSVEP�Ή��̐������֕��͂�K�p���܂�
    %   ���̓f�[�^��Z���Ԃ̑��`���l���]�g�Ƃ��C
    %   �Q�ƃf�[�^�𒲂ׂ������g���̐����g�E�]���g����т��̍����g�Ƃ��Ă��܂��D
    %   BCI�ɑg�ݍ��ޑO�ɃR���X�g���N�^��
    %   �i���ׂ������g���C�����g�̐��C�o�͂���`���l�����C�o�͂������f�[�^�C
    %   �K�p���鑋�֐��j
    %   ����͂��Ă��������D
    %   �܂��C�������֕��͂̐�����
    %   https://www.jstage.jst.go.jp/article/jnns/20/2/20_62/_pdf
    %   ��������₷���CSSVEP�ւ̉��p���
    %   https://arxiv.org/abs/1308.5609
    %   �ȂǂɋL�ڂ���Ă��܂��D
    %
    %   �L����P�D�i7Hz��14Hz�𒲂ׂ�j
    %   of = [ECCAOutput.SpatialFilter ECCAOutput.CorrelationEfficient];
    %   Mod = CCAModule(7, 2, 2, of, EWindowList.Hann)
    %
    %   �L����Q�D�i7Hz,14Hz,15Hz,30Hz�𒲂ׂ�j
    %   of = [ECCAOutput.SpatialFilter ECCAOutput.CorrelationEfficient];
    %   Mod = CCAModule([7 15], 2, 2, of, EWindowList.Hann)
    %
    %   �L����R�D�i7Hz,14Hz,15Hz�𒲂ׂ�j
    %   of = [ECCAOutput.SpatialFilter ECCAOutput.CorrelationEfficient];
    %   Mod = CCAModule([7 15], [2 1], 2, of, EWindowList.Hann)
    
     
	properties (SetAccess=private)
		SamplingFreq 	%�T���v�����O���g��
        Freq    %���ׂ������g��
        Harmonics   %��{�g�{�����g�̐�
        SignalNum   %�o�͂���`���l���̐�
        OutputFeature   %�o�͂��������
        SignalRule  %����͖��g�p
        Window      %�g�p���鑋�֐�
	end
	
	properties (Dependent)
		FilterNum   %���ׂ������g���̐�
		WavePos     %�]�g�����Ԗڂ̓����ʂɂ����邩
	end
	
	%get���\�b�h
	methods 
		%���͂��ꂽ���g���̐�����t�B���^�̐����v�Z
		function output = get.FilterNum(obj)
			output = length(obj.Freq);
		end
		
		%�]�g�ɂ���������ʂ����o
		function output = get.WavePos(obj)
			import BCI_Module.ECCAOutput
            for index=1:length(obj.OutputFeature)
                if obj.OutputFeature(index) == ECCAOutput.FilterOutput
                    output=index;
                    return
                end
            end
            output = NaN;
		end

	end

	%set���\�b�h
	methods 

		%�����g�̏���
		%Freq�v���p�e�B�̗v�f���ɍ��킹�邽�߂�
		%�������򂵂Ă��܂��D
		function obj =set.Harmonics(obj, h)
            if length(h)==1
                obj.Harmonics=ones(obj.FilterNum, 1)*h;
            elseif length(h)==obj.FilterNum 
                obj.Harmonics=h;
            else
                error('����h�̒������s�K�؂ł�');
            end
		end

		%��肽���`���l�����̏���
		function obj = set.SignalNum(obj, s)
            if length(s)==1
                obj.SignalNum=ones(obj.FilterNum, 1)*s;
            elseif length(s)==obj.FilterNum 
                obj.SignalNum=s;
            else
                error('����h�̒������s�K�؂ł�');
            end
			
		end

	end

     %�R���X�g���N�^
    methods (Access=public)
        function obj=CCAModule(f,h,s,of, win)          
            %�v���p�e�B�̃Z�b�g
            obj.Freq=f;
            obj.Harmonics = h;
            obj.SignalNum = s;
            obj.OutputFeature=of;
            obj.Window=win;
        end
    end
	
	%���s���\�b�h
    methods (Access=protected)
		function output = operate(obj,input)
			%�񋓑̂̃C���|�[�g
            import BCI_Module.ECCAOutput
			
			%EEG�N���X����T���v�����O���g�����擾
            obj.SamplingFreq=input.SamplingFreq;

            %�o�͂ƐM���̏����ݒ�
            output=input;
            S=input.Signal;
            S=obj.setwindow(S);

			%���[�J���ϐ��̐ݒ�
            Nepo=input.EpochNum;
            %Fout=obj.OutputFeature;
                       
            %�e�t�B���^�̃`���l�������v�Z
            CCANum = obj.clacccanum(input);

            %�o�̓T�C�Y�̊m��
            output.Signal=obj.SaveFilterOutput(input, CCANum);
            output.WavePos=obj.WavePos;

            %���g�����Ƃɏ���
            ssvepFreq=obj.Freq;
            ssvepHarmonics=obj.Harmonics;
            for n=1:length(ssvepFreq)
                f=ssvepFreq(n);
                h=ssvepHarmonics(n);
                %�G�|�b�N����CCA�K�p
                for epoch=1:Nepo
                    [A,B,r,U,V]=obj.cca(S(:,:,epoch),f,h);
                    for index=1:length(obj.OutputFeature)
                        temp=output.Signal{index,n};
                        switch obj.OutputFeature(index)
                            case ECCAOutput.SpatialFilter
                                temp(:,:,epoch)=A(:,1:CCANum(n));

                            case ECCAOutput.FourierEfficient
                                temp(:,:,epoch)=B(:,1:CCANum(n));

                            case ECCAOutput.CorrelationEfficient
                                temp(:,:,epoch)=r(:,1:CCANum(n));

                            case ECCAOutput.FilterOutput
                                temp(:,:,epoch)=U(:,1:CCANum(n));

                            case ECCAOutput.FourierSeries
                                temp(:,:,epoch)=V(:,1:CCANum(n));
                        end
                        output.Signal{index,n}(:,:,epoch)=temp(:,:,epoch);
                    end

                end
				output.FeatureInfo = obj.setfeatureinfo(output.Signal);
                
            end
       
        end
        
    end
    
    methods (Access=private)
        %�o�͂Ƃ��āC[�o�͂�������ʂ̎퐔, �Ώێ��g���̎퐔]��
        %���������Z����Ԃ��܂��D
        %�e�Z���ɂ�[�����ʂ̒����C�����ʂ̐��C�G�|�b�N��]�̒���������
		%3�����̃f�[�^���܂܂�Ă��܂��D
		
		%�e�t�B���^�̃`���l�������v�Z
		function output = clacccanum(obj, input)
			%���[�J���ϐ��̐ݒ�
			Nfilt=obj.FilterNum;
			Nch=ones(Nfilt, 1)*input.ChanelNum;
			Nharm=obj.Harmonics;
			Ns=obj.SignalNum;
			
			%�o�̓T�C�Y�̊m��
			output=zeros(Nfilt, 1);
			
			%�e�t�B���^���ɏo�͂̃`���l���T�C�Y���v�Z
			for index=1:Nfilt
				%�]�g�̃`���l�����C���t�@�����X�M���̃`���l�����C
				%���[�U���v������`���l�����̓��̍ŏ��l���v�Z
                output(index)=min([Nch(index), 2*Nharm(index), Ns(index)]);
			end

		end

        function o=SaveFilterOutput(obj, input, CCANum)

            import BCI_Module.ECCAOutput
            
            %���[�J���ϐ�
			Nfilt=obj.FilterNum;
            Nsig=length(obj.OutputFeature);	
            Nfreq=length(obj.Freq);
			Nharm=obj.Harmonics;
			Nepo=input.EpochNum;
			Nch=ones(Nfilt, 1)*input.ChanelNum;
			Nsamp=input.SignalNum;

            %�o�͂̃Z�����̊m��
            o=cell(Nsig, 1);

            %�e�Z�����̃f�[�^�T�C�Y�̊m��
            for f=1:Nfreq
                for index=1:Nsig
                    %�ق����o�͂̎�ނɉ����ďꍇ����
                    switch obj.OutputFeature(index)
                        case ECCAOutput.SpatialFilter
                            x=Nch(f);
                            y=CCANum(f);
                            z=Nepo;                        
                        case ECCAOutput.FourierEfficient
                            x=2*Nharm(f);
                            y=CCANum(f);
                            z=Nepo;                        
                        case ECCAOutput.CorrelationEfficient
                            x=1;
                            y=CCANum(f);
                            z=Nepo;                        
                        case ECCAOutput.FilterOutput
                            x=Nsamp;
                            y=CCANum(f);
                            z=Nepo;                       
                        case ECCAOutput.FourierSeries
                            x=Nsamp;
                            y=CCANum(f);
                            z=Nepo;
                    end
                    o{index, f}=zeros(x,y,z);
                end
            end
        end


        function [A, B, r, U, V, Ns]=cca(obj, Y, f, Nh)
            [A, B, r, U, V]=ssvepcca(Y, f, Nh, obj.SamplingFreq);
            Ns=length(U(1, :));
		end        
		
		function output = setfeatureinfo(obj, S)

			%Table�z��̗v�f�̃T�C�Y���m��
			FeatureName = zeros(numel(S), 1);
			FeatureLength = zeros(numel(S), 1);

			%S��col�̓����ʂ̖��O�ƒ����𒲂ׂ�
			n = 1;
			for row = 1:size(S, 2)
				for col= 1:size(S, 1)
					FeatureName(n) = obj.OutputFeature(col);
					FeatureLength(n) = size(S{col, row}, 1);
					n = n + 1;
				end
			end

			output = table(FeatureName, FeatureLength);

		end

    end
    
end

