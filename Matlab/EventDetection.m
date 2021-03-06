function Events = EventDetection(Trialname,Time,FTable,ForceRatio,MTable,Threshold)
if contains(Trialname,"IsoM")
    [indx,c]=find(abs(FTable)>ForceRatio.*max(abs(FTable)));
    Stime=Time(indx([1;find(diff(indx)>10)+1]),1);
    %Etime=Time(indx([(find(diff(indx)>10));end]),1);
    Etime=Stime+3;
elseif contains(Trialname,"IsoK") 
    if contains(Trialname,"Fl")
        [indx,c]=find(MTable>=Threshold(1) & MTable<=Threshold(2));
        % & [0;diff(MTable(:,6))>0]
        Sindx=indx([1;find(diff(indx)>10)+1]);
        Eindx=indx([(find(diff(indx)>10));end]);
        count=0;
        Stime=[];
        Etime=[];
        for ww=1:length(Sindx)
            if (MTable(Sindx(ww))-MTable(Sindx(ww)-1))>0
                count=count+1;
                Stime=[Stime;Time(Sindx(ww),1)];
                Etime=[Etime;Time(Eindx(ww),1)];
            end
        end
    else
        [indx,c]=find(MTable>=Threshold(1) & MTable<=(Threshold(2)-5/180*3.14));
        Sindx=indx([1;find(diff(indx)>10)+1]);
        Eindx=indx([(find(diff(indx)>10));end]);
        count=0;
        Stime=[];
        Etime=[];
        for ww=1:length(Sindx)
            if (MTable(Sindx(ww)+1)-MTable(Sindx(ww)))<0
                count=count+1;
                Stime=[Stime;Time(Sindx(ww),1)];
                Etime=[Etime;Time(Eindx(ww),1)];
            end
        end
    end
else
     fprintf('\nERROR: %s unknown trail ...\n\n', Trialname);
end
Events=[Stime,Etime];
end