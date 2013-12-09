function out = randomColor(labels)
% Xinlei Chen
% CV Fall 2013 - Provided Code
% Randomly pick colors for segments given a segmentation for visualization
%
% Input:
%   labels - segmentation output, should be of size H x W where H is the
%            height, and W is the width
% Output:
%   out - the colored segmenation

[h w] = size(labels);

rimg = zeros(h,w);
gimg = zeros(h,w);
bimg = zeros(h,w);

mc = unique(labels(:))';

for i=mc
    idx = find(labels==i);
    rimg(idx) = round(rand * 255);
    gimg(idx) = round(rand * 255);
    bimg(idx) = round(rand * 255);
end

out = uint8(cat(3,rimg,gimg,bimg));

end