function in2out = perspectiveProj(in, out)
if nargin==0, in2out = demo(); return; end

x = in(1,:)';
y = in(2,:)';
u = out(1,:)';
v = out(2,:)';

top = [x, y, ones(4,1), zeros(4,3), -x.*u, -y.*u];
bottom = [zeros(4,3), x, y, ones(4,1), -x.*v, -y.*v];
a = [top; bottom];

s = a \ [u; v];

in2out = @(xy) bsxfun(@rdivide, ...
    [s(1:2)' * xy + s(3); s(4:5)' * xy + s(6)], ...
    s(7:8)' * xy + 1);
end



function in2out = demo()
in = [3 5; 5 5; 2 2; 6 1]';
out = [0 3; 3 3; 0 0; 3 0]';
in2out = perspectiveProj(in, out);
absError = abs(in2out(in) - out);

if all(all(absError < 10 * eps()))
    disp('perspectiveProj demo passed.')
else
    error('perspectiveProj:demo', ...
        'Failed absolute tolerance test:')
end
end