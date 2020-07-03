function OrientScoreAve = CalculateOrientationConsistency(v1,v2)
    num           = size(v1,1);
    numCounter    = 0;
    OrientScore   = 0;
    if num >0
        for i=1:num-1
            for j=i+1:num
                v1_pre   = v1(i,:);
                v1_next  = v1(j,:);
                v2_next  = v2(j,:);
                crossResult1 =cross([v1_pre,0],[v1_next,0]);
                crossResult2 =cross([v1_pre,0],[v2_next,0]);
                cross1 =norm(crossResult1);
                cross2 =norm(crossResult2);
                OrientScore= OrientScore+min(cross1 ,cross2);
                numCounter = numCounter+1;
            end
        end
        OrientScoreAve =OrientScore/numCounter;
    else
        OrientScoreAve = nan;
    end

end 