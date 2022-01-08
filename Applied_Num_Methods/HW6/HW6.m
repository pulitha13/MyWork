

%9.4
load deblur
figure; imshow(Y);
n = size(Y, 1);

E = zeros(n, n);
E(1, 1)= 1;
E(n, 1)= -1;

for i = -5:.5:5
    lam = 10^i; 

    %Step 1: fft everything
    y = reshape(fft2(Y), n^2, 1);
    b = reshape(fft2(B), n^2, 1);
    e = reshape(fft2(E), n^2, 1);
    e_t = reshape(fft2(E'), n^2, 1);

    %Step 2: Diagonal inverse
    D = transpose(b') .* b + lam .* transpose(e') .* e + lam .* transpose(e_t') .* e_t;
    D = 1./D;

    %Step 3: Calc D*(diag(b) * y)
    alpha = D .* (transpose(b') .* y);

    %Step 4: Calc x_hat
    X_hat = ifft2(reshape(alpha, n, n));


    figure; imshow(X_hat);
end


%{
%8.6
[u, v] = circlefit;
plot(u, v, 'o');
axis equal

A = zeros(size(u, 1), 3);
b = zeros(size(u, 1), 1);

for i = 1:size(A, 1)

    A(i, :) = [-2*u(i) -2*v(i) 1];
    b(i, :) = [-1*(u(i)^2 + v(i)^2)];
    
end

x = A \ b;

R = sqrt(x(1)^2 + x(2)^2 - x(3));
u_c = x(1);
v_c = x(2);

t = linspace(0, 2*pi, 1000);
plot(u, v, 'o', R*cos(t) + u_c, R*sin(t)+v_c, '-');
%}