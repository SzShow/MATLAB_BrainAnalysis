classdef (Abstract)BCIOutputModule
    %UNTITLED ���̃N���X�̊T�v�������ɋL�q
    %   �ڍא����������ɋL�q
    
    properties(Abstract)
        Classifier
    end
    
    methods  (Abstract)  
        O=train(obj, varargin)
        O=test(obj, varargin)
        
    end
    
    methods(Access=protected, Static)

        function o=JointFeature(i)
            %�f�[�^�̌����J�n
            o=[];
            for index=1:length(i)
                X=[];
                data=i{index};
                for a=1:size(data.Signal, 1)
                    for b=1:size(data.Signal, 2)
                        temp=data.Signal{a, b};
                        for y=1:size(temp, 2)
                            if size(temp(:,y,:), 1)==1
                                X=[X squeeze(temp(:,y,:))];
                            else
                                X=[X squeeze(temp(:,y,:))'];
                            end
                        end
                    end
                end
                o=[o;X];
            end
        end

        function o=epochtrigger(i)
            %�����f�[�^���Ƃɏ���
            o=[];


            for index=1:length(i)
                data=i{index};
                Lepoch=data.EpochTimeList;
                tabel=data.Rabel;
                Fs=data.SamplingFreq;
                temp=zeros(length(Lepoch), 1);
                for n=1:length(Lepoch)
                    temp(n)=tabel(floor(Fs*Lepoch(n)));
                end
                o=[o; temp];
            end
        end
    end
end

