%% run Selective Search on VIDEO data (TRECVID 2013)

% add working path
addpath('../');
addpath('../Dependencies/');

% Parameters. Note that this controls the number of hierarchical
% segmentations which are combined.
colorTypes = {'Hsv', 'Lab', 'RGI', 'H', 'Intensity'};

% Here you specify which similarity functions to use in merging
simFunctionHandles = {@SSSimColourTextureSizeFillOrig, @SSSimTextureSizeFill, @SSSimBoxFillOrig, @SSSimSize};

% Thresholds for the Felzenszwalb and Huttenlocher segmentation algorithm.
% Note that by default, we set minSize = k, and sigma = 0.8.
ks = [50 100 150 300]; % controls size of segments of initial segmentation. 
sigma = 0.8;

% After segmentation, filter out boxes which have a width/height smaller
% than minBoxWidth (default = 20 pixels).
% minBoxWidth = 10;

% Comment the following three lines for the 'quality' version
colorTypes = colorTypes(1:2); % 'Fast' uses HSV and Lab
simFunctionHandles = simFunctionHandles(1:2); % Two different merging strategies
ks = ks(1:2);

% generate the boxes
datasetfile = 'trec2012develtest_All_Merged.txt';
ss_strategy = 'selectivesearch_fast';
TRECImgPath = '/home/zhenyang/Workspace/Data/TRECVID/TRECVID2013/trec2012develtest/%s';
TRECBoxPath = ['./TREC13/MyBBoxesMat/' ss_strategy '/%s.mat'];
% fprintf('After box extraction, boxes smaller than %d pixels will be removed\n', minBoxWidth);
fprintf('Obtaining boxes for Trecvid 2013 devel and test set:\n');

tic;
imgfiles=textread(datasetfile,'%s');
for i=1:length(imgfiles)
    fprintf('%d ', i);
    
    % 
    im = imread(sprintf(TRECImgPath, imgfiles{i}));
    idx = 1;
    for j=1:length(ks)
        k = ks(j); % Segmentation threshold k
        minSize = k; % We set minSize = k
        for n = 1:length(colorTypes)
            colorType = colorTypes{n};
            [boxesT{idx} blobIndIm blobBoxes hierarchy priorityT{idx}] = Image2HierarchicalGrouping(im, sigma, k, minSize, colorType, simFunctionHandles);

            idx = idx + 1;
        end
    end
    boxes = cat(1, boxesT{:}); % Concatenate boxes from all hierarchies
    priority = cat(1, priorityT{:}); % Concatenate priorities
    
    % Do pseudo random sorting as in paper
    priority = priority .* rand(size(priority));
    [priority sortIds] = sort(priority, 'ascend');
    boxes = boxes(sortIds,:);

    % boxes = FilterBoxesWidth(boxes, minBoxWidth);
    boxes = BoxRemoveDuplicates(boxes);

    bfilename = sprintf(TRECBoxPath, imgfiles{i});
    [bfpath,~,~]=fileparts(bfilename);
    if (~exist(bfpath, 'dir'))
        mkdir(bfpath);
    end
    save(bfilename, 'boxes');
end
toc



