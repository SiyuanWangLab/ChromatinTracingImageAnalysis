clear all
close all

SampleNum = '20';

FileName = ['Sequential/STORMCy5_00_' SampleNum];
load(['DriftParams' SampleNum '.mat']);
load('DeltaZ.mat');
load('tform.mat');
Color = ['r' 'g' 'b' 'c' 'm' 'y' 'k' 'r' 'g' 'b' 'c' 'm'];

[ImageStack, InfoFile] = ReadZStack(FileName,111,5);

ImageMean = mean(ImageStack,3);
% Here warp the Cy5 image into the Cy3 channel.
ImageMean_trans = imtransform(ImageMean, tform, 'XData', [1 256], 'Ydata', [1 256], 'fill', min(min(ImageMean)));
figure(100)
imagesc(ImageMean_trans)
colormap gray
axis equal
% imwrite(uint16(ImageMean),strcat('Fig100', '.tiff'),'tiff');

NewROI = questdlg('Do you want to select new ROI?'); %ask question
if(strcmp(NewROI, 'Yes'))
    selectROI
    save(['roiList' SampleNum '.mat'],'roiList')
else
    load(['roiList' SampleNum '.mat']);
end
roiListBig = roiList;

for ii = 1:length(roiListBig)
    figure(200+ii)
    imagesc(ImageMean_trans)
    colormap gray
    axis equal
    xlim([roiListBig(ii).rect(1) roiListBig(ii).rect(1)+roiListBig(ii).rect(3)]);
    ylim([roiListBig(ii).rect(2) roiListBig(ii).rect(2)+roiListBig(ii).rect(4)]);
    hold on
    if(~strcmp(NewROI, 'Yes'))
        load(['result' SampleNum '_' num2str(ii) '.mat']);
    else
        Real = ones(27,1);
    end
    Xfit = zeros(27,1);
    Yfit = zeros(27,1);
    Zfit = zeros(27,1);
    
    for i = 1:14
        if i<10
            FileName = ['Sequential/STORMCy5_0' num2str(i) '_' SampleNum];
        else
            FileName = ['Sequential/STORMCy5_' num2str(i) '_' SampleNum];
        end
        [ImageStack, InfoFile] = ReadZStack(FileName,111,5);
        % Here warp the Cy5 image into the Cy3 channel.
        for j = 1:size(ImageStack,3)
            ImageStack(:,:,j) = imtransform(ImageStack(:,:,j), tform, 'XData', [1 256], 'Ydata', [1 256]);
        end
        roiNOW = roiListBig(ii);
        roiNOW.rect = roiNOW.rect + [Xdrift(i) Ydrift(i) 0 0];
        [Xfit(i), Yfit(i), Zfit(i)] = fitFoci(ImageStack, roiNOW, i, ii);
        if Zfit(i)<1 || Zfit(i)>21
            Real(i) = 0;
        end
        Xfit(i) = Xfit(i) - Xdrift(i);
        Yfit(i) = Yfit(i) - Ydrift(i);
        Zfit(i) = Zfit(i) - Zdrift(i);
    end

    for i = 15:27
        j = i-14;
        if j<10
            FileName = ['Sequential/STORMCy3_0' num2str(j) '_' SampleNum];
        else
            FileName = ['Sequential/STORMCy3_' num2str(j) '_' SampleNum];
        end
        [ImageStack, InfoFile] = ReadZStack(FileName,111,5);
        roiNOW = roiListBig(ii);
        roiNOW.rect = roiNOW.rect + [Xdrift(j) Ydrift(j) 0 0];
        [Xfit(i), Yfit(i), Zfit(i)] = fitFoci(ImageStack, roiNOW, i, ii);
        if Zfit(i)<1 || Zfit(i)>21
            Real(i) = 0;
        end
        Xfit(i) = Xfit(i) - Xdrift(j);
        Yfit(i) = Yfit(i) - Ydrift(j);
        Zfit(i) = Zfit(i) - Zdrift(j);

    end
    figure(200+ii)
    plot(Xfit, Yfit, 'b-', 'LineWidth', 2);
    plot(Xfit, Yfit, 'or', 'MarkerSize', 5, 'MarkerFaceColor', 'r');
    for i = 1:27
        text(Xfit(i), Yfit(i), num2str(i));
    end

    % now choose the dots that are not real and mark them.
    for i = 1:27
        if Xfit(i)<roiListBig(ii).rect(1) || Xfit(i)>roiListBig(ii).rect(1)+roiListBig(ii).rect(3) ||...
                Yfit(i)<roiListBig(ii).rect(2) || Yfit(i)>roiListBig(ii).rect(2)+roiListBig(ii).rect(4)
            Real(i) = 0;
        end
    end
    
    for i = 1:27
        if Real(i) == 0;
            plot(Xfit(i), Yfit(i), 'og', 'MarkerSize', 5, 'MarkerFaceColor', 'g');
        end
    end

    if(strcmp(NewROI, 'Yes'))
        selectROI
        for i = 1:length(roiList)
            x = roiList(i).rect(1) + 0.5*roiList(i).rect(3);
            y = roiList(i).rect(2) + 0.5*roiList(i).rect(4);
            [C , I] = min(((Xfit-x).^2+(Yfit-y).^2).^0.5);
            if C < 4
                Real(I) = 0;
                plot(Xfit(I), Yfit(I), 'og', 'MarkerSize', 5, 'MarkerFaceColor', 'g');
            end
        end
    end

    hold off

    Xfit = Xfit*167/1000; %um
    Yfit = Yfit*167/1000; %um
    Yfit = 2*mean(Yfit)-Yfit;
    Zfit(1:14) = Zfit(1:14)-DeltaZ;
    Zfit = Zfit*0.2; %um

    figure(300+ii)
    plot3(Xfit, Yfit, Zfit,'LineWidth', 2);
    hold on
    for i = 1:27
        if Real(i) == 0
            scatter3(Xfit(i), Yfit(i), Zfit(i), 'og', 'MarkerFaceColor', 'g');
        else
            scatter3(Xfit(i), Yfit(i), Zfit(i), 'or', 'MarkerFaceColor', 'r');
        end
    end
    hold off
    xlabel('x');
    ylabel('y');
    zlabel('z');
    if(strcmp(NewROI, 'Yes'))
        save(['result' SampleNum '_' num2str(ii) '.mat'], 'Xfit', 'Yfit', 'Zfit', 'Real');
    end
end
    

