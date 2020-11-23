function [stats] = statisticalInfo(stats, suffix, penumbraMask, coreMask, ...
    MANUAL_ANNOTATION_FOLDER, patient, indexImg, penumbra_color, core_color, ...
    flag_PENUMBRACORE, image_suffix, calculateTogether, THRESHOLDING)
%STATISTICALINFO Get statistics from patients and the corresponding
% ground truth
%   Function that get the statistics of each patient and their extraction
%   based on the corresponding ground truth images

pIndex = patient(end-1:end);
name = num2str(indexImg);
if length(name) == 1
    name = strcat('0', name);
end

if isa(penumbraMask,'uint16')
    penumbraMask = penumbraMask./256;
    penumbraMask(penumbraMask>core_color-(penumbra_color/4)) = core_color;
    penumbraMask(penumbraMask<penumbra_color+(penumbra_color/4) & penumbraMask>90) = penumbra_color;
    penumbraMask(penumbraMask<90 & penumbraMask>0) = penumbra_color/2; % brain color
end

if THRESHOLDING
    coreMask = double(coreMask);
    penumbraMask = double(penumbraMask);
end

%% load the correct annotation image
filename = strcat(MANUAL_ANNOTATION_FOLDER, 'Patient', pIndex, '/', pIndex , name, image_suffix);
if ~isfile(filename)
    filename = strcat(MANUAL_ANNOTATION_FOLDER, patient, "/", name, image_suffix);
end

Igray = imread(filename);
if ndims(Igray)==3
    Igray = rgb2gray(Igray);
end

if isa(Igray,'uint16')
    Igray = Igray./256;    
    Igray(Igray>core_color-(penumbra_color/4)) = core_color;
    Igray(Igray<penumbra_color+(penumbra_color/4) & Igray>90) = penumbra_color;
    Igray(Igray<90 & Igray>0) = penumbra_color/2; % brain color
end

index_no_back = find(Igray~=0); %% 0==background!

if calculateTogether
    penumbraMask_reshape = reshape(penumbraMask, 1, []);
    Igray = reshape(Igray, 1, []);
    penumbraMask_noback = penumbraMask_reshape(index_no_back);
    Igray_noback = Igray(index_no_back);
    
    order = double(unique([unique(Igray),unique(penumbraMask_reshape)]));
    idx_brain = find(order==penumbra_color/2); % brain color
    idx_penumbra = find(order==penumbra_color);
    idx_core = find(order==core_color);
    
    order_noback = double(unique([unique(penumbraMask_noback),unique(Igray_noback)]));
    idx_b_nb = find(order_noback==penumbra_color/2);
    idx_p_nb = find(order_noback==penumbra_color);
    idx_c_nb = find(order_noback==core_color);
    
    CM = confusionmat(Igray, penumbraMask_reshape);
    CM_noback = confusionmat(Igray_noback, penumbraMask_noback);
    
    % TN, FN, FP, TP
    if ~isempty(idx_brain)
        tp = CM(idx_brain,idx_brain);
        fp = sum(CM(:,idx_brain))-tp;
        fn = sum(CM(idx_brain,:))-tp;
        tn = sum(CM,"all")-tp-fp-fn;
        CM_brain = [tn,fp;fn,tp];
    else
        CM_brain = double(reshape([0,0,0,0], 2,2));
    end
    if ~isempty(idx_b_nb)
        tp = CM_noback(idx_b_nb,idx_b_nb);
        fp = sum(CM_noback(:,idx_b_nb))-tp;
        fn = sum(CM_noback(idx_b_nb,:))-tp;
        tn = sum(CM_noback,"all")-tp-fp-fn;
        CM_brain_noback = [tn,fp;fn,tp];
    else
        CM_brain_noback = double(reshape([0,0,0,0], 2,2));
    end
    if ~isempty(idx_penumbra) 
        tp = CM(idx_penumbra,idx_penumbra);
        fp = sum(CM(:,idx_penumbra))-tp;
        fn = sum(CM(idx_penumbra,:))-tp;
        tn = sum(CM,"all")-tp-fp-fn;
        CM_penumbra = [tn,fp;fn,tp];
    else
        CM_penumbra = double(reshape([0,0,0,0], 2,2));
    end
    if ~isempty(idx_p_nb) 
        tp = CM_noback(idx_p_nb,idx_p_nb);
        fp = sum(CM_noback(:,idx_p_nb))-tp;
        fn = sum(CM_noback(idx_p_nb,:))-tp;
        tn = sum(CM_noback,"all")-tp-fp-fn;
        CM_penumbra_noback = [tn,fp;fn,tp];
    else
        CM_penumbra_noback = double(reshape([0,0,0,0], 2,2));
    end
    
    if  ~isempty(idx_core)
        tp = CM(idx_core,idx_core);
        fp = sum(CM(:,idx_core))-tp;
        fn = sum(CM(idx_core,:))-tp;
        tn = sum(CM,"all")-tp-fp-fn;
        CM_core = [tn,fp;fn,tp];
    else
        CM_core = double(reshape([0,0,0,0], 2,2));
    end
    if ~isempty(idx_c_nb)
        tp = CM_noback(idx_c_nb,idx_c_nb);
        fp = sum(CM_noback(:,idx_c_nb))-tp;
        fn = sum(CM_noback(idx_c_nb,:))-tp;
        tn = sum(CM_noback,"all")-tp-fp-fn;
        CM_core_noback = [tn,fp;fn,tp];
    else
        CM_core_noback = double(reshape([0,0,0,0], 2,2));
    end   
