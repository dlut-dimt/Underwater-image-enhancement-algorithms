function [nb] = grid_nb(w, h);

% Sets up a sparse matrix representing a grid neighbourhood

nb = sparse(w*h,w*h);
for y=1:h % set up a grid-like neighbourhood, arbitrarily
    for x=1:w
        if (x < w), nb((y-1)*w+x,(y-1)*w+x+1) = 1; end
        if (y < h), nb((y-1)*w+x, y   *w+x  ) = 1; end
    end
end


end