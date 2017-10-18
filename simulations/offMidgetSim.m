function [response, RF, stim] = offMidgetSim(varargin)
	% OFFMIDGETSIM  Simulate off midget response to grating
	%
	% INPUTS:
	%	Type 'help' for reminder on input parameters
	% OUPUTS:
	%	response	simulated response
	%	RF 			off neuron receptive field
	%	stim 		grating stimulus
	% USE:
	%	[response, RF, stim] = offMidgetSim('hz', 4);
	%
	% Note: final output isn't normalized for hz comparisons
	%
	% 24Sept2017 - SSP

	if nargin == 1 && strcmp(varargin{1}, 'help')
		disp('Input parameters:');
		disp('	cSD		[0.07]		center RF standard deviation');
		disp('	sSD		[0.21]		surround RF SD');
		disp('	hz		[2]			grating spatial frequency');
		disp('	pts 	[1:100] 	grating pixels');
		disp('	time 	[1:100]		simulation time vector');
		disp('	norm 	[true]		normalize final output');
	end

	ip = inputParser();
	addParameter(ip, 'cSD', 0.07, @isnumeric);
	addParameter(ip, 'sSD', 0.21, @isnumeric);
	addParameter(ip, 'hz', 2, @isnumeric);
	addParameter(ip, 'pts', linspace(0,1,100), @isvector);
	addParameter(ip, 'time', 1:100, @isvector);
	addParameter(ip, 'norm', true, @islogical);
	parse(ip, varargin{:})

	pts = ip.Results.pts;
	sSD = ip.Results.sSD;
	cSD = ip.Results.cSD;
	hz = ip.Results.hz;
	time = ip.Results.time;
	x0 = 0.5;

	center = normpdf(pts, x0, sSD);
	surround = normpdf(pts, x0, cSD);
	RF = -center + surround;
	RF = RF/max(abs(RF));

	grating = sin(hz * pts * 2 * pi);
	stim = bsxfun(@(x,y) circshift(x, [y 0]), grating', time);
	stim = stim';

	response = zeros(1, numel(pts));
	for ii = 1:numel(pts)
		response(1, ii) = RF * stim(ii,:)';
	end

	if ip.Results.norm
		response = response/max(abs(response));
	end