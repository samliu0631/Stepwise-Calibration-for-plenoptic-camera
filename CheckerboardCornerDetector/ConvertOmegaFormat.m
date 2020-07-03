function  OmegaCell = ConvertOmegaFormat(allOmega)
    FrameNum    = size(allOmega,1);
    OmegaCell   = cell(FrameNum,1);
    for i       = 1:FrameNum
        OmegaCollect        = [];
        OmegaCurrentFrame   = allOmega{i};
        CornerNum           = size(OmegaCurrentFrame,1);
        for j               = 1:CornerNum
            OmegaCurrent    = OmegaCurrentFrame{j};
            OmegaCollect    = [OmegaCollect;OmegaCurrent];
        end
        OmegaCell{i}        = OmegaCollect;    
    end
end