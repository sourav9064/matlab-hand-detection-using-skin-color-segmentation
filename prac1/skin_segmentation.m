clc;    % Clear the command window.
close all;  % Close all figures (except those of imtool.)
imtool close all;  % Close all imtool figures.
clear;  % Erase all existing variables.
workspace;  % Make sure the workspace panel is showing.
format longg;
format compact;
fontSize = 20;

% Change the current folder to the folder of this m-file.
if(~isdeployed)
	cd(fileparts(which(mfilename)));
end
	
% Check that user has the Image Processing Toolbox installed.
hasIPT = license('test', 'image_toolbox');
if ~hasIPT
	% User does not have the toolbox installed.
	message = sprintf('Sorry, but you do not seem to have the Image Processing Toolbox.\nDo you want to try to continue anyway?');
	reply = questdlg(message, 'Toolbox missing', 'Yes', 'No', 'Yes');
	if strcmpi(reply, 'No')
		% User said No, so exit.
		return;
	end
end

% Read in a standard MATLAB color demo image.
folder = fullfile(matlabroot, '\toolbox\images\imdemos');
baseFileName = 'kids.tif';
% Get the full filename, with path prepended.
fullFileName = fullfile(folder, baseFileName);
if ~exist(fullFileName, 'file')
	% Didn't find it there.  Check the search path for it.
	fullFileName = baseFileName; % No path this time.
	if ~exist(fullFileName, 'file')
		% Still didn't find it.  Alert user.
		errorMessage = sprintf('Error: %s does not exist.', fullFileName);
		uiwait(warndlg(errorMessage));
		return;
	end
end
[indexedImage, colorMap] = imread(fullFileName);
% Convert from indexed to RGB color
rgbImage = ind2rgb(indexedImage, colorMap);
% It seems to have a lot of dithering or noise in it so
% let's clean it up a bit with a median filter.
rgbImage(:,:,1) = medfilt2(rgbImage(:,:,1), [3 3]);
rgbImage(:,:,2) = medfilt2(rgbImage(:,:,2), [3 3]);
rgbImage(:,:,3) = medfilt2(rgbImage(:,:,3), [3 3]);

% The gamut of this indexed demo image is still fairly quantized so let's blur the S and H channels
% to make the colors that are present more continuous and not as quantized.
hsv = rgb2hsv(rgbImage);
% Get separate channels.
h = hsv(:, :, 1);
s = hsv(:, :, 2);
v = hsv(:, :, 3);
% Blur h and v channels.  Don't blur v channel so the image doesn't look blurred.
s = conv2(s, ones(3)/9, 'same');
h = conv2(h, ones(3)/9, 'same');
% Recombine.
hsv = cat(3, h, s, v);
rgbImage = hsv2rgb(hsv);

% Get the dimensions of the image.  numberOfColorBands should be = 3.
[rows, columns, numberOfColorBands] = size(rgbImage);
% Display the original color image.
subplot(2, 2, 1);
imshow(rgbImage, []);
title('Starting Color Image', 'FontSize', fontSize);
% Enlarge figure to full screen.
set(gcf, 'units','normalized','outerposition',[0 0.05 1 .95]);

% Convert to hsv color space.
hsv = rgb2hsv(rgbImage);
h = hsv(:, :, 1);
s = hsv(:, :, 2);
v = hsv(:, :, 3);

% Display them all.
subplot(2, 2, 2);
imshow(h, []);
title('Hue Image', 'FontSize', fontSize);
subplot(2, 2, 3);
imshow(s, []);
title('Saturation Image', 'FontSize', fontSize);
subplot(2, 2, 4);
imshow(v, []);
title('Value Image', 'FontSize', fontSize);
% Put up status bar so user can mouse around images and see pixel values.
% Status bar will be in the lower left corner of the figure.
hv = impixelinfo();

% Get histograms of them all
figure;
% First, display the HSV array with a status bar so we can inspect values.
subplot(2, 2, 1);
imshow(hsv, []);
caption = sprintf('HSV Image - mouse over and\nlook at pixel info at bottom left.');
title(caption, 'FontSize', fontSize);
% Put up status bar so user can mouse around images and see pixel values.
% Status bar will be in the lower left corner of the figure.
hv = impixelinfo();

