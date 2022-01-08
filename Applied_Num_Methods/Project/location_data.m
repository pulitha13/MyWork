function [rho, beacons, receiver] = location_data(m, error_level);

% rho:         m-vector of measured distances
% beacons:     2 x m matrix with position of beacons
% receiver:    2-vector with exact position of receiver
% m:           number of beacons
% error_level: scales measurement noise and receiver offset

n = 2;
receiver = 2*rand(n,1) - 1;  
beacons = randn(n,m);
R = 10000*(rand(m,1) - .5) + 20000;
beacons = beacons * diag(R ./ sqrt(sum(beacons.^2))');
dist = sqrt( sum( (beacons - receiver(:, ones(1,m))) .^2 ) )';
rho = dist + error_level*mean(R)*(randn(1) + .1*randn(m,1));
