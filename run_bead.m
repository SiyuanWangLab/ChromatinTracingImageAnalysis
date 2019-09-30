clear all
close all

SampleNum = '20';

FileName = ['Sequential/BEAD_00_' SampleNum];

[ImageStack, InfoFile] = ReadZStack(FileName,111,5);

ImageMean = mean(ImageStack,3);
figure(1)
imagesc(ImageMean)
colormap gray
axis equal

selectROI

figure(2)
imagesc(ImageMean)
colormap gray
axis equal
hold on

for i = 0:14
    if i<10
        FileName = ['Sequential/BEAD_0' num2str(i) '_' SampleNum];
    else
        FileName = ['Sequential/BEAD_' num2str(i) '_' SampleNum];
    end
    [ImageStack, InfoFile] = ReadZStack(FileName,111,5);
    [Xfit(i+1), Yfit(i+1), Zfit(i+1)] = fitFoci(ImageStack, roiList, i+1,1);
    figure(2)
    plot(Xfit(i+1), Yfit(i+1), 'x');
end

hold off

for i = 1:14
    Xdrift(i) = Xfit(i+1) - Xfit(1);
    Ydrift(i) = Yfit(i+1) - Yfit(1);
    Zdrift(i) = Zfit(i+1) - Zfit(1);
end

save(['DriftParams' SampleNum '.mat'], 'Xdrift', 'Ydrift', 'Zdrift');
    
