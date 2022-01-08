%Problem 1
%syms f(T)
%t = [1 2 3 4 5];
%b = [3 5 10 -2 -3];

%A = zeros(5,5);
%for i = 1:5
%    A(i,:) = [1 t(i) (t(i))^2 -1*b(i)*t(i) -1*b(i)*(t(i))^2];
%end

%x = A \ b.';

%fprintf('Solving for x we get : x = [');
%fprintf('%g ', x);
%fprintf(']\n');


%f(T) = (x(1) + x(2)*T + x(3)*T^2)/(1 + x(4)*T + x(5)*T^2);
%fplot(f)

%Problem 2
a1 = [-10 10 10];
a2 = [0 10 0];
a3 = [-10 10 0];
a4 = [-20 -10 -10];
a = [a1;  a2; a3; a4];

rho1 = 17.7518;
rho2 = 9.6417;
rho3 = 14.3198;
rho4 = 24.9654;
rho = [17.7518 9.6417 14.3198 24.9654];

A = zeros(3,3);
for i = 2:4
    A(i-1,:) = [2*a(1,1)-2*a(i,1) 2*a(1,2)-2*a(i,2) 2*a(1,3)-2*a(i,3)];
end

b = zeros(3,1);
for i = 2:4
    b(i-1, 1) = rho(i)^2 - rho(1)^2 + a(1,1)^2- a(i,1)^2 + a(1,2)^2- a(i,2)^2 + a(1,3)^2- a(i,3)^2;
end

x = A \ b;

fprintf('Solving for x we get : x = [');
fprintf('%g ', x);
fprintf(']\n');



