%% do evaluation for selective search
addpath('../');
addpath('../Dependencies/');
addpath('/home/zhenyang/Workspace/Data/TRECVID/TRECVID2013/anno_tools/TRECanno/');

gtClasses = {'Airplane', 'Boat_Ship', 'Bridges', 'Bus', 'Chair', ... 
             'Flags', 'Hand', 'Motorcycle', 'Quadruped', 'Telephones'};
datasetfile = 'trec2012develtest_All_Merged.txt';
% ss_strategy = 'selectivesearch-fast';
ss_strategy = 'magflow-simple';
% ss_strategy = 'selectivesearch+magflow-fast';
% ss_strategy = 'selectivesearch-simple';
TREC_gtBoxPath = '/home/zhenyang/Workspace/Data/TRECVID/TRECVID2013/trec2012local/Annotations';
TREC_ssBoxPath = ['./TREC13/MyBBoxesMat/' ss_strategy '/%s.mat'];
TREC_ssDefBoxPath = './TREC13/MyBBoxesMat/selectivesearch-fast/%s.mat';

% Load ground truth images (merged from per class)
mergedImgfiles = textread(datasetfile,'%s');

gtDataset = './GroundTruthTREC12develtest.mat';
% Load ground truth boxes and images and image names
if (~exist(gtDataset, 'file'))

    gtBoxes = cell(length(gtClasses), 1);
    gtImIds = cell(length(gtClasses), 1);

    for i=1:length(gtClasses)
        gtImgFiles=textread(sprintf([TREC_gtBoxPath '/trec2012develtest_%s_gt.txt'], gtClasses{i}), '%s');
        
        boxes = {};
        imids = {};  
        for k=1:length(gtImgFiles)
            record = TRECreadrecxml(sprintf([TREC_gtBoxPath '/' gtClasses{i} '/%s.xml'], gtImgFiles{k}));
            bbox = {record.objects.bbox};
            boxes{k} = cat(1, bbox{:});

            [lia, locb] = ismember(record.imgname, mergedImgfiles);
            if (~lia)
                fprintf('Error Message: Image file %s not found\n', record.imgname);
            end
            imids{k} = ones(length(bbox), 1) .* locb;
        end
        gtBoxes{i} = cat(1, boxes{:});
        gtImIds{i} = cat(1, imids{:});
    end

    save(gtDataset, 'gtBoxes', 'gtImIds');

else
    load(gtDataset);
end

% load selective search boxes
ssBoxes = cell(length(mergedImgfiles), 1); 
for j=1:length(mergedImgfiles)

    if (~exist(sprintf(TREC_ssBoxPath, mergedImgfiles{j}), 'file'))
        ldd = load(sprintf(TREC_ssDefBoxPath, mergedImgfiles{j}));
    else
        ldd = load(sprintf(TREC_ssBoxPath, mergedImgfiles{j}));
    end
    ssBoxes{j} = ldd.boxes(:, [2 1 4 3]);
end

[boxAbo boxMabo boScores avgNumBoxes] = BoxAverageBestOverlap(gtBoxes, gtImIds, ssBoxes);

boxRec = zeros(length(gtClasses), 1);
for i=1:length(boScores)
    boxRec(i) = sum(boScores{i} >= 0.5)/ length(boScores{i});
end
boxMrec = mean(boxRec);

