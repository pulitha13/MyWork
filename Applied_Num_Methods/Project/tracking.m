%Method 3
function [positions, offsets] = tracking(beacons, rho, gamma)
    %Initialize all non-iterative variables
    m = size(beacons, 2);
    T = size(rho, 2);
    
    x = 10*rand(3*T,1) - 1; %initialize random x 
    lambda = .1;
    epsilon = 10^-5;
    beta_1 = .8;
    beta_2 = 2;
    
    %(A_dot_dot in report)
    A_dot_block = sqrt(gamma)*[1, 0, 0, -2, 0, 0, 1, 0, 0; 0, 1, 0, 0, -2, 0, 0, 1, 0];    
    A_dot = zeros((T-3+1)*2, 3*T);
    for i = 1:T-3+1
        A_dot(i*2-1:i*2, i*3-2:i*3-2+8) = A_dot_block;
    end
    
    x_mat = reshape(x, 3, T);
    positions = x_mat(1:2, :);
    offsets = x_mat(3, :);
    
    f_x = zeros(m*T, 1);
    for i = 1:T
        for j = 1:m
            f_x(m*(i-1)+j) =  norm(positions(:, i) - beacons(:,j)) + offsets(i) - rho(j, i);
        end
    end
    f_x = [f_x; A_dot*x];
   
    A = [];
    for i = 1:T
        A_block = zeros(m, 3);
        for j = 1:m
            d = norm(positions(:, i) - beacons(:, j));
            A_block(j,:) =  [(positions(1,i) - beacons(1,j))/d , (positions(2, i) - beacons(2,j))/d, 1];
        end
        A = blkdiag(A, A_block);
    end
    A = [A; A_dot];

    %Terminate if gradient@x is suff close to 0;
    while (norm(2*A'*f_x) > epsilon)
    
        %Formulate the LM LSQ approx 
        A_t = [A; sqrt(lambda)*eye(3*T)];
        b_t = [A*x - f_x; sqrt(lambda)*x];
        
        x_hat = A_t \ b_t;
        

        %Calc next iteration
        x_hat_mat = reshape(x_hat, 3, T);
        temp_positions = x_hat_mat(1:2, :);
        temp_offsets = x_hat_mat(3, :);
        temp_f_x = zeros(m*T, 1);
        for i = 1:T
            for j = 1:m
                temp_f_x(m*(i-1)+j) =  norm(temp_positions(:, i) - beacons(:,j)) + temp_offsets(i) - rho(j, i);
            end
        end 
        temp_f_x = [temp_f_x ; A_dot*x_hat];
        
        if (norm(temp_f_x)^2 <  norm(f_x)^2 )
            x = x_hat;
            positions = temp_positions;
            offsets = temp_offsets;
            lambda = lambda*beta_1;
            f_x = temp_f_x;
            
            A = [];
            for i = 1:T
                A_block = zeros(m, 3);
                for j = 1:m
                    d = norm(positions(:, i) - beacons(:, j));
                    A_block(j,:) =  [(positions(1,i) - beacons(1,j))/d , (positions(2, i) - beacons(2,j))/d, 1];
                end
                A = blkdiag(A, A_block);
            end
            A = [A; A_dot];
            
        else
            lambda = lambda*beta_2;
        end
    end
end 




