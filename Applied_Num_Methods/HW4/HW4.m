n=10000;

a = randn(n, 1);
b = randn(n, 1);
A = toeplitz(a, [a(1), flipud(a(2:n))']);

tic
x_m1 = A \ b;
toc
t_m1 = toc;

tic
y_1 = fft(b);
a_dot = fft(a);
y_2 = y_1 ./ a_dot;
x_m2 = ifft(y_2);
toc
t_m2 = toc;

clc;
fprintf('Difference in n-dim x vectors [');
fprintf('%g ', norm(x_m1 - x_m2));
fprintf(']\n');

fprintf('Time for method 1: %g\nTime for method 2: %g\n', t_m1, t_m2);


