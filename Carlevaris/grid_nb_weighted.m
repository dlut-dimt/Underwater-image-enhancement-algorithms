function [nb] = grid_nb_weighted(w, h, t_est);

% Sets up a sparse matrix representing a grid neighbourhood

nb = sparse(w*h,w*h);
for y=1:h % set up a grid-like neighbourhood, arbitrarily
    for x=1:w
        if (x < w), nb((y-1)*w+x,(y-1)*w+x+1) = 1-abs(t_est(y,x) - t_est(y,x+1)); end
        if (y < h), nb((y-1)*w+x, y   *w+x  ) = 1-abs(t_est(y,x) - t_est(y+1,x)); end
    end
end


end