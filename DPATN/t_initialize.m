
function [t_bdcon, t_b] = t_initialize(HazeImg, A, C0, C1, sz)
% patch-wise transmission
if length(A) == 1
    A = A * ones(3, 1);
end
if length(C0) == 1
    C0 = C0 * ones(3, 1);
end
if length(C1) == 1
    C1 = C1 * ones(3, 1);
end
HazeImg = double(HazeImg);

% pixel-wise boundary
t_r = max((A(1) - HazeImg(:, :, 1)) ./ (A(1)  -  C0(1)), (HazeImg(:, :, 1) - A(1)) ./ (C1(1) - A(1) ));
t_g = max((A(2) - HazeImg(:, :, 2)) ./ (A(2)  - C0(2)), (HazeImg(:, :, 2) - A(2)) ./ (C1(2) - A(2) ));
t_b = max((A(3) - HazeImg(:, :, 3)) ./ (A(3)  - C0(3)), (HazeImg(:, :, 3) - A(3)) ./ (C1(3) - A(3) ));
t_b = max(cat(3, t_r, t_g, t_b), [], 3);
t_b = min(t_b, 1);

% minimum filtering
se = strel('square', sz);
t_bdcon = imclose(t_b, se);
