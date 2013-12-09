function [P, J, nPositive, nNegative] = evaluateClassUns(maskDir, gtDir, maskFiles)
% Xinlei Chen
% CV Fall 2013 - Provided Code for evaluation of a single class (unsupervised)
% Credit: Ce Liu, from http://people.csail.mit.edu/mrub/ObjectDiscovery/

nMasks = length(maskFiles);
    
PB = 0;
JB = 0;
nPositiveB = 0;

fig = figure;

for i = 1:nMasks
    [~,imageName] = fileparts(maskFiles{i});
    
    mask = readMask(maskDir, imageName);
    gtMask = readMask(gtDir, imageName);

    mask = double(mask(:,:,1) ~= 0);
    gtMask = double(gtMask(:,:,1) ~= 0);
    
    if ~all(imsize(mask) == imsize(gtMask))
        mask = imresize(mask, imsize(gtMask), 'nearest');
    end
    
    
    figure(fig);
    subplot(1,2,1); imagesc(mask); axis equal tight;
    xlabel('Result');
    subplot(1,2,2); imagesc(gtMask); axis equal tight;
    xlabel('Ground truth');
    colormap gray;
    subtitle(sprintf('Image %d/%d', i, nMasks));

    
    PB = PB + sum(gtMask(:)==mask(:)) ./ prod(imsize(gtMask));
    
    % Compute Jaccard only for images that contain an object
    if any(gtMask(:))
        JB = JB + sum( (mask(:)==1) & (gtMask(:)==1) ) ./ sum( (mask(:) | gtMask(:))==1 );
        nPositiveB = nPositiveB+1;
    end
end


PB = PB / nMasks;
JB = JB / nPositiveB;
nNegativeB = nMasks - nPositiveB;

PF = 0;
JF = 0;
nPositiveF = 0;

for i = 1:nMasks
    [~,imageName] = fileparts(maskFiles{i});
    
    mask = readMask(maskDir, imageName);
    gtMask = readMask(gtDir, imageName);

    mask = double(mask(:,:,1) == 0);
    gtMask = double(gtMask(:,:,1) ~= 0);
    
    if ~all(imsize(mask) == imsize(gtMask))
        mask = imresize(mask, imsize(gtMask), 'nearest');
    end
    
    
    figure(fig);
    subplot(1,2,1); imagesc(mask); axis equal tight;
    xlabel('Result');
    subplot(1,2,2); imagesc(gtMask); axis equal tight;
    xlabel('Ground truth');
    colormap gray;
    subtitle(sprintf('Image %d/%d', i, nMasks));

    
    PF = PF + sum(gtMask(:)==mask(:)) ./ prod(imsize(gtMask));
    
    % Compute Jaccard only for images that contain an object
    if any(gtMask(:))
        JF = JF + sum( (mask(:)==1) & (gtMask(:)==1) ) ./ sum( (mask(:) | gtMask(:))==1 );
        nPositiveF = nPositiveF+1;
    end
end

PF = PF / nMasks;
JF = JF / nPositiveF;
nNegativeF = nMasks - nPositiveF;

if PB > PF
    P = PB;
    J = JB;
    nPositive = nPositiveB;
    nNegative = nNegativeB;
else
    P = PF;
    J = JF;
    nPositive = nPositiveF;
    nNegative = nNegativeF;
end

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
