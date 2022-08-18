% Experiment Variables
global timer yUnfiltered yFiltered s;
preStimSize = 25;    % Initial number of trials before stimulation
trialSize = 50;      % Number of trials to attempt to reach convergence
convergedBlocks = 18;  % Number of trial blocks once convergence has been reached
blockSize = 3;      % Block size for converged trials
convergedSize = convergedBlocks * blockSize;

subjectName = string(inputdlg('Enter Subject Number'));
span = 7;

% Initialize Python
initPy()

% Initialize Stimulator
s = serialport("COM6", 115200);
readline(s);
writeline(s, "sumOfSines2");
pause(2);

% Initialize variables
a1 = optimizableVariable('a1', [0 1]);
f1 = optimizableVariable('f1', [0 30]);
a2 = optimizableVariable('a2', [0 1]);
f2 = optimizableVariable('f2', [0 30]);
d = optimizableVariable('d', [0 2]);

vars = [a1,f1,a2,f2,d];

yFiltered = zeros(preStimSize + trialSize + convergedSize, 1);
yUnfiltered = zeros(preStimSize + trialSize + convergedSize, 1);

% Task without Stim
for z = 1:preStimSize
    [yUnfiltered(z, 1), ~] = objective(span, z - 1);
    yUnfiltered(z,1) = -yUnfiltered(z,1);
    [yFiltered(z, 1), ~] = kalmanSmooth(yUnfiltered(1:z));
end

block1 = inputdlg('Hit enter when ready to continue');
% Bayesian Optimization
timer = preStimSize + 1;
fun = @(x)bayesFunc(x);
results = bayesopt(fun, vars, 'AcquisitionFunctionName', 'lower-confidence-bound', 'MaxObjectiveEvaluations', trialSize, 'IsObjectiveDeterministic', false, 'PlotFcn', []);

% Find best weights and print
yBest = yFiltered(preStimSize + 1:preStimSize + trialSize);
[~, ix] = min(yBest);
X = double(vpa(results.XTrace{:,:},6));

best = X(ix,:);

fprintf('Best Result: w1 = %.3f, f1 = %.3f, w2 = %.3f, f2 = %.3f, delay = %.3f\n', best(1), best(2), best(3), best(4), best(5));
block2 = inputdlg('Hit enter when ready to continue');

% Perform trials with sham & best
shamOrStim = randperm(convergedBlocks);
for z = 1:convergedBlocks
    weights = best;
    if (shamOrStim(z) > (convergedBlocks / 2))
        weights(1) = 1 * rand(1,1);     % W1
        weights(2) = 30 * rand(1,1);    % F1
        weights(3) = 1 * rand(1,1);     % W2
        weights(4) = 30 * rand(1,1);    % F2
    end
    stimTime = 7 + (2 - weights(5));
    for zz = 1:blockSize
        setStim(weights(1), weights(2), weights(3), weights(4), weights(5), stimTime, s);
        [yUnfiltered(preStimSize + trialSize + ((z-1) * blockSize + zz)), span] = objective(span, z);
        yUnfiltered(preStimSize + trialSize + ((z-1) * blockSize + zz)) = -yUnfiltered(preStimSize + trialSize + ((z-1) * blockSize + zz));
        yFiltered(preStimSize + trialSize + ((z-1) * blockSize + zz)) = kalmanSmooth(yUnfiltered(1:preStimSize + trialSize + ((z-1) * blockSize + zz)));

        X = [X; weights];
    end
end

% Save Data
combData = [yUnfiltered, yFiltered];
saveFileY = sprintf('Data/Behavior/%sY.mat', subjectName);
saveFileX = sprintf('Data/Behavior/%sX.mat', subjectName);
save(saveFileY, 'combData')
save(saveFileX, 'X')

% List Results
fprintf('Average Hit Rate: %f\n', -mean(combData(:,1)));
fprintf('Average Accuracy State: %f\n', -mean(combData(:,2)));
plot(-combData(:,1)); hold on
plot(-combData(:,2), '--')
legend('Hit Rate', 'Accuracy State')
title("Hit Rate and Accuracy State vs. Trial Number")

% Close connections
writeline(s, "-1");
clear('s');
clear global;


