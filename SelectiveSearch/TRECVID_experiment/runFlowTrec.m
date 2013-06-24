%% run optical flow on VIDEO data (TRECVID 2013)

% add working path
addpath('../flow_code');
if (~isdeployed)
    addpath(genpath('../flow_code/utils'));
end

% 
flow_method = 'classic+nl-fast';
datasetfile = 'trec2012develtest_All_Merged_flow.txt';
TRECImgPath = '/home/zhenyang/Workspace/Data/TRECVID/TRECVID2013/trec2012develtest/%s';
TRECFlowImgPath = '/home/zhenyang/Workspace/Data/TRECVID/TRECVID2013/trec2012develtest_ofnext/%s';
TRECFlowPath = ['./TREC13/MyFlowMat/' flow_method '/%s.mat'];

% load ground truth images (merged from per class)
[Imgfiles, flowImgFiles, flowImgPositions]= textread(datasetfile,'%s %s %s');

for i=1:length(Imgfiles)
    fprintf('%d ', i);

    if (strcmp(flowImgPositions{i}, 'skip'))
        continue;
    elseif (strcmp(flowImgPositions{i}, 'next'))
        im1 = double(imread(sprintf(TRECImgPath, Imgfiles{i})));
        im2 = double(imread(sprintf(TRECFlowImgPath, flowImgFiles{i})));
        imflow = estimate_flow_interface(im1, im2, flow_method);
    elseif (strcmp(flowImgPositions{i}, 'pre'))
        im1 = double(imread(sprintf(TRECFlowImgPath, flowImgFiles{i})));
        im2 = double(imread(sprintf(TRECImgPath, Imgfiles{i})));
        imflow = estimate_flow_interface(im1, im2, flow_method);
    else
        printf('\nError: flow image position is not correct!!\n')
    end

    if (~isempty(imflow))

        flowfilename = sprintf(TRECFlowPath, Imgfiles{i});
        [ffpath,~,~]=fileparts(flowfilename);
        if (~exist(ffpath, 'dir'))
            mkdir(ffpath);
        end
        save(flowfilename, 'imflow');

    end

end