close all; clear all;  clc;
image=imread('C:\Users\HP\DEASYSOFT Tech Pvt Ltd\3rd Project\hand_matlab\human-hand.jpg');
BW=binary_image(image);
BW = ~BW;
st = regionprops(BW, 'BoundingBox' );
for k = 1 : length(st)
  thisBB = st(k).BoundingBox;
  rectangle('Position', [thisBB(1),thisBB(2),thisBB(3),thisBB(4)],...
  'EdgeColor','r','LineWidth',2 )
end
