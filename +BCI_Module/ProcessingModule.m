classdef (Abstract)ProcessingModule
    %ProcessingModule �M�������p���W���[���̊��N���X
    %   �ڍא����������ɋL�q
	
	%
	properties (Abstract, SetAccess=immutable)
		%����͖��g�p
        %SignalRule
    end
	
	methods
		%�ʂ̐M�������p�̊֐����Ăяo���֐�
        function o=process(obj, i)
            o=cell(length(i), 1);
            for index=1:length(i)%�����f�[�^���Ƃ̏���
                o{index}=obj.operate(i{index});
            end

        end
        
        
    end
    
    methods (Static=true)
		%���̓f�[�^�̕��בւ�
		%(����͖��g�p)
        function o=DataPermute(i, rule)
            
            %���[�J���ϐ�����
            o=i;
            order=[0 0 0];
            S=i.Specification;
            
            %n�����ڂ̔z��̈ړ]�������
            for n=1:3
                %i�Ԗڂ̗񋓑̂Ƃ̔�r
                for index=1:3
                    if uint32(S(n))==rule(index)
                        order(n)=index;
                    end
                end

            end
            
            %permute���s
            o.Signal=permute(i.Signal, order);
            
        end
    end
    
	methods(Access=protected)
		%���͔z��̎�������ւ�
		%����͖��g�p
        function o=InputReshape(obj, i)
            %�e�����f�[�^�ɕ���
            for n=1:length(i)
                for index=1:4
                    %�e���������Ԗڂ̎����ɂ���Ηǂ��̂���T��
                    temp=i{n};
                    o{n}=temp.Specification;
                    
                end
            end
            
            
            %permute��莟���̍Ĕz������s
        end
		
		%�o�͔z��̎�������ւ�
		%����͖��g�p
        function o=OutputReshape(obj, varargin)
            %�e�����f�[�^�ɕ���
            
            %�e���������Ԗڂ̎����ɂ���Ηǂ��̂���T��
            
            %permute��莟���̍Ĕz������s
        end
		
		%����͖��g�p
        function o=SignalNumControll(obj, i)
        end
		
		%���֐��̓K�p
        function o= setwindow(obj, S)
			%���֐��̗񋓑̂̃C���|�[�g
			import BCI_Module.EWindowList

			%win�ɓ��͂��ꂽ�]�gS�Ɠ��������̑��֐������
			%�i����̓T�|�[�g���R���p�N�g���C�]�g�̗��[�̐U�������Ȃ�
			%�@�n�������g�p���Ă���܂��D�j
            switch obj.Window
                case EWindowList.Gauss	%�K�E�X��
                    win=gausswin(length(S));
                case EWindowList.Hamming	%�n�~���O��
                    win=hamming(length(S));
                case EWindowList.Hann	%�n����
                    win=hann(length(S));
                case EWindowList.Rect	%��`��
                    o=S;
                    return;	%�����]�g�ɉ������Ȃ��̂ƈꏏ�Ȃ̂ŏ������I��
                
            end

			%�o�̓T�C�Y�̊m��
			o= zeros(size(S));
			
			%���֐��̓K�p
            for x=1:size(S, 2)	%x�Ԗڂ̃`���l����Ώ�
                for y = 1:size(S, 3)	%y�Ԗڂ̃G�|�b�N��Ώ�
                    o(:,x,y)=S(:,x,y).*win; %y�Ԗڂ̃G�|�b�N��x�Ԗڂ̃`���l��
                                            %�̔]�g�Ƒ��֐��œ��ς����
                end
            end
		end

    end
    
    methods(Abstract, Access=protected)
        o=operate(obj, i)
    end
end

