% Copyright 2012. All rights reserved.
% Author: Andreas Geiger
%         Institute of Measurement and Control Systems (MRT)
%         Karlsruhe Institute of Technology (KIT), Germany

% This is free software; you can redistribute it and/or modify it under the
% terms of the GNU General Public License as published by the Free Software
% Foundation; either version 3 of the License, or any later version.

% This software is distributed in the hope that it will be useful, but WITHOUT ANY
% WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
% PARTICULAR PURPOSE. See the GNU General Public License for more details.

% You should have received a copy of the GNU General Public License along with
% this software; if not, write to the Free Software Foundation, Inc., 51 Franklin
% Street, Fifth Floor, Boston, MA 02110-1301, USA

function [corners1,corners2] = findCorners(img,templateCell,tau)

    % convert to double grayscale image
    img = im2double(img);
    if length(size(img))==3
        img = rgb2gray(img);
    end

    % scale input image
    img     = double(img);
    img_min = min(img(:));
    img_max = max(img(:));
    img     = (img-img_min)/(img_max-img_min);

    %disp('Filtering ...');
    img_corners1 = zeros(size(img,1),size(img,2));
    img_corners2 = zeros(size(img,1),size(img,2));
    for template_class=  1:size(templateCell,1)

        % create correlation template
        template = templateCell{template_class};

        % filter image according with current template
        img_corners_a1 = conv2(img,template.a1,'same');
        img_corners_a2 = conv2(img,template.a2,'same');
        img_corners_b1 = conv2(img,template.b1,'same');
        img_corners_b2 = conv2(img,template.b2,'same');

        % add mask to increase the response of corner near the edge.
        
        
        
        % compute mean
        img_corners_mu = (img_corners_a1+img_corners_a2+img_corners_b1+img_corners_b2)/4;

        % case 1: a=white, b=black
        img_corners_a = min(img_corners_a1-img_corners_mu,img_corners_a2-img_corners_mu);
        img_corners_b = min(img_corners_mu-img_corners_b1,img_corners_mu-img_corners_b2);
        img_corners_1 = min(img_corners_a,img_corners_b);

        % case 2: b=white, a=black
        img_corners_a = min(img_corners_mu-img_corners_a1,img_corners_mu-img_corners_a2);
        img_corners_b = min(img_corners_b1-img_corners_mu,img_corners_b2-img_corners_mu);
        img_corners_2 = min(img_corners_a,img_corners_b);
        
        if mod(template_class,2)~=0
            % update corner map
            img_corners1 = max(img_corners1,img_corners_1);
            img_corners1 = max(img_corners1,img_corners_2);
        else
            % update corner map
            img_corners2 = max(img_corners2,img_corners_1);
            img_corners2 = max(img_corners2,img_corners_2);
        end
    end

    corners1.p = nonMaximumSuppression(img_corners1,3,tau,5);
    %figure; imshow(img); hold on; plot(corners1.p(:,1),corners1.p(:,2),'*');hold off;
    if isempty(corners1.p)
        corners1.response = [];
    else
        corners1.response = img_corners1((corners1.p(:,1)-1).*size(img,1)+corners1.p(:,2));
    end
    
    corners2.p = nonMaximumSuppression(img_corners2,3,tau,5);
    %figure; imshow(img); hold on; plot(corners2.p(:,1),corners2.p(:,2),'*');hold off;
    if isempty(corners2.p)
        corners2.response = [];
    else
        corners2.response = img_corners2((corners2.p(:,1)-1).*size(img,1)+corners2.p(:,2));
    end

end



