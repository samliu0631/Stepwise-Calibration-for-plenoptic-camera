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

function corners = refineCorners(img_du,img_dv,corners,r,GridCoords,LensRadius)
    % image dimensions
    width  = size(img_du,2);
    height = size(img_dv,1);
    
    % Lens center coordinates
    %GridCoordsX = GridCoords(:,:,1);
    %GridCoordsY = GridCoords(:,:,2);
    
    % for all corners do
    for i=1:size(corners.p,1)  
      % extract current corner location
      cu = corners.p(i,1);
      cv = corners.p(i,2);

      % get orientation.
      v1  = corners.v1(i,:);
      v2  = corners.v2(i,:);
      
      
      % get lens center coordinates within ROI. 
%       LensCoords       = [GridCoordsX(corners.LensID(i)),GridCoordsY(corners.LensID(i))];
%       LensCoordsInROI  = LensCoords+corners.p(i,1:2)-corners.pImg(i,1:2);
%       dist             = sqrt( sum( ([cu,cv]-LensCoordsInROI).^2 , 2 ) );
%       r                = round(LensRadius-dist);
      
      
      % continue, if invalid edge orientations
      if v1(1)==0 && v1(2)==0 || v2(1)==0 && v2(2)==0
        continue;
      end

      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      % corner orientation refinement %
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

      A1 = zeros(2,2);
      A2 = zeros(2,2);
        
      
      for u=max(cu-r,1):min(cu+r,width)
        for v=max(cv-r,1):min(cv+r,height)
          % validate that the pixel is in the micro-image. %added by sam
%           dist = sqrt(sum(([u,v]-LensCoordsInROI).^2,2));  
%           if dist > (LensRadius-EdgeWidth)
%               continue;
%           end
          % pixel orientation vector
          o = [img_du(v,u) img_dv(v,u)];
          if norm(o)<0.1
            continue;
          end
          o = o/norm(o);

          % robust refinement of orientation 1
          if abs(o*v1')<0.25 % inlier?
            A1(1,:) = A1(1,:) + img_du(v,u) * [img_du(v,u) img_dv(v,u)];
            A1(2,:) = A1(2,:) + img_dv(v,u) * [img_du(v,u) img_dv(v,u)];
          end

          % robust refinement of orientation 2
          if abs(o*v2')<0.25 % inlier?
            A2(1,:) = A2(1,:) + img_du(v,u) * [img_du(v,u) img_dv(v,u)];
            A2(2,:) = A2(2,:) + img_dv(v,u) * [img_du(v,u) img_dv(v,u)];
          end

        end
      end

      % set new corner orientation
      [v1,foo1] = eig(A1); v1 = v1(:,1)'; corners.v1(i,:) = v1;
      [v2,foo2] = eig(A2); v2 = v2(:,1)'; corners.v2(i,:) = v2;

      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      %  corner location refinement  %
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

      G = zeros(2,2);
      b = zeros(2,1);
      for u=max(cu-r,1):min(cu+r,width)
        for v=max(cv-r,1):min(cv+r,height)
%           dist = sqrt(sum(([u,v]-LensCoordsInROI).^2,2));  
%           if dist > (LensRadius-EdgeWidth)
%               continue;
%           end
          % pixel orientation vector
          o = [img_du(v,u) img_dv(v,u)];
          if norm(o)<0.1
            continue;
          end
          o = o/norm(o);

          % robust subpixel corner estimation
          if u~=cu || v~=cv % do not consider center pixel

            % compute rel. position of pixel and distance to vectors
            w  = [u v]-[cu cv];
            d1 = norm(w-w*v1'*v1);
            d2 = norm(w-w*v2'*v2);

            % if pixel corresponds with either of the vectors / directions
            if d1<3 && abs(o*v1')<0.25 || d2<3 && abs(o*v2')<0.25
              du = img_du(v,u);
              dv = img_dv(v,u);
              H = [du dv]'*[du dv];

              G = G + H;
              b = b + H*[u v]';
            end
          end
        end
      end

      % set new corner location if G has full rank
      if rank(G)==2
        corner_pos_old = corners.p(i,:);
        corner_pos_new = (G\b)';
        corners.p(i,:) = corner_pos_new;

        % set corner to invalid, if position update is very large
        if norm(corner_pos_new-corner_pos_old)>=4
          corners.v1(i,:) = [0 0];
          corners.v2(i,:) = [0 0];
        end

      % otherwise: set corner to invalid
      else
        corners.v1(i,:) = [0 0];
        corners.v2(i,:) = [0 0];
      end
    end

end

