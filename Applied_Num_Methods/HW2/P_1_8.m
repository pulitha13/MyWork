orthregdata

[lsq] = polyfit(a, b, 1);
lsq_m = lsq(1);
lsq_b = lsq(2);

std_a = std(a);
std_b = std(b);
rho = corrcoef(a, b);
rho = rho(2);
x = (std_a/std_b-std_b/std_a);
p = [rho x -1*rho];

osq = roots(p);
if osq(1) * rho > 0
    osq_m = osq(1);
else
    osq_m = osq(2);
end

osq_b = mean(b)-mean(a)*osq_m;


x = linspace(-2, 5);

figure
scatter(a , b)
hold on
plot(x, lsq_m*x + lsq_b);
plot(x, osq_m*x + osq_b);
legend({'points', 'least squares line', 'orthogonal distance line'});