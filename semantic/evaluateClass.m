function [P, J, nPositive, nNegative] = evaluateClass(maskDir, gtDir, maskFiles)
% Xinlei Chen
% CV Fall 2013 - Provided Code for evaluation of a single class
% Credit: Ce Liu, from http://people.csail.mit.edu/mrub/ObjectDiscovery/

nMasks = length(maskFiles);

P = 0;
J = 0;
nPositive = 0;

fig = figure;

for i = 1:nMasks
    [~,imageName] = fileparts(maskFiles{i});
    
    mask = readMask(maskDir, imageName);
    gtMask = readMask(gtDir, imageName);

    mask = double(mask(:,:,1) ~= 0);
    gtMask = double(gtMask(:,:,1) ~= 0);
    
    if ~all(size(mask(:,:,1)) == size(gtMask(:,:,1)))
        mask = imresize(mask, size(gtMask(:,:,1)), 'nearest');
    end
    
    
    figure(fig);
    subplot(1,2,1); imagesc(mask); axis equal tight;
    xlabel('Result');
    subplot(1,2,2); imagesc(gtMask); axis equal tight;
    xlabel('Ground truth');
    colormap gray;
    subtitle(sprintf('Image %d/%d', i, nMasks));

    
    P = P + sum(gtMask(:)==mask(:)) ./ numel(gtMask(:,:,1));
    
    % Compute Jaccard only for images that contain an object
    if any(gtMask(:))
        J = J + sum( (mask(:)==1) & (gtMask(:)==1) ) ./ sum( (mask(:) | gtMask(:))==1 );
        nPositive = nPositive+1;
    end
end

P = P / nMasks;
J = J / nPositive;
nNegative = nMasks - nPositive;

close(fig);
end

function mask = readMask(maskDir, imageName)
% masks are stored as either png, bmp, or jpg
maskFile = [];
if exist(fullfile(maskDir, [imageName '.png']))
    maskFile = fullfile(maskDir, [imageName '.png']);
elseif exist(fullfile(maskDir, [imageName '.jpg']))
    maskFile = fullfile(maskDir, [imageName '.jpg']);
elseif exist(fullfile(maskDir, [imageName '.bmp']))
    maskFile = fullfile(maskDir, [imageName '.bmp']);
end
disp(maskFile);
mask = imread(maskFile);
mask = mask ~= 0;
end