% -------------------------------------------------------------------------
% FALL VISION MEETING VERSION
% -------------------------------------------------------------------------
% Each cone outline was traced at multiple sections, however, this image
% shows only the outlines of cones traced at the section immediately after
% the bipolar and horizontal cell processes become entirely contained in
% the cone outline.
% -------------------------------------------------------------------------
% Some figure preferences I like
set(0, 'DefaultAxesTitleFontWeight', 'normal',...
	'DefaultAxesBox', 'off',...
	'DefaultAxesTickDir', 'out');
% A scale factor was calculated by comparing measured lines in Viking to
% pixels in Matlab measured with imdistline
scaleFac = 0.2276; 
% these are the indices of s-cones
sInd = [8 18 22 41 52 65 68 86];
lmInd = [14,43,53,75,77,81,21,96,76,62,45];

% read the image
im = imread('mosaic_filled.png');
% convert to doubles, then grayscale, then binary
im = imbinarize(rgb2gray(im2double(im)));
% close areas less than 1000 pixels. they aren't cones
im = bwareaopen(im, 1000);

% identify boundaries
[B, L] = bwboundaries(im);
% plot the results
figure(1); clf;
set(gcf, 'Name', 'Identified cones');
imshow(label2rgb(L, @jet, [0 0 0]));
hold on;
for ii = 1:length(B)
	bound = B{ii};
	plot(bound(:,2), bound(:,1), 'w', 'LineWidth', 1);
end

% get statistics
stats = regionprops('table', L, 'Area',... 
	'Centroid', 'Eccentricity',...
	'MajorAxisLength', 'MinorAxisLength',...
	'EquivDiameter', 'BoundingBox');

% get the cone area in microns
radii = scaleFac * (stats.EquivDiameter/2);
coneArea = pi * radii.^2;