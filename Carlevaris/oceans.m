%% Nicholas Carlevaris-Bianco
%  Anush Mohan
%  Ryan Eustice
%  2010
 
clear
clc

%% Load image and setup params
file_path =  'E:\ircnn-master\haze\underwater\';% 图像文件夹路径
%avepath='E:\ACM_MM\all\备份\11\';
%img_path_list = dir(strcat(file_path,'*.png'));%获取该文件夹中所有jpg格式的图像
%img_num = length(img_path_list);%获取图像总数量


for j = 1:64 %逐一读取图像
    %name = img_path_list(j).name;% 图像名
    %I =  imread(strcat(file_path,name));
    I =imread(['E:\水下数据库\syn\syn\',num2str(j),'.png']);

% UNDERWATER
%imfile = ['D:\ICME\ircnn-master\haze\underwater\sea',num2str(num),'.jpg'];
 %imfile = 'images/reef1.jpg';
% imfile = 'images/reef2.jpg';
% imfile = 'images/reef3.jpg';
% imfile = 'images/ship.jpg';
% imfile = 'images/fish.jpg'; %fattal

% TANK TEST
% for tank images our method can't estimate airlight 
% so used fixed (SEE LINE 88)
% imfile = 'tank_images/block-row.jpg'; 

% Graph Cuts Library
addpath(genpath('gco-v3.0'));

% results can be sensitive to these two parameters
% I found I had to tune them a little bit for each image to 
% get the best possible results. As a starting point use 
% something in the range of:
% win = 20; %for smaller images
% win = 60; %for larger images
% lambda = 10e-4; %for smaller images
% lambda = 10e-5; %for larger images
win = 20;
lambda = 10e-5;

% Window size transmission estimate limit omega
omega = 0.95;

%scale to convert decimals to integers
int_scale = 1e5;

%I = imread(imfile);
%I = imresize(I, 0.8);
%convert to a single between 0 and 1
I = im2double(I);
[height width depth] = size(I);

%% Estimate the depth of the scene

tic

% for underwater images look at the attenuation of red channel to
% estimate depth
max_r_im = ordfilt2(I(:,:,1),win^2,ones(win,win),zeros(win,win),'symmetric');
max_g_im = ordfilt2(I(:,:,2),win^2,ones(win,win),zeros(win,win),'symmetric');
max_b_im = ordfilt2(I(:,:,3),win^2,ones(win,win),zeros(win,win),'symmetric');
gb_im = cat(3,max_g_im,max_b_im);
max_gb_im = max(gb_im,[],3);
diff = max_r_im - max_gb_im;
diff_max = max(max(diff));
t_est = diff + (1-diff_max); 

clear max_r_im max_g_im max_b_im gb_im max_gb_im diff

%figure(10)
%imagesc(t_est), title('Initial Transmission'), colormap hot, axis image

% refine the depth estimate with laplacian natural image matting proposed
% by Levin et al
[t_est] = laplacian_matting( t_est, I, lambda);

%% Estimate the airlight
% find intensity values at the pixel with the minimum transmission
 t_est_min = min(min(t_est));
 A_ind = find(t_est == t_est_min, 1, 'first');
 [row col] = ind2sub([height,width], A_ind);
 A = squeeze(I(row, col, :))
%A_nic(num,:)=A;
 %figure(4) 
   % imshow(t_est);
   % title(sprintf('Airlight Estimate = [%f %f %f]',A(1),A(2),A(3)));
   % hold on
   %     plot(col, row, '.r');
   % hold off

% for tank images our method can't estimate airlight so used fixed
% A = [0.1 0.999 0.7]; %tank images


clear mask inds cols rows bg bg_max

%limit the furthest transmission by omega
t_est(t_est < (1-omega)) = 1-omega;    
    
disp('Transmission Estimated'), toc

%figure(1)
   % subplot(1,3,1)
    %    imshow(I), title('Original Image');
   % subplot(1,3,2)
    %    imagesc(t_est), title('Estimated Transmission'), colormap hot, axis image
%figure(11)
%imagesc(t_est), title('Estimated Transmission'), colormap hot, axis image


%% Estimate the scene albedo

J_num_lvls = 50;
Jstar = single(linspace(0,1,J_num_lvls));
I_est = zeros(height,width,depth);

% for each color channel
color_chans = {'Red', 'Green', 'Blue'};
for c = 1:3
    tic
    
    % Calculate datacost 
    Qc = single(zeros(height, width, J_num_lvls));
    I_rep = single(repmat(I(:,:,c), [1 1 J_num_lvls]));
    Jstar_rep = single(repmat(reshape(Jstar, [1,1,J_num_lvls]), [height,width,1]));
    t_est_rep = single(repmat(t_est, [1,1,J_num_lvls]));
    Qc(:,:,:) = ((I_rep-A(c))./t_est_rep + A(c) - Jstar_rep).^2; 
    % convert to an int 32 (small decimal so scale up and round)
    Qc(:,:,:) = round(Qc(:,:,:).*int_scale);
    
    % Preform graph cut minimization
    gch = GCO_Create(width*height, J_num_lvls); %creat new graph
    GCO_SetVerbosity(gch, 2); %set visible output
    %set neighborhood
    %nb = round(grid_nb_weighted(width, height, t_est).*int_scale);
    nb = round(grid_nb(width, height));
    GCO_SetNeighbors(gch,nb);
    %set datacost
    GCO_SetDataCost(gch, reshape(permute(Qc,[3,1,2]), J_num_lvls,height*width));
    %set smoothness cost
    Vc = int32(ones(J_num_lvls) - eye(J_num_lvls));
    %Vc = int32(zeros(J_num_lvls));
    GCO_SetSmoothCost(gch,Vc);
    
    % set label cost
    % no label cost used during gco
    
    % get the solve for new labels using expand or swap method
    GCO_Expansion(gch);    
    Jbar = GCO_GetLabeling(gch); 

    disp(sprintf('Estimated the %s color channel', color_chans{c})), toc
    
    % calculate this color channel
    Jbar = reshape(Jbar, [height, width]);
    cc_est = Jstar(Jbar);
    I_est(:,:,c) = cc_est;
    %figure(2)
    %subplot(2,3,c)
       % imshow(I(:,:,c)), title(sprintf('Orig %s color channel', color_chans{c}))
   % subplot(2,3,3+c)
        %imshow(cc_est), title(sprintf('Est %s color channel', color_chans{c}))
        

end


%% Display Final Image
%figure(1)
        %subplot(1,3,3)
        %imshow(I_est), title('Dehazed Image')
        
 %figure(3)
        %imshow(I_est), title('Dehazed Image')
        imwrite(I_est,['E:\水下数据库\syn\results\Carlevaris\',num2str(i),'.png']);
        %imwrite(t_est,['result\',num2str(j),'t_Carlevaris_.jpg'])
        %save(['result\',num2str(num),'_Nicholas.mat','I_est']);
end








