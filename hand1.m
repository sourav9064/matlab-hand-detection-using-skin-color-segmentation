clear all
clc

%https://www.upgrad.com/blog/matlab-application-in-face-recognition/

fDetect = vision.CascadeObjectDetector;
img = imread('C:\Users\HP\Desktop\Needful\sourav_office.jpg');
bb = step(fDetect, img);

figure;
imshow(img); hold on

for i = 1:size(bb,1)
    rectangle('Position', bb(i,:), 'LineWidth', 5, 'LineStyle', '-', 'EdgeColor', 'r');
end
title('Face Detection');
hold off;