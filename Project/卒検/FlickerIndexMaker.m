Lf=[7.5 6.66 10 12 6.66 8.57 12 7.5];
win=rdann('S001a', 'win');
Tm=100+10*length(Lf);
W=zeros(Tm, 1);
c=0;

for t=2:Tm
    if t*250>win(c+1)
        c=c+1;
        if W(t-1)==0
            W(t)=Lf(ceil(c/2));
        else
            W(t)=0;
        end
    else
        W(t)=W(t-1);
    end
end