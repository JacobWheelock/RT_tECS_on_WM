%% Load in Data
subjectNum = 8;
t = [1:50];
stimShamX = []; stimShamY = [];
means = [];
all = [1:12];
distraction = [1, 5, 6, 10]; stim = [2, 3, 7]; sham = [4, 8, 11]; none = [9, 12];
group = all;
groupName = "All Aggregate Data";

subject = subjectNum;
XData = sprintf('Data/Behavior/%iX.mat', subject);
YData = sprintf('Data/Behavior/%iY.mat', subject);
shamData = sprintf('Data/Behavior/%iShamStim.mat',subject);

weightData = load(XData);
objectiveData = load(YData);
shamStimData = load(shamData);

weightData = weightData.X;
objectiveData = objectiveData.combData;
shamStimData = shamStimData.shamOrStim;

% Learning Phase Data

learningX = weightData(26:75, :);
figure()
subplot(3,2,1)
scatter(t,learningX(:,1))
subplot(3,2,2)
scatter(t,learningX(:,3))
subplot(3,2,3)
scatter(t,learningX(:,3))
subplot(3,2,4)
scatter(t,learningX(:,4))
subplot(3,2,5)
scatter(t,learningX(:,5))
