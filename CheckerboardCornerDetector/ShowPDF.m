function ShowPDF(Img_raw,Omiga,LensRadius)
    figure;imshow(Img_raw);
    hold on;
    plot(Omiga(1),Omiga(2),'r*');
    RadisPixel=abs(Omiga(3))*LensRadius;
    theta=0:pi/100:2*pi;
    x = RadisPixel*cos(theta)+Omiga(1);
    y = RadisPixel*sin(theta)+Omiga(2);
    plot(x,y);
    hold off;
end