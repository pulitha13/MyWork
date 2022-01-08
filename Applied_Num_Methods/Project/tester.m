m = 7;
error_level = 10^-5;

err_1 = 0;
err_2 = 0;
for i = 1:10
    [rho, beacons, receiver] = location_data(m, error_level);

    position_1 = location_1(beacons, rho);
    [position_2, offset] = location(beacons, rho);

    err_1 = err_1 + norm(position_1 - receiver)^2;
    err_2 = err_2 + norm(position_2 - receiver)^2;
end 
    
fprintf("Average Squared Error in using Method 1: %f\n", err_1/10);
fprintf("Average Squared Error in using Method 2: %f\n\n", err_2/10);

m = 7;
error_level = 10^-5;
gamma = .01;
err_1 = 0;
err_2 = 0;
err_3 = 0;
err_3_c = 0;
for i = 1:10
    [rho, beacons, receiver] = tracking_data(m, error_level);

    positions_1 = tracking_1(beacons, rho);
    [positions_2, offsets_2] = tracking_2(beacons, rho);
    [positions_3, offsets_3] = tracking(beacons, rho, gamma);
    
    err_1 = err_1 + norm(positions_1 - receiver)^2;
    err_2 = err_2 + norm(positions_2 - receiver)^2;
    err_3 = err_3 + norm(positions_3 - receiver)^2;
    %err_3_c = err_3_c + norm(positions_3(:, 3:end) - receiver(:, 3:end))^2;
end 

fprintf("Average Squared Error in using Method 1: %f\n", err_1/10);
fprintf("Average Squared Error in using Method 2: %f\n", err_2/10);
fprintf("Average Squared Error in using Method 3: %f\n", err_3/10);
fprintf("Average Squared Error in using Method 3: %f (disregarding the first 2 points)\n", err_3_c/10);

scatter(receiver(1, :), receiver(2,:));
hold on
scatter(positions_3(1, :), positions_3(2, :));
