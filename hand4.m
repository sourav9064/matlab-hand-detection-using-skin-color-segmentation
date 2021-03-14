clc;    % Clear the command window.
close all;  % Close all figures (except those of imtool.)
clear;  % Erase all existing variables. Or clearvars if you want.
format long g;
fontSize = 10;

% Get the full filename, with path prepended.
fullFileName = fullfile('C:\Users\HP\DEASYSOFT Tech Pvt Ltd\2nd Project\hand_matlab\hand3.jpg');%hand3.jpg
% Making gray image
grayImage=imread(fullFileName);
% Get the dimensions of the image.  
% numberOfColorBands should be = 1.
[rows, columns, numberOfColorBands] = size(grayImage);
if numberOfColorBands > 1
  % It's not really gray scale like we expected - it's color.
  % Convert it to gray scale by taking only the green channel.
  grayImage = grayImage(:, :, 2); % Take green channel.
end
% Display the original image.
subplot(2, 2, 1);
imshow(fullFileName);
title('Original Image', 'FontSize', fontSize);
% Display the original gray scale image.
subplot(2, 2, 2);
imshow(grayImage, []);
axis on;
title('Original Grayscale Image', 'FontSize', fontSize); 
% Making binary image
binaryImage = grayImage < 128;
% Display the image.
subplot(2, 2, 3);
imshow(binaryImage, []);
title('Labelled Image', 'FontSize', fontSize);

% Label the image
labeledImage = logical(binaryImage);%bwlabel(binaryImage);
measurements = regionprops(labeledImage, 'BoundingBox', 'Area');
for k = 1 : length(measurements)
  thisBB = measurements(k).BoundingBox;
  rectangle('Position', [thisBB(1),thisBB(2),thisBB(3),thisBB(4)],...
  'EdgeColor','r','LineWidth',2 )
end

