%% run Selective Search with Optical Flow (motion) on VIDEO data (TRECVID 2013)

% add working path
addpath('../');
addpath('../Dependencies/');

% Parameters. Note that this controls the number of hierarchical
% segmentations which are combined.
colorTypes = {'Hsv', 'Lab', 'RGI', 'H', 'Intensity'};

% Here you specify which similarity functions to use in merging
% simFunctionHandles = {@SSSimColourTextureSizeFillOrig, @SSSimTextureSizeFill, @SSSimBoxFillOrig, @SSSimSize};
% simFunctionHandles = {@SSSimColourTextureFlowSizeFillOrig, @SSSimTextureFlowSizeFill};
% simFunctionHandles = {@SSSimColourSize, @SSSimFlowSize, @SSSimColourFlowSize};
% simFunctionHandles = {@SSSimColourSize, @SSSimTextureSize, @SSSimColourTextureSize};
simFunctionHandles = {@SSSimFlowSize};

% Thresholds for the Felzenszwalb and Huttenlocher segmentation algorithm.
% Note that by default, we set minSize = k, and sigma = 0.8.
ks = [50 100 150 300]; % controls size of segments of initial segmentation. 
sigma = 0.8;

% After segmentation, filter out boxes which have a width/height smaller
% than minBoxWidth (default = 20 pixels).
% minBoxWidth = 10;

% Comment the following three lines for the 'quality' version
% colorTypes = colorTypes(1:2); % 'Fast' uses HSV and Lab
% simFunctionHandles = simFunctionHandles(1:2); % Two different merging strategies
% ks = ks(1:2);

% Single strategy
colorTypes = colorTypes(1);
ks = ks(1);

% generate the boxes
datasetfile = 'trec2012develtest_All_Merged.txt';

% ss_strategy = 'selectivesearch+flow-fast';
% ss_strategy = 'flow-simple';
% ss_strategy = 'selectivesearch-simple';
ss_strategy = 'FoS';

flow_method = 'classic+nl-fast';
TRECImgPath = '/home/zhenyang/Workspace/data/TRECVID/TRECVID2013/trec2012develtest/%s';
TRECFlowPath = ['./TREC13/MyFlowMat/' flow_method '/%s.mat'];
TRECBoxPath = ['./TREC13/MyBBoxesMat/' ss_strategy '/%s.mat'];
% fprintf('After box extraction, boxes smaller than %d pixels will be removed\n', minBoxWidth);
fprintf('Obtaining boxes for Trecvid 2013 devel and test set:\n');

tic;
nbSkips = 0;
imgfiles=textread(datasetfile,'%s');
for i=1:length(imgfiles)
    fprintf('%d ', i);
    
    % check if exist
    bfilename = sprintf(TRECBoxPath, imgfiles{i});
    if (exist(bfilename, 'file'))
        continue;
    end

    % load image and flow data
    im = imread(sprintf(TRECImgPath, imgfiles{i}));
    if (~exist(sprintf(TRECFlowPath, imgfiles{i}), 'file'))
        fprintf('\nSkip %s, since no flow data found!\n', imgfiles{i});
        nbSkips = nbSkips + 1;
        continue;
    end
    
    load(sprintf(TRECFlowPath, imgfiles{i}));
    if (~sum(sum(sum(imflow))))
        fprintf('\nSkip %s, since flow data is all zeros!\n', imgfiles{i});
        nbSkips = nbSkips + 1;
        continue;
    end
    flowIm = NormalizeArray(imflow); % Make range [0 1].
    % magnitudeFlow = sqrt(imflow(:,:,1) .* imflow(:,:,2));
    % flowIm = NormalizeArray(magnitudeFlow);

    idx = 1;
    for j=1:length(ks)
        k = ks(j); % Segmentation threshold k
        minSize = k; % We set minSize = k
        for n = 1:length(colorTypes)
            colorType = colorTypes{n};

            % image version
            % [boxesT{idx} blobIndIm blobBoxes hierarchy priorityT{idx}] = ... 
            %             Image2HierarchicalGrouping(im, sigma, k, minSize, colorType, simFunctionHandles);

            % video version
            [colourIm] = Image2ColourSpace(im, colorType);

            % image channels for initial over-segmentation
            segmentIm = cat(3, colourIm, NormalizeArray(flowIm));

            [boxesT{idx} blobIndIm blobBoxes hierarchy priorityT{idx}] = VideoFrame2HierarchicalGrouping( ... 
                                colourIm, flowIm, segmentIm, sigma, k, minSize, colorType, simFunctionHandles);
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

    % bfilename = sprintf(TRECBoxPath, imgfiles{i});
    [bfpath,~,~]=fileparts(bfilename);
    if (~exist(bfpath, 'dir'))
        mkdir(bfpath);
    end
    save(bfilename, 'boxes');
end

fprintf('Skipped totally %d frames:\n', nbSkips);

toc
