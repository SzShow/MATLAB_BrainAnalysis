classdef ClusteringAddon < OutputAddon
    %UNTITLED2 ���̃N���X�̊T�v�������ɋL�q
    %   �ڍא����������ɋL�q
    
    properties
        Property1
    end
    
    methods
        function altrabel=addonprocess(obj, feature, rabel)
            [idx, C] = kmeans(feature, 2);
            winner=1;

            if (C(1, :)< C(2, :))
                winner=2;
            end
            altrabel = changerabel(rabel, idx, winner);
        end
    end

    methods (Access=private, Static)
        function altrabel = changerabel(rabel, idx, winner)
            
        end
    end
end

