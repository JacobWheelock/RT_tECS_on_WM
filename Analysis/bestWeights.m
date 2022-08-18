close all
stimEff= [2,3,7];
distraction = [1, 5, 6, 10];
shamEff = [4,8,11];
none = [9, 12];
all = [1:12];
stim = [];
sham = [];
baseline = [];
for i = 1:length(all)
    subject = all(i);
    %% Load in Data
    XData = sprintf('Data/Behavior/%iX.mat', subject);
    YData = sprintf('Data/Behavior/%iY.mat', subject);
    shamData = sprintf('Data/Behavior/%iShamStim.mat',subject);

    weightData = load(XData);
    objectiveData = load(YData);
    shamStimData = load(shamData);

    weightData = weightData.X;
    objectiveData = objectiveData.combData;
    shamStimData = shamStimData.shamOrStim;

    %% Seperate Data
    % Learning Phase
    learningX = weightData(1:50,:);
    learningY = objectiveData(26:75,2);
    [~, idx] = min(learningY);
    minX = learningX(idx,:);



    %% Plot data

    % Plot Bar Graph
    subplot(1,3,1);
    plot(minX(1)', 0.5,'-or');
    hold on;
    plot(minX(3)', -0.5, '-ob');
    ax = gca;
    ax.YTick = [-0.5, 0, 0.5];
    ax.YTickLabels = {'Amplitude 2','','Amplitude 1'};
    ylim([-1 1])
    xlim([0 1])
    xlabel('Amplitude (mA)')
    ax = gca;
    ax.FontSize = 20;


    t1 = sprintf('Aggregate Best\nAmplitude Weights');
    title(t1)
    % Plot Bar Graph
    subplot(1,3,2);
    plot(minX(2)', 0.5,'-or');
    hold on;
    plot(minX(4)', -0.5, '-ob');
    ax = gca;
    ax.YTick = [-0.5, 0, 0.5];
    ax.YTickLabels = {'Frequency 2','','Frequency 1'};
    ylim([-1 1])
    xlim([0 30])
    xlabel("Frequency (Hz)")
    ax = gca;
    ax.FontSize = 20;



    t2 = sprintf('Aggregate Best\nFrequency Weights');
    title(t2)

    % Plot Bar Graph
    subplot(1,3,3);
    plot(minX(5)', 0.0,'-or');
    hold on;
   
    ax = gca;
    ax.YTick = [-0.5, 0, 0.5];
    ax.YTickLabels = {'','Delay',''};
    ylim([-1 1])
    xlim([0 2])
    xlabel("Delay (s)")
    ax = gca;
    ax.FontSize = 20;



    t3 = sprintf('Aggregate Best\nDelay Weights');
    title(t3);


end



