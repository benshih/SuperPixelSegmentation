function [P, J, classes] = evaluateDataset(resultDir, datasetname, datasetinfo)
% Xinlei Chen
% CV Fall 2013 - Provided Code for evaluation of a dataset
% Credit: Ce Liu, from http://people.csail.mit.edu/mrub/ObjectDiscovery/

classes = datasetinfo.cls;
nClasses = length(classes);

P = zeros(1, nClasses);
J = zeros(1, nClasses);

for i = 1:nClasses
    class = classes{i};
    disp(class);
    
    maskDir = fullfile(resultDir, datasetname, class);
    gtDir = fullfile('data', datasetname, class, 'GroundTruth');
    
    [P(i), J(i)] = evaluateClass(maskDir, gtDir, datasetinfo.testimgs{i});
end

