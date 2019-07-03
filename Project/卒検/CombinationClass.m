classdef CombinationClass
    %UNTITLED2 ���̃N���X�̊T�v�������ɋL�q
    %   �ڍא����������ɋL�q
    
    properties(Constant)
        
        
        %Bipolar�p�v���Z�b�g
        BipPreset_15={   'P5',   'PO7';
                         'P3',   'PO3';
                         'PO3',  'O1' ;
                         'P3',   'O1';
                         'P3',   'P1' ;
                         'P1',   'Pz' ;
                         'Pz',   'POz' ;
                         'Pz',   'Oz' ;
                         'POz',   'Oz' ;
                         'Pz',   'P2' ;
                         'P2',   'P4' ;
                         'P4',   'PO4' ;
                         'P4',   'O2' ;
                         'PO4',   'O2' ;
                         'P6',   'PO8' ;};
        
        %Laplacian�p�v���Z�b�g
        LapPreset_15={  'PO3',   'P3',   'POz',   'O1',   'PO7';
                        'POz',   'Pz',   'PO4',   'Oz',   'PO3';
                        'PO4',   'P4',   'PO8',   'O2',   'POz';};
    end
    
    properties
        
        %I:�O��������
        Method                  %�O�������@�̖��O
        Ebi                     %Bipolar���s���̓d�ɂ̑g�ݍ��킹
        Ela                     %Laplacian���s���̓d�ɂ̑g�ݍ��킹
        f
        Nh
        DetectionMode
        
        %O:���茋��
        MethodName
        S                       %�O�����σf�[�^
        Ns                      %S�̃`�����l����
        D                       %mec,mcc���s���̕��όŗL�l�s��
        Tp                      %mec,mcc���s���̏����Ԋu
    end
    
    properties(Dependent)

    end
    
    
    methods
        

        
        function [obj, Signal]=prepro(obj, E, a)

            %ExperimentDataClass�̃p�����[�^����
            Ny=E.Ny;
            Nt=E.Nt;
            
            switch obj.Method
                %AverageCombination
                case 1
                    obj.MethodName='Average';
                    obj.S=zeros(length(E.Y), E.Ny);
                    W=zeros(Ny,1);
                    for i=1:Ny
                        W(i,1)=1;
                    end
                    obj.S(:, :, i)=E.Y(:, :, a)*W(:, :, 1);
                    
                %NativeCombination
                case 2
                    obj.MethodName='Native';
                    obj.S=zeros(length(E.Y), E.Ny);
                    W=eye(Ny);
                    for i=1:Ny
                     W(1,i)=1;
                    end
                    obj.S(:, :)=E.Y(:, :, a)*W(:, :, 1);

                    
                %BipolarCombination
                case 3
                    obj.S=zeros(length(E.Y), E.Ny);
                    obj.MethodName='Bipolar';
                    obj.Ns=length(obj.Ebi(:,1));
                    Mbi=BipolarConvert(obj.Ebi, E);
                    W=zeros(Ny, obj.Ns);
                    for n=1:obj.Ns
                        W(Mbi(n,1),n)=1;
                        W(Mbi(n,2),n)=-1;
                    end
                    obj.S(:, :)=E.Y(:, :, a)*W(:, :);

                
                %LaplacianCombination
                case 4
                    obj.MethodName='Laplacian';
                    obj.Ns=length(obj.Ela(:,1));
                    Mla=LaplacianConvert(obj.Ela, E);
                    obj.S=zeros(length(E.Y), obj.Ns);
                    W=zeros(Ny, obj.Ns);
                    for n=1:obj.Ns
                        W(Mla(n,1),n)=4;
                        W(Mla(n,2),n)=-1;
                        W(Mla(n,3),n)=-1;
                        W(Mla(n,4),n)=-1;
                        W(Mla(n,5),n)=-1;
                    end
                        obj.S(:, :)=E.Y(:, :, a)*W(:, :);
                    
                %MinimumEnergyCombination
                case 5
                    obj.MethodName='MinimumEnergy';
                    obj.S=zeros(length(E.Y), E.Ny);

                    [~, obj.D]=mec(E.Y(:, :, a), obj.f, obj.Nh, E.Fs);
                    obj.S=E.Y(:,:,a)*obj.D;
                    
%                     if obj.DetectionMode==1
%                         subS=obj.S;
%                         clear obj.S 
%                         obj.Ns=0;
%                         Dns=0;
%                         Dall=0;
%                         for n=1:E.Ny
%                             Dall=Dall+obj.D(n, n);
%                         end
%                         
%                         for n=1:E.Ny
%                             obj.Ns=1+obj.Ns;
%                             Dns=Dns+obj.D(n, n);
%                             if Dns/Dall>0.1; break
%                             end
%                         end
%                         
%                         obj.S=subS(:, 1:obj.Ns, :);
%                     end
                    
                %MaximumContrastCombination
                case 6
                    obj.MethodName='MaximumContrast';
                    %obj.S=zeros(E.Tw*E.Fs, E.Ny);
                    [~, obj.D]=mcc(E.Y(:, :, a), obj.f, obj.Nh, E.Fs);
                    obj.S=E.Y(:,:,a)*obj.D;
                    
%                     if obj.DetectionMode==1
%                         subS=obj.S;
%                         clear obj.S 
%                         obj.Ns=0;
%                         for n=1:E.Ny
%                             if obj.D(E.Ny-n+1, E.Ny-n+1)<1000/(1000-2*obj.Nh)
%                                 break
%                             end
%                             obj.Ns=1+obj.Ns;
%                         end
%                         obj.S=subS(:,1:obj.Ns, :);
%                     end
                
            end
            Signal=obj.S;
            obj.Ns=length(obj.S(1,:));
            
        end
        
        

    end
    
end

function [Mbi]=BipolarConvert(Ebi, E)
    Nbi=length(Ebi(:,1));
    Mbi=zeros(Nbi,2);
    for n=1:Nbi
        Mbi(n, 1)=find(strncmp(E.El, Ebi(n, 1), 5));
        Mbi(n, 2)=find(strncmp(E.El, Ebi(n, 2), 5));
    end
end

function [Mla]=LaplacianConvert(Ela, E)
    Nla=length(Ela(:,1));
    Mla=zeros(Nla,2);
    for n=1:Nla
        Mla(n, 1)=find(strncmp(E.El, Ela(n, 1), 5));
        Mla(n, 2)=find(strncmp(E.El, Ela(n, 2), 5));
        Mla(n, 3)=find(strncmp(E.El, Ela(n, 3), 5));
        Mla(n, 4)=find(strncmp(E.El, Ela(n, 4), 5));
        Mla(n, 5)=find(strncmp(E.El, Ela(n, 5), 5));
    end
end

