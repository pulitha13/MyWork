function [ rho, beacons, receiver ] = tracking_data(m, error_level);

% rho:         m x 100 matrix of measured distances at t = 1,...,100
% beacons:     2 x m matrix with position of beacons
% receiver:    n x 100 matrix with exact positions of receiver 
%                  at t = 1,...,100
% m:           number of beacons
% error_level: scales measurement noise and receiver offset

A = [ eye(2), eye(2); zeros(2,2), .4*eye(2) ];
B = [ zeros(2,2); eye(2) ];
C = [ eye(2), zeros(2,2) ];
T = 100;
W = [cos(linspace(0,4*pi,T-1)); linspace(-1,1,T-1)]; 

xinit = [2*rand(2,1)-1; [3;-2]];  
X = [ xinit, zeros(4,T-1) ];
for t = 1:T-1
    X(:,t+1) = A*X(:,t) + B*W(:,t);
end;
receiver = C*X; 

beacons = randn(2,m);
R = 10000*(rand(m,1) - .5) + 20000;
beacons = beacons * diag(R ./ sqrt(sum(beacons.^2))');
rec_offsets = error_level*mean(R)*randn(T,1);

psranges = zeros(m,T);
rho = zeros(m,T);
for t = 1:T
    psranges(:,t) = ...
	sqrt(sum( (beacons - receiver(:, t*ones(1,m))) .^2 ))' + ...
            rec_offsets(t);
    rho(:,t) = psranges(:,t) + .1*error_level*mean(R)*randn(m,1);
end;
