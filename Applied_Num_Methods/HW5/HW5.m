%Problem 8.11
format long
k = [6 7 8];
A = zeros(3,2);
b = zeros(3,1);

fprintf('Part B\n');
for i = k
    A = [1 1; 10^-i 0; 0 10^-i];
    b = [-10^-i; 1+10^-i; 1-10^-i];
    fprintf('Solving for x we get : x =');
    fprintf('%g ', A \ b);
    fprintf('for k =%g', i);
    fprintf('\n');
end

fprintf('Part C\n');
for i = k
    A = [1 1; 10^-i 0; 0 10^-i];
    b = [-10^-i; 1+10^-i; 1-10^-i];
    fprintf('Solving for x we get : x =');
    fprintf('%g ', (A'*A) \ (A'*b));
    fprintf('for k =%g', i);
    fprintf('\n');
end

%Problem 13.3
%{
T = [
1971 2250
1972 2500 
1974 5000 
1978 29000 
1982 120000 
1985 275000 
1989 1180000 
1993 3100000 
1997 7500000 
1999 24000000 
2000 42000000 
2002 220000000
2003 410000000 ];

%Create b = log(Transistors)
b = log (T(:,2)) ./ log(10);

%Create A
A = zeros(13, 2);
A(:,1) = ones(13, 1);
A(:,2) = T(:,1) - 1970;

x = A \ b;

fprintf('Solving for x we get : x = [');
fprintf('%g ', x(1));
fprintf(', %g', x(2));
fprintf(']\n');

fprintf('RMS = ');
fprintf('%g ', dot((A*x - b),(A*x - b)));
fprintf('\n');

fprintf('We predict that in 2015 there will be ');
fprintf('%g ', 10^(x(1) + x(2)*(2015-1971)));
fprintf('transistors\n');

fprintf('Moore would predict that in 2015 there will be ');
fprintf('%g-', T(13,2)*2^6);
fprintf('%g ', T(13,2)*2^8);
fprintf('transistors\n');


x_plot = 0:0.001:40;
y_plot = x(1) + x(2)*x_plot;

scatter(T(:, 1) - 1970, log(T(:, 2))./log(10));
hold on
plot(x_plot, y_plot);
%}


