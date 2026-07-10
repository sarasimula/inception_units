%##########################################################################
%                   INCEPTION SINGLE UNITS ANALYSIS
%##########################################################################

%% Upload clu and res 
% in adrian: /media/data-150/Inception/
clear
mainfold = "/media/data-150/Inception/";
filepath = mainfold + "RatD-202511/Neuropixels_data/RatD_2025-11-19_20/";

cd(filepath)
load("RatD_2025-11-19_20.CluRes.mat")
% G= units ID
% T=time samples of AP for each unit in G

xmlfeat = fileread('RatD_2025-11-19_20.xml');
tok = regexp(xmlfeat, '<samplingRate>(\d+)</samplingRate>', 'tokens');
fs = str2double(tok{1}{1});
clearvars Map tok xmlfeat %clean workspace

spikeTimeSec(:,1) = double(T) / fs;
spikeTimeSec(:,2) = G; %units ids

%% Preprocessing
% clean low FR
recStart = min(spikeTimeSec(:,1));
recEnd   = max(spikeTimeSec(:,1));
recDur   = recEnd - recStart;  

unitID = unique(G);
unitID(unitID <= 1) = [];       % drop noise (0) and MUA (1)

% thresholds
minSpkCount = 100;    % preliminary, 100 minimum spikes in whole rec
minFR = 0.01;   % Hz, floor for active unit

unitsAll = struct('clusterID', {}, 'spikeTimes', {}, 'firingRate', {}, 'nSpikes', {});
rejected = struct('clusterID', {}, 'nSpikes', {}, 'firingRate', {}, 'reason', {});

for u = 1:numel(unitID)
    idx = G == unitID(u);
    nSp = sum(idx);
    fr  = nSp / recDur;

    if nSp < minSpkCount || fr < minFR
        ui = numel(rejected) + 1;
        rejected(ui).clusterID = unitID(u);
        rejected(ui).nSpikes   = nSp;
        rejected(ui).firingRate = fr;
        continue
    end

    ui = numel(unitsAll) + 1;
    unitsAll(ui).clusterID  = unitID(u);
    unitsAll(ui).spikeTimes = spikeTimeSec(idx,1);
    unitsAll(ui).nSpikes    = nSp;
    unitsAll(ui).firingRate = fr;
end

fprintf('Kept %d / %d units (%d rejected: <%d spikes or <%.3f Hz)\n', ...
    numel(unitsAll), numel(unitID), numel(rejected), minSpkCount, minFR);

clearvars -except mainfold filepath fs spikeTimeSec unitsAll recStart recEnd

%% Upload sws-->rem transitions timepoints

% i dont have them yet so I ll just create a dummy
swstorem = sort(rand(200, 1).*(recEnd-recStart) + recStart);

%% Compute PETH for sws-->rem transiitions

for ui = 1:numel(unitsAll)
    spk = unitsAll(ui).spikeTimes;
    [peth,t,mean] = PETH(spk, swstorem, 'durations', [-1 1], 'nBins', 101);
    unitsAll(ui).peth = peth;
    unitsAll(ui).t    = t;
    unitsAll(ui).mean = mean;
    clearvars peth t mean spk
end

tbins = unitsAll(1).t;
avgpeth = vertcat(unitsAll.mean);
[avgpeth_sort] = sortby_sara(avgpeth, 'max');
zpeth = nanzscore(avgpeth_sort, 1, 2);

%% Plot PETH

figure;
colorlim = [-2,2];
sgtitle('Fake SWS-REM transitions')

subplot(1,2,1)
PlotColorMap(zpeth,'x',tbins); hold on;
xline(0,'k--');
xlabel('Time (s)'); ylabel('Unit #');
clim(colorlim); colormap('parula'); c = colorbar('Ticks',linspace(-2, 2, 9));
c.Label.String = 'z-score FR'; c.Label.FontSize = 7;
title('Heatmap unit by unit', 'FontSize', 8)


subplot(1,2,2)
semplot(tbins, zpeth,'r','smooth',3); hold on;
xline(0,'k--'); ylim(colorlim);
ylabel('Firing rate (z-scored)');
legend({'all units avg peth','sem', 'transition'}, "Location","northwest", "FontSize", 6, "IconColumnWidth", 3);
title('Population response around transition', 'FontSize', 8)


%% Rasterplot
