classdef EDataSpecification < uint32
    %UNTITLED ���̃N���X�̊T�v�������ɋL�q
    %   �ڍא����������ɋL�q
    methods (Static=true)
        %���̓f�[�^�̕��בւ�
        function o=DataPermute(i, rule)
            
            %���[�J���ϐ�����
            o=i;
            order=[0 0 0];
            S=i.Specification;
            
            %n�����ڂ̔z��̈ړ]�������
            for n=1:3
                %i�Ԗڂ̗񋓑̂Ƃ̔�r
                for i=1:3
                    if uint(S{n})==i
                        order(n)=i;
                    end
                end

            end
            
            %permute���s
            o.Signal=permute(i.Signal, order);
            
        end
    end
    
    enumeration
        Data (1)
        Chanel (2)
        
        Epoch (3)
        Branch (4)
    end
end

