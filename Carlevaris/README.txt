It should be pretty straight forward to run. It relies on the graph cuts 
library which needs to be compiled. Out of the box it should run on Windows 7 
64bit. On other operating systems you may need to recompile. Just a warning, 
if you want to dehaze megapixel and larger images it might take quite a bit of 
memory (especially the Laplacian matting step).

The main file to run is oceans.m which is setup to run a few sample images and 
pretty well commented. There are two tuning parameters, win and lambda, that I 
found to be very important in order to get the best results. There is a 
comment in the code that gives some rough ranges of appropriate values for 
these  parameters.
