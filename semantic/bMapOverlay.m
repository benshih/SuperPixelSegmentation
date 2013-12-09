function image = bMapOverlay( image, bmap, color )
% Xinlei Chen
% CV Fall 2013 - Provided Code
% Overlay the boundary map computed from seg2Bmap to the original image
%
% Input:
%   image - the original image
%   bmap - binary boundary map denoting segment boundaries
%   color - optional, denoting the color of the boundary
% Output:
%   image - the overlayed image

if nargin < 3
    color = [255,0,255];
end

[h,w,~] = size(image);
image = reshape(image,[],3);

idx = find(bmap(:)>0);

image(idx,1) = color(1);
image(idx,2) = color(2);
image(idx,3) = color(3);

image = reshape(image,[h,w,3]);

end

