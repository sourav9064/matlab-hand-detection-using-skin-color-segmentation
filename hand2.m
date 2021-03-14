clear all
clc

hDetect = vision.CascadeObjectDetector;
img = imread('C:\Users\HP\DEASYSOFT Tech Pvt Ltd\3rd Project\hand_matlab\human-hand.jpg');
bb = step(hDetect, img);
disp(bb);
figure;
imshow(img);hold on

for i = 1:size(bb,1)
    rectangle('Position', bb(i,:), 'LineWidth', 5, 'LineStyle', '-', 'EdgeColor', 'r');
end
title('Hand Detection');
hold off;