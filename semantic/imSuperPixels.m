function seg = imSuperPixels( image, options )
% Xinlei Chen
% CV Fall 2013 - Provided Code (You can modify it to wrap other superpixel algorithms)
% Given an image, get a superpixel representation as output
%
% Input:
%   image - the image
%   options - optional, if not exist, this function will use a default
%   setting of parameters to compute superpixels, you can also use it to
%   tune parameters (see examplar usage in batch2SuperPixels.m)

% Output:
%   seg - the superpixel output

if nargin < 2
    options = [];
end

%% This section can be modified!
% example to add parameters for superpixel computing, in this case (SLIC) it is the number of clusters
sizeslic = 100;
if isfield(options,'sizeslic')
    sizeslic = options.sizeslic;
end

reguslic = 1;
if isfield(options,'reguslic')
    reguslic = options.reguslic;
end

image = RGB2Lab(image) ;
seg = slicwrapper(single(image), sizeslic, reguslic);

end

