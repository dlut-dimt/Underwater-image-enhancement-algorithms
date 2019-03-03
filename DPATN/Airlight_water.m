function A = Airlight_water(HazeImg, wsz)
% estimating A channel by channel separately
minImg = ordfilt2(double(HazeImg(:, :, 1)), 1, ones(wsz), 'symmetric');
A(1) = mean(minImg(:));
for k = 2 : 3
    minImg = ordfilt2(double(HazeImg(:, :, k)), 1, ones(wsz), 'symmetric');
%     A(k) = max(minImg(:));
%     A=max(A,1)
end

[nRows, nCols, bt] = size(HazeImg);
GrayImg =max( HazeImg(:,:,3)-HazeImg(:,:,1),HazeImg(:,:,2)-HazeImg(:,:,1));
topDark = sort(minImg(:), 'descend');
idx = round(0.005 * length(topDark));
val = topDark(idx); 
id_set = find(minImg >= val);  % the top 0.1% brightest pixels in the dark channel
BluePxls = GrayImg(id_set);
iBlue = find(BluePxls >= max(BluePxls));
id = id_set(iBlue); id = id(1);
row = mod(id, nRows);
col = floor(id / nRows) + 1;
% A is a vector
row=max(row,1);
A = HazeImg(row, col, :);
A=max(A,0.001);
A = double(A(:));