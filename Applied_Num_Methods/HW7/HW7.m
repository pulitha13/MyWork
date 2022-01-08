n = 20;
c_1 = zeros(1,n);
c_2 = zeros(1,n);
c_3 = zeros(1,n);
c_4 = zeros(1,n);

c_3(1) = 1;
c_4(1) = 1;
sum_1 = 0;
sum_2 = 0;
for i = 1:n-1
    sum_1 = sum_1 + c_3(i);
    sum_2 = sum_2 + c_4(i);
    c_1(i+1) = sum_1;
    c_2(i+1) = sum_2;
    c_3(i+1) = c_3(i)*.95;
    c_4(i+1) = c_4(i)*.8;
end

C = [ .1*c_1 (-.2)*c_2; .1*c_3 zeros(1, n); zeros(1, n) .2*c_4];

%QR Factorize C
[Q, R] = qr(C');
R = R(1:3, :);
Q = Q(:, 1:3);
y = [1; 0; 0];
%Solution x = Q R^-T y
a = R' \ y;
x = Q * a;

%Plot the positions of s and p
s = zeros(2, 21);
p = zeros(2, 21);
s(:, 1) = [0; 0];
p(:, 1) = [1; 0];
S_m = [1 1; 0 0.95];
S_v = [0; .1];
P_m = [1 1; 0 .8];
P_v = [0; .2];

%Note x = [u(19) u(18) ... u(0) v(19) v(18) ...]
for i = 1:n
       s(:, i+1) = S_m * s(:,i) + S_v * x(n+1-i);
       p(:, i+1) = P_m * p(:,i) + P_v * x(2*n+1-i);
end

plot(1:21, s(1, :));
hold on
plot(1:21, p(1, :));
legend('Car 1', 'Car 2')

