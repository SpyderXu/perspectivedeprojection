clear

%% PARAMETERS
% Input image filename
inputfname = 'screen.jpg';
% How many 90-degree turns needed?
numTurns = 2;
% Pixels in the original image corresponding to edges of the flat rectangle:
% start at top-left and go clock-wise
in = [519 354; 1942 503; 2004 1404; 593 1711]';
% Height in pixels of the orthorectified image
height = 900;
% Actual aspect ratio of flat rectangle
aspect = 1.6;
% Output filename of rectified image
outfname = 'ortho.jpg';

%% COMPUTATION
screen = imread(inputfname);
% Apparently the new Matlab 2014a's rot90 is 3D capable but not mine. This
% functor accepts a function handle `func` and returns another function handle
% that will apply `func` to each 3D slice of a 3D array. It's used in a couple
% of places here.
functor2dto3d = @(func) @(s) cell2mat(cellfun(func, ...
    mat2cell(s, size(s,1), size(s,2), ones(1,size(s,3))), ...
    'uniformOutput',0));
if numTurns ~= 0
    rotImg180 = functor2dto3d(@(x) rot90(x, numTurns));
    screen = rotImg180(screen);
end

out = [0 1; 1 1; 1 0; 0 0]';
in2out = perspectiveProj(in, out);

[x, y] = meshgrid(1:size(screen,2), 1:size(screen,1));
xyout = in2out([x(:) y(:)]');
u = reshape(xyout(1,:),size(x));
v = reshape(xyout(2,:), size(y));

[ugrid, vgrid] = meshgrid(linspace(0, 1, round(height*aspect)), linspace(0, 1, height));
out2in = perspectiveProj(out, in);
xy01 = out2in([ugrid(:) vgrid(:)]');
x01 = reshape(xy01(1,:), size(ugrid));
y01 = reshape(xy01(2,:), size(ugrid));
f1 = interp2(x, y, double(screen(:,:,1)), x01, y01);

makeortho = functor2dto3d(@(t) flipud(interp2(x, y, double(t), x01, y01, '*spline')));
orthoscreen = makeortho(screen);
orthoimg = uint8(round(orthoscreen));

figure;image(orthoimg); 
axis image

imwrite(orthoimg, outfname, 'jpg')
disp(['Saving ' outfname])