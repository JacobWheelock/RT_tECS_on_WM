%% Experiment Script
% Experiment Variables
numTrials = 50;
subjectName = string(inputdlg());

% Initialize Python
initPy()
score = 0;
span = 7;


% Initialize Data Arrays

yFiltered = zeros(preStimSize + initialSize + trialSize + convergedSize, 1);
yUnfiltered = zeros(preStimSize + initialSize + trialSize + convergedSize, 1);

% Task without Stim
for z = 1:numTrials
    [yUnfiltered(z, 1), ~] = objective(span, z - 1);
    [yFiltered(z, 1), ~] = kalmanSmooth(yUnfiltered(1:z));
end

combData = [yUnfiltered, yFiltered];

saveFile = sprintf('Data/Behavior/%s.mat', subjectName);
save(saveFile, 'combData')

%% Stats for Previous Run
fprintf('Average Hit Rate: %f\n', mean(combData(:,1)));
fprintf('Average Accuracy State: %f\n', mean(combData(:,2)));
plot(combData(:,1)); hold on
plot(combData(:,2), '--')
legend('Hit Rate', 'Accuracy State')
title("Hit Rate and Accuracy State vs. Trial Number")


%% Plots for All Subjects
figure(); hold on; ylim([0 8])
dirs = dir('Data/Behavior');
names = strings(height(dirs) - 2, 1);
for i = 3:height(dirs)
    names(i - 2) = dirs(i).name;
    path = sprintf('Data/Behavior/%s',names(i - 2,:));
    data = load(path);
    data = data.combData;
    hitRate = data(:,1);
    accState = data(:,2);
    plot(accState);
end
legend(names)
title("Accuracy State vs. Trial Number")