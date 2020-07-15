function [HR,Q_CR] = signal2HeartRate(signal,frameRate,isDisplayFigure)
% This code calculate heart rate by deriving dominant frequency of the
% signal.

freqRange_width = 0.01;freqRange = 0.6:freqRange_width:4;% frequency range of typical human heart rates.
[pxxEst,f] = pwelch(signal,length(signal),[],freqRange,frameRate);
[~,idx] = max(pxxEst);
HR = 60*f(idx);
[Q_CR] = getQ_CR(pxxEst);

if isDisplayFigure==1
    figure
    plot(f,pxxEst,'LineWidth',5)
    hold on
    plot(f(idx),pxxEst(idx),'o')
    xlabel('Frequency [Hz]')
    ylabel('PSD')
    title('PSD of BVP')
    set(gca,'FontSize',15)
    
    figure
    plot(1/frameRate:1/frameRate:length(signal)/frameRate,signal,'LineWidth',5)
    xlabel('time [s]')
    ylabel('Anplitude')
    title('BVP')
    set(gca,'FontSize',15)
end


end