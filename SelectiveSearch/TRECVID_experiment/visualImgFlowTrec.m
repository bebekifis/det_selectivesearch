datasetfile = 'trec2012develtest_All_Merged_flow.txt';

TRECImgPath = '/home/zhenyang/Workspace/Data/TRECVID/TRECVID2013/trec2012develtest/%s';
TRECFlowImgPath = '/home/zhenyang/Workspace/Data/TRECVID/TRECVID2013/trec2012develtest_ofnext/%s';

% load ground truth images (merged from per class)
[Imgfiles, flowImgFiles, flowImgPositions]= textread(datasetfile,'%s %s %s');

for i=1:length(Imgfiles)
    fprintf('%d ', i);

    if (strcmp(flowImgPositions{i}, 'skip'))
        continue;
    elseif (strcmp(flowImgPositions{i}, 'next'))
        im1 = imread(sprintf(TRECImgPath, Imgfiles{i}));
        im2 = imread(sprintf(TRECFlowImgPath, flowImgFiles{i}));
    elseif (strcmp(flowImgPositions{i}, 'pre'))
        im1 = imread(sprintf(TRECFlowImgPath, flowImgFiles{i}));
        im2 = imread(sprintf(TRECImgPath, Imgfiles{i}));
    else
        printf('\nError: flow image position is not correct!!\n')
    end

    %figure;
    
    imshow(im1);
    pause(1)
    imshow(im2);
    
    %disp('Press any key to continue');
    %pause;
end