else
    I_penumbra = double(Igray==penumbra_color); % PENUMBRA COLOR
    I_penumbra_no_back = double(Igray(index_no_back)==penumbra_color); % PENUMBRA COLOR

    I_core = double(Igray==core_color); % CORE COLOR
    I_core_no_back = double(Igray(index_no_back)==core_color); % CORE COLOR

    if flag_PENUMBRACORE
        I_penumbraCore = I_penumbra+I_core;
        penumbraCoreMask = penumbraMask+coreMask;
        I_penumbraCore = double(I_penumbraCore>=1);
        penumbraCoreMask = double(penumbraCoreMask>=1);
        I_penumbraCore_reshape = reshape(I_penumbraCore, 1,[]);
        penumbraCoreMask_reshape = reshape(penumbraCoreMask, 1,[]);
    end

    penumbraMask_noback =  penumbraMask(index_no_back);
    penumbraMask_reshape = reshape(penumbraMask,1,[]);
    I_penumbra_reshape = reshape(I_penumbra,1,[]);

    coreMask_noback =  coreMask(index_no_back);
    coreMask_reshape = reshape(coreMask,1,[]);
    I_core_reshape = reshape(I_core,1,[]);

    if flag_PENUMBRACORE
        I_penumbraCore_no_back = I_penumbra_no_back+I_core_no_back;
        I_penumbraCore_no_back = double(I_penumbraCore_no_back>=1);
        penumbraCoreMask_noback = penumbraMask_noback+coreMask_noback;
        penumbraCoreMask_noback = double(penumbraCoreMask_noback>=1);
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% Confusion matrices
    CM_penumbra = confusionmat(I_penumbra_reshape,penumbraMask_reshape);
    if numel(CM_penumbra)==1
        CM_penumbra = double(reshape([CM_penumbra, 0, 0, 0], 2,2));
    end
    CM_core = confusionmat(I_core_reshape,coreMask_reshape);
    if numel(CM_core)==1
        CM_core = double(reshape([CM_core, 0, 0, 0], 2,2));
    end

    if flag_PENUMBRACORE
        CM_brain = confusionmat(I_penumbraCore_reshape,penumbraCoreMask_reshape); % CM_penumbra+CM_core;
        if numel(CM_brain)==1
            CM_brain = double(reshape([CM_brain, 0, 0, 0], 2,2));
        end
    else
        CM_brain = double(reshape([0,0,0,0], 2,2));
    end

    CM_penumbra_noback = confusionmat(I_penumbra_no_back, penumbraMask_noback);
    if numel(CM_penumbra_noback)==1
        CM_penumbra_noback = double(reshape([CM_penumbra_noback, 0, 0, 0], 2,2));
    end
    CM_core_noback = confusionmat(I_core_no_back, coreMask_noback);
    if numel(CM_core_noback)==1
        CM_core_noback = double(reshape([CM_core_noback, 0, 0, 0], 2,2));
    end

    if flag_PENUMBRACORE
        CM_brain_noback = confusionmat(I_penumbraCore_no_back,penumbraCoreMask_noback); % CM_penumbra_noback+CM_core_noback;
        if numel(CM_brain_noback)==1
            CM_brain_noback = double(reshape([CM_brain_noback, 0, 0, 0], 2,2));
        end
    else
        CM_brain_noback = double(reshape([0,0,0,0], 2,2));
    end

    % check if noback are empty
    if isempty(CM_penumbra_noback)
        CM_penumbra_noback = [0,0;0,0];
    end
    if isempty(CM_core_noback)
        CM_core_noback = [0,0;0,0];
    end
    if isempty(CM_brain_noback)
        CM_brain_noback = [0,0;0,0];
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% table structure:
% table("name", "tn_p", "fn_p", "fp_p", "tp_p", "tn_c", "fn_c", "fp_c", "tp_c", "tn_pc", "fn_pc", "fp_pc", "tp_pc" "auc_p" "auc_c" "auc_pc");
rowToAdd = {suffix, ...
    CM_penumbra(1,1), ... "tn_p"
    CM_penumbra(2,1), ... "fn_p"
    CM_penumbra(1,2), ... "fp_p"
    CM_penumbra(2,2), ... "tp_p"
    CM_core(1,1), ... "tn_c"
    CM_core(2,1), ... "fn_c"
    CM_core(1,2), ... "fp_c"
    CM_core(2,2), ... "tp_c"
    CM_brain(1,1), ... "tn_pc"
    CM_brain(2,1), ... "fn_pc"
    CM_brain(1,2), ... "fp_pc"
    CM_brain(2,2), ... "tp_pc"
    CM_penumbra_noback(1,1), ... "tn_p"
    CM_penumbra_noback(2,1), ... "fn_p"
    CM_penumbra_noback(1,2), ... "fp_p"
    CM_penumbra_noback(2,2), ... "tp_p"
    CM_core_noback(1,1), ... "tn_c"
    CM_core_noback(2,1), ... "fn_c"
    CM_core_noback(1,2), ... "fp_c"
    CM_core_noback(2,2), ... "tp_c"
    CM_brain_noback(1,1), ... "tn_pc"
    CM_brain_noback(2,1), ... "fn_pc"
    CM_brain_noback(1,2), ... "fp_pc"
    CM_brain_noback(2,2) ... "tp_pc"
    };

stats = [stats; rowToAdd];

end