% Let's compute and display the h histogram.
[pixelCount, grayLevels] = hist(h(:), 100);
subplot(2, 2, 2); 
bar(grayLevels, pixelCount);
grid on;
title('Histogram of Hue Image', 'FontSize', fontSize);
xlim([0 grayLevels(end)]); % Scale x axis manually.
% Enlarge figure to full screen.
set(gcf, 'units','normalized','outerposition',[0 0.05 1 .95]);

% Let's compute and display the s histogram.
[pixelCount, grayLevels] = hist(s(:), 100);
subplot(2, 2, 3); 
bar(grayLevels, pixelCount);
grid on;
title('Histogram of Saturation Image', 'FontSize', fontSize);
xlim([0 grayLevels(end)]); % Scale x axis manually.

% Let's compute and display the s histogram.
[pixelCount, grayLevels] = hist(v(:), 100);
subplot(2, 2, 4); 
bar(grayLevels, pixelCount);
grid on;
title('Histogram of Value Image', 'FontSize', fontSize);
xlim([0 grayLevels(end)]); % Scale x axis manually.

% Example calling for a double, floating point monochrome image.  
% The image does not need to be in the range 0-1 - it can have any range.
% Starting range is initialized to (-0.5 to 0.27).
% [lowHThreshold, highHThreshold] = threshold(0, 0.07, h)
% [lowSThreshold, highSThreshold] = threshold(0.25, 1, s)
% [lowVThreshold, highVThreshold] = threshold(0.57, 1, v)

% Try to get a binary image of skin.
hBinary = h < 0.07;
sBinary = s > 0.25;
vBinary = v > 0.57;
skinPixels = hBinary & sBinary & vBinary;

% Display them all.
figure;
subplot(2, 3, 1);
imshow(skinPixels, []);
title('Skin Pixels - ANDing of all binary images', 'FontSize', fontSize);
subplot(2, 3, 2);
imshow(hBinary, []);
title('Hue Image Binarized', 'FontSize', fontSize);
subplot(2, 3, 3);
imshow(sBinary, []);
title('Saturation Image Binarized', 'FontSize', fontSize);
subplot(2, 3, 4);
imshow(vBinary, []);
title('Value Image Binarized', 'FontSize', fontSize);
% Put up status bar so user can mouse around images and see pixel values.
% Status bar will be in the lower left corner of the figure.
hv = impixelinfo();
% Mask the image.
maskedRgbImage = bsxfun(@times, rgbImage, cast(skinPixels,class(rgbImage)));
subplot(2,3, 5);
imshow(maskedRgbImage);
title('Skin Pixels in Color', 'FontSize', fontSize);
maskedRgbImage = bsxfun(@times, rgbImage, cast(~skinPixels,class(rgbImage)));
subplot(2,3, 6);
imshow(maskedRgbImage);
title('Non-Skin Pixels in Color', 'FontSize', fontSize);

% Enlarge figure to full screen.
set(gcf, 'units','normalized','outerposition',[0 0.05 1 .95]);

promptMessage = sprintf('Do you want to Continue, this time using YCbCr color space,\nor Cancel to abort processing?');
titleBarCaption = 'Continue?';
button = questdlg(promptMessage, titleBarCaption, 'Continue', 'Cancel', 'Continue');
if strcmp(button, 'Cancel')
	return;
end

% Convert to hsv color space.
hsv = rgb2ycbcr(rgbImage);
y = hsv(:, :, 1);
cb = hsv(:, :, 2);
cr = hsv(:, :, 3);

% Display them all.
figure;
subplot(2, 2, 1);
imshow(rgbImage);
% Enlarge figure to full screen.
set(gcf, 'units','normalized','outerposition',[0 0.05 1 .95]);
subplot(2, 2, 2);
imshow(y, []);
title('Y Image', 'FontSize', fontSize);
subplot(2, 2, 3);
imshow(cb, []);
title('Cb Image', 'FontSize', fontSize);
subplot(2, 2, 4);
imshow(cr, []);
title('Cr Image', 'FontSize', fontSize);
% Put up status bar so user can mouse around images and see pixel values.
% Status bar will be in the lower left corner of the figure.
hv = impixelinfo();

