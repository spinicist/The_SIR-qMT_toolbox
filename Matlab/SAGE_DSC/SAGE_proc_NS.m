% New proc script after misplacing data.

%===========================================================%
% Simple multi echo perfusion calculations using SAGE       %
% Much of this was adapted from Ashley M. Stokes, Ph.D.     %
%                                                           %
% Nicholas J. Sisco, Ph.D.                                  %
%===========================================================%

clc;clear;close all
script_path = "C:\Users\nicks\Documents\Github\The_MRI_toolbox\Matlab\SAGE_DSC\";
cd(script_path);
addpath(genpath('./mfiles/'))


% ptnums=1:100; %does not matter, keep the range
ptnums=1; %does not matter, keep the range

temp = uigetdir("C:\Users\nicks\Documents\GitHub\DSC_SAGE_python\");
out_path = "C:\Users\nicks\Documents\MRI_data\SAGE\DSC_standard_proc\";

f=dir(temp);
base_path=f(1).folder;

% base_path = uigetdir('C:/Users/nicks/Box/MSPerfusion Data/SAGE_dcm_converted/');
% brainMask_path = uigetdir('C:/Users/nicks/Box/MSPerfusion Data/SAGE_dcm_converted/');
% base_path = "/Users/nicks/Box/MSPerfusion Data/SAGE_dcm_converted/SAGE_niftis/";
% brainMask_path = "/Users/nicks/Box/MSPerfusion Data/SAGE_dcm_converted/SAGE_prebolus_TE5/";
if ~base_path
    return
end
%%
for index=73
    %%
    % if you want to use Volterra, put a 1 in the flag spot
%     [DSC,CBF_map,CBFSE_map,CBV_all,CBV_SE,MTT,MTT_SE] = sage_proc_ns_func(base_path,index,0);
    [DSC_volterra,CBF_map_volterra,CBFSE_map_volterra,CBV_all_volterra,CBV_SE_volterra,MTT_volterra,MTT_SE_volterra] = sage_proc_ns_func(base_path,index,1);
    [DSC_block,CBF_map_block,CBFSE_map_block,CBV_all_block,CBV_SE_block,MTT_block,MTT_SE_block] = sage_proc_ns_func(base_path,index,2);
    
end
%%
kernel=5;
CBF_outlier = removeOutlierVolume(CBF_map,2,kernel);
CBF_se_outlier = removeOutlierVolume(CBFSE_map,2,kernel);
CBV_outlier = removeOutlierVolume(CBV_all,2,kernel);
CBV_se_outlier = removeOutlierVolume(CBV_SE,2,kernel);
mtt_outlier = removeOutlierVolume(MTT,2,kernel);
mtt_se_outlier = removeOutlierVolume(MTT_SE,2,kernel);


CBF_outlier_volterra = removeOutlierVolume(CBF_map_volterra,2,kernel);
CBF_se_outlier_volterra = removeOutlierVolume(CBFSE_map_volterra,2,kernel);
CBV_outlier_volterra = removeOutlierVolume(CBV_all_volterra,2,kernel);
CBV_se_outlier_volterra = removeOutlierVolume(CBV_SE_volterra,2,kernel);
mtt_outlier_volterra = removeOutlierVolume(MTT_volterra,2,kernel);
mtt_se_outlier_volterra = removeOutlierVolume(MTT_SE_volterra,2,kernel);


%%
% MTT(MTT>100)=0;
% MTT_SE(MTT_SE>100)=0;
close all
for ii = 1:DSC.Parms.nz
    subplot(2,1,1)
    imagesc(permute(MTT(:,:,ii),[2 1 3] ));colorbar
    subplot(2,1,2)
    imagesc(permute(MTT_SE(:,:,ii),[2 1 3] ));colorbar
    pause(0.1)
end

for ii = 1:DSC.Parms.nz
    subplot(2,1,1)
    imagesc(permute(CBV_all(:,:,ii),[2 1 3] ));colorbar
    subplot(2,1,2)
    imagesc(permute(CBV_SE(:,:,ii),[2 1 3] ));colorbar
    pause(0.1)
end

for ii = 1:DSC.Parms.nz
    subplot(2,1,1)
    imagesc(permute(CBF_map(:,:,ii),[2 1 3] ));colorbar
    subplot(2,1,2)
    imagesc(permute(CBFSE_map(:,:,ii),[2 1 3] ));colorbar
    pause(0.1)
end

subplot(2,1,1)
imagesc(permute(MTT(:,:,8),[2 1 3] ));colorbar
subplot(2,1,2)
imagesc(permute(MTT_SE(:,:,8),[2 1 3] ));colorbar

%%

temp1 = (MTT);
temp2 = (MTT_SE);
temp3 = (mtt_outlier);
temp4 = (mtt_se_outlier);
base='C:\Users\nicks\Documents\MRI_data\SAGE\AIF_optimizations\';
save(sprintf('%sMTT.mat',base),'temp1','-v6')
save(sprintf('%sMTTSE.mat',base),'temp2','-v6')
save(sprintf('%sMTT_rm_out.mat',base),'temp3','-v6')
save(sprintf('%sMTTSE_rm_out.mat',base),'temp4','-v6')

temp1 = (CBF_map);
temp2 = (CBFSE_map);
temp3 = (CBF_outlier);
temp4 = (CBF_se_outlier);

save(sprintf('%sCBF.mat',base),'temp1','-v6')
save(sprintf('%sCBFSE.mat',base),'temp2','-v6')
save(sprintf('%sCBF_rm_out.mat',base),'temp3','-v6')
save(sprintf('%sCBFSE_rm_out.mat',base),'temp4','-v6')

temp1 = (CBV_all);
temp2 = (CBV_SE);
temp3 = (CBV_outlier);
temp4 = (CBV_se_outlier);

save(sprintf('%sCBV.mat',base),'temp1','-v6')
save(sprintf('%sCBVSE.mat',base),'temp2','-v6')
save(sprintf('%sCBV_rm_out.mat',base),'temp3','-v6')
save(sprintf('%sCBVSE_rm_out.mat',base),'temp4','-v6')


