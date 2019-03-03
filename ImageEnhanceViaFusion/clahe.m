function img2=clahe(img)
img1 = SimplestColorBalance(img);
lab1 = rgb_to_lab(img1);
% CLAHE

lab2 = lab1;
lab2(:, :, 1) = adapthisteq(lab2(:, :, 1));
%lab2(:, :, 1) = uint8(bilateralFilter(double(lab2(:, :, 1))));
img2 = lab_to_rgb(lab2);


