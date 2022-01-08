load mnist_train
k = 20;
[n, N] = size(digits);
N= 10000;
digits = digits(:,1:N);
group = randi(k, 1, N);
done = false;
rep = zeros(n, k);
J = 0;
dist = zeros(N, k);
min_dist_sq = zeros(1, N);

while(~done)
    %calculate the new reps of each group
    for i = 1:k
        I = find(group == i);
        rep(:, i) = mean(digits(:,I), 2);
    end

    %calculate distance of every image to reps
    for i = 1:N
        for j = 1:k
            dist(i, j) = sum((digits(:,i) - rep(:, j)).^2);
        end   
        [min_dist_sq(i), group(i)] = min(dist(i, :));
    end

    %if ending critereon is met then end loop
    curr_J = mean(min_dist_sq);
    if abs( curr_J - J) <= 10^(-5) * curr_J
        done = true;
    end
    J = curr_J;

end

for k = 1:20
    subplot(4, 5, k)
    imshow(reshape(rep(:,k), 28, 28));
end

