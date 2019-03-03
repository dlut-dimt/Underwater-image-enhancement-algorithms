close all;
clear all;
% input an image
img_path=['images\'];          %%  ÕæÊµÍ¼Ïñ
img_path_list = dir(strcat(img_path,'*.jpg'));
img_num = length(img_path_list);
for i=1:img_num
    [~, img_name, ~] = fileparts(img_path_list(i).name);
    img = double(imread([img_path,img_name, '.jpg']));
    wsz = 3;
    A = Airlight_water(img, wsz);
    t0 = t_initialize(img, A, 30, 300, wsz);
    %% load model for the tranmission
    load (strcat('JointTraining_5x5_2500new.mat'));
    filter_size = 5;
    m = filter_size^2 - 1;
    filter_num = m;
    BASIS = gen_dct2(filter_size);
    BASIS = BASIS(:,2:end);
    %% pad and crop operation
    bsz = filter_size+1;
    bndry = [bsz,bsz];
    pad   = @(x) padarray(x,bndry,'symmetric','both');
    crop  = @(x) x(1+bndry(1):end-bndry(1),1+bndry(2):end-bndry(2));
    %% MFs means and precisions
    KernelPara.fsz = filter_size;
    KernelPara.filtN = filter_num;
    KernelPara.basis = BASIS;
    trained_model = save_trained_model(cof, MFS, stage, KernelPara);
    sigma = 15;
    reset(RandStream.getGlobalStream);
    [R,C] = size(t0);
    input = pad(t0);
    noisy = pad(t0);
    hazeimg=pad(img);
    for s = 1:stage
        deImg = denoisingOneStepGMixMFs(noisy, input, trained_model{s});
        t1 = crop(deImg);
        deImg = pad(t1);
        input = deImg;
    end
    t1=max(0,min(t1,1));
    final_t= reshape(t1,R,C);
    %guided filtering
    ps=double(final_t);
    r =10;
    eps =10^-3;
    I0=img;
    I_g=double(rgb2gray(I0));
    final_t= guidedfilter(I_g, ps, r, eps);
    final_t=max(final_t,0.005);
    % underwater dehazing
    rp= Dehazefun(img, final_t, A, 0.8);
    J=im2uint8(rp);
    result=SimplestColorBalance(J);
   
end
figure,imshow(img)
figure,imshow(result)


