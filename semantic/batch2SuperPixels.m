% Xinlei Chen
% CV Fall 2013 - Code for Batch mode superpixel computation
% Shows examples to:
%   1. Call the function imSuperPixels
%   2. Use the path/class information in msrc and icoseg (datapaths.mat)
%

%% Load data
load('datapaths.mat','msrc','icoseg');
%% Setting the parameters for your superpixel algorithm
options.sizeslic = 30;
options.reguslic = 1;

%% MSRC
datafile = './data/MSRC/';
datapath = msrc;

source = 'data/';
target = 'segments/'; 

sourcefile = datafile;
segfile = strrep(datafile,source,target);
disp(segfile);

if ~exist(segfile,'dir')
    mkdir(segfile);
end

for cate = datapath.cls'
    if ~exist([segfile,cate{1}],'dir')
        mkdir([segfile,cate{1}]);
    end
end

count = 1;
for i=1:datapath.lcls
    disp(datapath.cls{i});
    for j=1:length(datapath.allimgs{i})
        disp(datapath.allimgs{i}{j});
        filename = [segfile,datapath.cls{i},'/',strrep(strrep(datapath.allimgs{i}{j},'.jpg','.mat'),'.bmp','.mat')];
        if exist(filename,'file')
            continue;
        end
        image = imread([sourcefile,datapath.cls{i},'/',datapath.allimgs{i}{j}]);
        seg = imSuperPixels( image, options );
        save(filename,'seg');
        count = count + 1;
    end
end


%% iCoseg
datafile = './data/iCoseg/';
datapath = icoseg;

source = 'data/';
target = 'segments/'; 

sourcefile = datafile;
segfile = strrep(datafile,source,target);
disp(segfile);

if ~exist(segfile,'dir')
    mkdir(segfile);
end

for cate = datapath.cls'
    if ~exist([segfile,cate{1}],'dir')
        mkdir([segfile,cate{1}]);
    end
end

count = 1;
for i=1:datapath.lcls
    disp(datapath.cls{i});
    for j=1:length(datapath.allimgs{i})
        disp(datapath.allimgs{i}{j});
        filename = [segfile,datapath.cls{i},'/',strrep(strrep(datapath.allimgs{i}{j},'.jpg','.mat'),'.bmp','.mat')];
        if exist(filename,'file')
            continue;
        end
        image = imread([sourcefile,datapath.cls{i},'/',datapath.allimgs{i}{j}]);
        seg = imSuperPixels( image, options );
        save(filename,'seg');
        count = count + 1;
    end
end
