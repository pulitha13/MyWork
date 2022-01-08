% Method 1
function position = location_1(beacons, rho)
    
    %Initialize first x, lambda and non-iterative variables
    m = size(beacons, 2);
    x = 2*rand(2,1) - 1;
    lambda = .1;
    epsilon = 10^-5;
    beta_1 = .8;
    beta_2 = 2;
    position = x;
    
    %Calc first f(x) and A=Df(x)
    f_x = zeros(m, 1);
    for i = 1:m
        f_x(i) =  norm(x - beacons(:,i)) - rho(i);
    end 
   
    A = zeros(m, 2);
    for i = 1:m
        d = norm(x - beacons(:, i));
        A(i,:) =  [(x(1) - beacons(1,i))/d , (x(2) - beacons(2,i))/d];
    end 
    
    %Terminate if gradient@x is suff close to 0;
    while (norm(2*A'*f_x) > epsilon)
    
        %Formulate the LM LSQ approx 
        A_t = [A; sqrt(lambda)*eye(2)];
        b_t = [A*x - f_x; sqrt(lambda)*x];
        x_hat = A_t \ b_t;
        

        %Calc f(x_hat)
        temp = zeros(m, 1);
        for i = 1:m
            temp(i) =  norm(x_hat - beacons(:, i)) - rho(i);
        end
        
        %Calcultate next x, lambda, and A
        if (norm(temp) <  norm(f_x))
            x = x_hat;
            position = x;
            lambda = lambda*beta_1;
            f_x = temp;
            for i = 1:m
                d = norm(position - beacons(:,i));
                A(i,:) =  [(position(1) - beacons(1,i))/d , (position(2) - beacons(2,i))/d];
            end
        else
            lambda = lambda*beta_2;
        end
    end
    
end 
