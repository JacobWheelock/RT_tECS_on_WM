% NOTE: Please enter timeseries in TIME x VARS form. Time should be the
% number of rows
function [x_est,res] = kalmanSmooth(x_meas)
    x_est = zeros(size(x_meas)).';
    y = zeros(size(x_meas)).';
    dim = size(x_meas,2);
    x_est(:,1) = x_meas(1,:); %x_0|0
    P(:,:) = eye(dim); %P_0|0
    
    F = eye(dim);
    Q = 0.0000001*eye(dim);%cov(randn(dim,size(x_meas,1)));
    H = 1*eye(dim);
    R = 0.000001*eye(dim);%cov(randn(dim,size(x_meas,2)));
    
    for i=2:size(x_est,2)
        % Predict
        x_est(:,i) = F*x_est(:,i-1); %x_k|k-1
        P(:,:) = F*P(:,:)*F.' + Q; %P_k|k-1
        
        % Update
        y(:,i) = x_meas(i,:).' - H*x_est(:,i); %y_k
        S = H*P(:,:)*H.' + R;
        K = P(:,:)*H.'/(S);
        x_est(:,i) = x_est(:,i) + K*y(:,i); %x_k|k
        P(:,:) = (eye(dim) - H*K)*P(:,:); %P_k|k
        y(:,i) = x_meas(i,:).' - H*x_est(:,i); %y_k|k
    end
    res = y;
    x_est = x_est(:,end);
end