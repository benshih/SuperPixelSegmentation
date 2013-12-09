function bmap = seg2Bmap(seg)
% Xinlei Chen
% CV Fall 2013 - Provided Code
% Get boundaries given a segmentation
%
% Input:
%   seg - segmentation output, should be of size H x W where H is the
%            height, and W is the width
% Output:
%   bmap - binary boundary map, with 1 pixel wide
%           boundaries.  The boundary pixels are offset by 1/2 pixel towards the
%           origin from the actual segment boundary.

[h,w] = size(seg);

e = zeros([h,w]);
s = zeros([h,w]);
se = zeros([h,w]);

e(:,1:end-1) = seg(:,2:end);
s(1:end-1,:) = seg(2:end,:);
se(1:end-1,1:end-1) = seg(2:end,2:end);

bmap = (seg~=e | seg~=s | seg~=se);
bmap(end,:) = (seg(end,:)~=e(end,:));
bmap(:,end) = (seg(:,end)~=s(:,end));
bmap(end) = 0;
  
end
