function [v1,v2] = edgeOrientations(img_angle,img_weight)

% init v1 and v2
v1 = [0 0];
v2 = [0 0];

% number of bins (histogram parameter)
bin_num = 32;

% convert images to vectors
vec_angle  = img_angle(:);
vec_weight = img_weight(:);

% convert angles from normals to directions
vec_angle = vec_angle+pi/2;
vec_angle(vec_angle>pi) = vec_angle(vec_angle>pi)-pi;

% create histogram
angle_hist = zeros(1,bin_num);
for i=1:length(vec_angle)
  bin = max(min(floor(vec_angle(i)/(pi/bin_num)),bin_num-1),0)+1;
  angle_hist(bin) = angle_hist(bin)+vec_weight(i);
end

% find modes of smoothed histogram
[modes,angle_hist_smoothed] = findModesMeanShift(angle_hist,1);

% if only one or no mode => return invalid corner
if size(modes,1)<=1
  return;
end

% compute orientation at modes
modes(:,3) = (modes(:,1)-1)*pi/bin_num;

% extract 2 strongest modes and sort by angle
modes = modes(1:2,:);
[foo idx] = sort(modes(:,3),1,'ascend');
modes = modes(idx,:);

% compute angle between modes
delta_angle = min(modes(2,3)-modes(1,3),modes(1,3)+pi-modes(2,3));

% if angle too small => return invalid corner
if delta_angle<=0.3
  return;
end

% set statistics: orientations
v1 = [cos(modes(1,3)) sin(modes(1,3))];
v2 = [cos(modes(2,3)) sin(modes(2,3))];
