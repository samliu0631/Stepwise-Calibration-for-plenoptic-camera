function templateCell = CreateTemplate(radius)
    Num                             = size(radius,2);
    template_props                  = [];
    for i=1:Num
        template_props              = [template_props; [0 pi/2 radius(i); pi/4 -pi/4 radius(i)] ];
    end    
    TemplatetypeNum                 = size(template_props,1);
    templateCell                    = cell(TemplatetypeNum,1);
    for template_class = 1: TemplatetypeNum
        templateCell{template_class} = createCorrelationPatch(template_props(template_class,1),template_props(template_class,2),template_props(template_class,3));
    end
end