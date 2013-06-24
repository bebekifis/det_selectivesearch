%% do evaluation for selective search
addpath('../');
addpath('../Dependencies/');

gtClasses = {'Airplane', 'Boat_Ship', 'Bridges', 'Bus', 'Chair', ... 
             'Flags', 'Hand', 'Motorcycle', 'Quadruped', 'Telephones'};

datasetfile = 'trec2012develtest_All_Merged.txt';
% ss_strategy = 'selectivesearch-fast';
% ss_strategy = 'flow-simple';
ss_strategy = 'selectivesearch+flow-fast';
TRECImgPath = '/home/zhenyang/Workspace/Data/TRECVID/TRECVID2013/trec2012develtest/%s';
TREC_gtBoxPath = '/home/zhenyang/Workspace/Data/TRECVID/TRECVID2013/trec2012local/Annotations';
TREC_ssBoxPath = './TREC13/MyBBoxesMat/selectivesearch-fast/%s.mat';
TREC_ssFlowBoxPath = ['./TREC13/MyBBoxesMat/' ss_strategy '/%s.mat'];

% Load ground truth images (merged from per class)
mergedImgfiles = textread(datasetfile,'%s');

% Load ground truth boxes and images and image names
gtDataset = './GroundTruthTREC12develtest.mat';
load(gtDataset);
% gtBoxes, gtImIds

% load selective search boxes
ssBoxes = cell(length(mergedImgfiles), 1);
ssfBoxes = cell(length(mergedImgfiles), 1); 

for i=1:length(mergedImgfiles)
    ldd = load(sprintf(TREC_ssBoxPath, mergedImgfiles{i}));
    ssBoxes{i} = ldd.boxes(:, [2 1 4 3]);
end

for i=1:length(mergedImgfiles)

    if (~exist(sprintf(TREC_ssFlowBoxPath, mergedImgfiles{i}), 'file'))
        ldd = load(sprintf(TREC_ssBoxPath, mergedImgfiles{i}));
    else
        ldd = load(sprintf(TREC_ssFlowBoxPath, mergedImgfiles{i}));
    end
    ssfBoxes{i} = ldd.boxes(:, [2 1 4 3]);
end




%% visualize 
for i=1:length(gtClasses)
    
    % force to specific class
    i = 10;
    
    gtImgFiles=textread(sprintf([TREC_gtBoxPath '/trec2012develtest_%s_gt.txt'], gtClasses{i}), '%s');
    
    uimids = unique(gtImIds{i}, 'stable');
    imids = gtImIds{i};
    boxes = gtBoxes{i};
    
    if(length(uimids) ~= length(gtImgFiles))
        fprintf('Error Message: Image Ids and Files do not match');
    end
    
    for j=1:length(gtImgFiles)
        
        gtbox = boxes(imids==uimids(j), :);
        ssbox = ssBoxes{uimids(j)};
        ssfbox = ssfBoxes{uimids(j)};
        im=imread(sprintf(TRECImgPath, gtImgFiles{j}));
        
        %figure;
        imshow(im);
        
        for k=1:size(gtbox, 1)
            
            [score1, idx1] = BoxBestOverlap(gtbox(k, :), ssbox);
            [score2, idx2] = BoxBestOverlap(gtbox(k, :), ssfbox);
            xl_drawbox(gtbox(k, :), [1,0,0], 3);
            xl_drawbox(ssbox(idx1, :), [0,0,1], 3);
            xl_drawbox(ssfbox(idx2, :), 'yellow', 3);

        end
        
        drawnow;
        
        % pause
        but = 0;
        while(but ~= 32)
            [~,~,but]=ginput(1);
        end
        
    end
end

