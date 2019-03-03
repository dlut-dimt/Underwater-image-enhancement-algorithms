function [ t_est ] = dark_chan_prior(I, A, win, omega)
%DARK_CHAN_PRIOR estimates the depth of a scene using the Dark Channel
%Prior proposed by He et al in ...

    size_I = size(I);
    img_min_patch = single(zeros(size_I));
    img_min_patch(:,:,1) = ordfilt2(I(:,:,1),1,ones(win,win),zeros(win,win),'symmetric');
    img_min_patch(:,:,2) = ordfilt2(I(:,:,2),1,ones(win,win),zeros(win,win),'symmetric');
    img_min_patch(:,:,3) = ordfilt2(I(:,:,3),1,ones(win,win),zeros(win,win),'symmetric');
    img_min_patch(:,:,1) = img_min_patch(:,:,1)./A(1);
    img_min_patch(:,:,2) = img_min_patch(:,:,2)./A(2);
    img_min_patch(:,:,3) = img_min_patch(:,:,3)./A(3); 
    % calculate the transmission estimate
    t_est = 1-omega*min(img_min_patch,[],3);


end

