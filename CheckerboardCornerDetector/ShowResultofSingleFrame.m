
function ShowResultofSingleFrame(Img_raw,CellCornerInfoPerFrame)
    CornerNum = size(CellCornerInfoPerFrame);
    figure;imshow(Img_raw);hold on;
    for i = 1: CornerNum
        CornerInfo  = CellCornerInfoPerFrame{i};
        if  ~isempty(CornerInfo)
            CornerCoords = CornerInfo(:,1:2);
            plot(CornerCoords(:,1),CornerCoords(:,2),'*');
        end        
    end
    hold off;
end