% Get histograms of them all
figure;
% First, display the HSV array with a status bar so we can inspect values.
subplot(2, 2, 1);
imshow(hsv, []);
title('Original Color Image', 'FontSize', fontSize);
% Put up status bar so user can mouse around images and see pixel values.
% Status bar will be in the lower left corner of the figure.
hv = impixelinfo();

% Let's compute and display the h histogram.
[pixelCount, grayLevels] = hist(y(:), 100);
subplot(2, 2, 2); 
bar(grayLevels, pixelCount);
grid on;
title('Histogram of Y Image', 'FontSize', fontSize);
xlim([0 grayLevels(end)]); % Scale x axis manually.
% Enlarge figure to full screen.
set(gcf, 'units','normalized','outerposition',[0 0.05 1 .95]);

% Let's compute and display the s histogram.
[pixelCount, grayLevels] = hist(cb(:), 100);
subplot(2, 2, 3); 
bar(grayLevels, pixelCount);
grid on;
title('Histogram of Cb Image', 'FontSize', fontSize);
xlim([0 grayLevels(end)]); % Scale x axis manually.

% Let's compute and display the s histogram.
[pixelCount, grayLevels] = hist(cr(:), 100);
subplot(2, 2, 4); 
bar(grayLevels, pixelCount);
grid on;
title('Histogram of Cr Image', 'FontSize', fontSize);
xlim([0 grayLevels(end)]); % Scale x axis manually.

% [lowHThreshold, highHThreshold] = threshold(0.7, 1, y)
% [lowSThreshold, highSThreshold] = threshold(0.25, 1, cb)
% [lowVThreshold, highVThreshold] = threshold(0.57, 1, cr)
% Try to get a binary image of skin
yBinary = y > 0.5;
cbBinary = cb > 0.38 & cb < 0.44;
crBinary = cr > 0.57;
skinPixels = yBinary & cbBinary & crBinary;

% Display them all.
figure;
subplot(2, 3, 1);
imshow(skinPixels, []);
title('Skin Pixels', 'FontSize', fontSize);
% Enlarge figure to full screen.
set(gcf, 'units','normalized','outerposition',[0 0.05 1 .95]);
drawnow;

subplot(2, 3, 2);
scatter(y(:), cb(:));
% imshow(yBinary, []);
title('Cb vs. Y', 'FontSize', fontSize);
xlabel('Y', 'FontSize', fontSize);
ylabel('Cb', 'FontSize', fontSize);
drawnow;

subplot(2, 3, 3);
imshow(cbBinary, []);
scatter(y(:), cr(:));
title('Cr vs. Y', 'FontSize', fontSize);
xlabel('Y', 'FontSize', fontSize);
ylabel('Cr', 'FontSize', fontSize);
drawnow;

subplot(2, 3, 4);
% imshow(crBinary, []);
scatter(cb(:), cr(:));
title('Cr vs. Cb', 'FontSize', fontSize);
xlabel('Cb', 'FontSize', fontSize);
ylabel('Cr', 'FontSize', fontSize);
drawnow;

% Mask the image.
maskedRgbImage = bsxfun(@times, rgbImage, cast(skinPixels,class(rgbImage)));
subplot(2,3, 5);
imshow(maskedRgbImage);
title('Skin Pixels in Color', 'FontSize', fontSize);
maskedRgbImage = bsxfun(@times, rgbImage, cast(~skinPixels,class(rgbImage)));
subplot(2,3, 6);
imshow(maskedRgbImage);
title('Non-Skin Pixels in Color', 'FontSize', fontSize);

% Put up status bar so user can mouse around images and see pixel values.
% Status bar will be in the lower left corner of the figure.
hv = impixelinfo();

msgbox('Done with demo.');