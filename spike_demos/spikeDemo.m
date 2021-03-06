% Spot response ----------------------------------------------------
load spot;
c12_spot = Oscilloscope(resp,...
	'FrameRate', 20,... 
	'invert', true,... 
	'xbin', 150,...
	'fname', 'c12_spot.avi');
c12_spot.setStimulus('spot');
c12_spot.doVideo(40);	

% edge response -----------------------------------
load 
bw = c12.bar.resp(end-16,:);
c12_edgeBW = Oscilloscope(bw,... 
	'FrameRate', 20,... 
	'Invert', true,... 
	'xbin', 150,... 
	'fname', 'c12_edgeBW.avi',...
	'fpath', cd);
c12_edgeBW.setStimulus('edge');
c12_edgeBW.doVideo()

rg = c12.bar.resp(end-12,:);
c12_edgeRG = Oscilloscope(rg,...
	'FrameRate', 20,...
	'Invert', true,...
	'xbin', 150,...
	'fname', 'c12_edgeRG.avi');
c12_edgeRG.setStimulus('edge', 'rgFlag', true);
c12_edgeRG.doVideo(40);