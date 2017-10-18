classdef Oscilloscope < handle
    % 6Oct2017 - SSP
    
    properties (Access = public)
        response
        filePath
        fileName
        stimFlag = false
    end
    
    properties (SetAccess = private, GetAccess = public)
        stim
        params = containers.Map();
        xpts                % time axis in seconds
    end
    
    properties (Transient = true, SetAccess = private)
        media  		       % VideoWriter or GIF image matrix
        numFrames
        handles = struct();
        frameNum = 1;
    end
    
    properties (Constant = true, Hidden = true)
        FORMATS = {'avi', 'gif'};
        FRAMETOL = 1000             % Frame limit
    end
    
    properties (Dependent = true)
        x0          % current xpt at beginning of oscilloscope window
        x1          % the x-axis value at end of oscilloscope window
        fColor      % foreground color
        bColor      % background color
    end
    
    methods
        function obj = Oscilloscope(response, varargin)
            ip = inputParser();
            ip.CaseSensitive = false;
            addRequired(ip, 'response', @isvector);
            addParameter(ip, 'xbin', 100, @isnumeric); %ms
            addParameter(ip, 'frameRate', 25, @isnumeric); %hz
            addParameter(ip, 'sampleRate', 10e3, @isnumeric); %hz
            addParameter(ip, 'invert', false, @islogical);
            addParameter(ip, 'fname', 'oscilloscope.avi', @ischar);
            addParameter(ip, 'fpath', cd, @isdir);
            addParameter(ip, 'fmt', 'gif',...
                @(x) any(validatestring(x, obj.FORMATS)));
            
            parse(ip, response, varargin{:});
            obj.response = response;

            obj.fileName = ip.Results.fname;
            obj.filePath = ip.Results.fpath;
            
            obj.params('sampleRate') = ip.Results.sampleRate;  
            % inputs are ms. for consistency immediately convert to pts
            obj.params('xbin') = obj.ms2pts(ip.Results.xbin);
            obj.params('frameRate') = obj.ms2pts(ip.Results.frameRate);

            % keeping here for convinience                
            obj.params('invert') = ip.Results.invert;

            % the time axis in seconds            
            obj.xpts = 1:length(obj.response);
            obj.xpts = obj.xpts/obj.params('sampleRate');
            
            obj.numFrames = length(1:numel(obj.response)-obj.params('xbin')); % pts
            obj.numFrames = obj.pts2frame(obj.numFrames);
            
            % Catch large frame number errors
            if obj.numFrames > obj.FRAMETOL 
                fprintf('frames requested (%u) exceeds frame tolerance of %u\n',...
                    obj.numFrames, obj.FRAMETOL);
                return;
            else
                fprintf('creating %g frames\n', obj.numFrames);
            end
        end
        
        function setPath(obj, fpath)
            obj.filePath = fpath;
            if obj.filePath(end) ~= filesep
                obj.filePath = [obj.filePath filesep];
            end
            fprintf('Saving to %s%s\n', obj.filePath, obj.fileName);
        end
        
        function setStimulus(obj, stimType, varargin)
            % SETSTIMULUS
            %   Required:       
            %       type        ('bar', 'spot', 'edge')
            %   Optional:
            %       colors      [bColor, fColor]    stimulus colors
            %       timing      []                  stimulus timing (pre, stim, post)
            %
            obj.stim.type = validatestring(stimType, {'bar', 'spot', 'edge'});
            
            ip = inputParser();
            ip.CaseSensitive = false;
            ip.KeepUnmatched = true;
            addParameter(ip, 'timing', [], @(x) isequal(sum(x), length(obj.response)));
            addParameter(ip, 'colors', [obj.bColor; obj.fColor], @(x) ismatrix(x) || ischar(x));
            parse(ip, varargin{:});
            obj.stim.timing = ip.Results.timing;
            obj.stim.colors = ip.Results.colors;

            
            switch obj.stim.type
                case {'bar', 'edge'}
                    obj.setMap(ip.Unmatched);
                case 'spot'
                    obj.setSpot(ip.Unmatched);
            end
            obj.stimFlag = true;
        end
        
        function doVideo(obj, videoFrameRate)
            if nargin < 2
                videoFrameRate = obj.params('frameRate');
            end
            % setup the axes
            obj.createAxes();
            % create the media object
            obj.media = VideoWriter([obj.filePath filesep obj.fileName]);
            % video frame rate needs hz
            obj.media.FrameRate = videoFrameRate;
            open(obj.media);
            % plot the frames
            for i = 1:obj.numFrames
                obj.frameNum = i;
                obj.frameSpikes();
                obj.addStim();
                f = getframe(obj.handles.fh);
                writeVideo(obj.media, f);
            end
            close(obj.media);
            obj.frameNum = 1;
        end
        
        function doGif(obj)
            obj.createAxes();
            f = getframe();
            [im, map] = rgb2ind(f.cdata, 256, 'nodither');
            im(1,1,1, obj.numFrames+1) = 0;
            for i = 1:obj.numFrames
                obj.frameNum = i;
                obj.frameSpikes();
                obj.addStim();
                f = getframe();
                im(:, :, 1, i) = rgb2ind(f.cdata, map, 'nodither');
            end
            obj.frameNum = 1;
            imwrite(im, map, [obj.filePath obj.fileName],...
                'DelayTime', 0,...
                'LoopCount', 'inf');
            fprintf('Saved to %s\n', obj.fileName);
        end

        function checkStim(obj)
            if ~isempty(obj.stim)
                switch obj.stim.type
                    case {'edge', 'bar'}
                        fh = figure();
                        ax = axes('Parent', fh);
                        imagesc(obj.stim.map, 'Parent', ax);
                    otherwise
                        return;
                end
            end
        end
        
        % Dependent methods get/set -------------------------------
        function x0 = get.x0(obj)
            x0 = obj.frame2pts(obj.frameNum);
        end
        
        function x1 = get.x1(obj)
            x1 = obj.x0 + obj.params('xbin');
        end

        function fColor = get.fColor(obj)
            if obj.params('invert')
                fColor = 'w';
            else
                fColor = 'k';
            end
        end

        function bColor = get.bColor(obj)
            if obj.params('invert')
                bColor = 'k';
            else
                bColor = 'w';
            end
        end
    end
    
    methods (Access = private)
        function addStim(obj)
            if obj.stimFlag
                switch obj.stim.type
                    case 'spot'
                        obj.frameSpot();
                    case {'bar', 'edge'}
                        obj.frameMap();
                end
            end
        end
        
        function frameSpikes(obj)
            plot(obj.xpts(obj.x0 : obj.params('xbin')+obj.x0),...
                obj.response(obj.x0 : obj.params('xbin')+obj.x0),...
                'Color', obj.fColor,...
                'Parent', obj.handles.ax.resp);
        end
        
        function frameSpot(obj)
            if obj.x1 >= obj.stim.timing(1) && ...
                    obj.x1 <= (sum(obj.stim.timing(1:2)))
                set(obj.handles.stim,...
                    'FaceColor', obj.stim.color,...
                    'EdgeColor', obj.stim.color);
            else
                set(obj.handles.stim,...
                    'FaceColor', obj.bColor,...
                    'EdgeColor', obj.bColor);
            end
        end
        
        function frameMap(obj)
            if ~any(obj.stim.map(obj.frameNum,:))
                obj.handles.stim = rectangle(1,1,...
                    'Color', obj.bColor,...
                    'Parent', obj.handles.ax.stim);
            else
                obj.handles.stim = imagesc(obj.stim.map(obj.frameNum,:),...
                    'Parent', obj.handles.ax.stim);
            end
        end

        function createAxes(obj)
            obj.handles.fh = figure('Color', obj.bColor);
            
            if obj.stimFlag
                figPos(obj.handles.fh, 0.45, 1);
                mainLayout = uix.VBox(...
                    'Parent', obj.handles.fh,...
                    'BackgroundColor', obj.bColor);
                obj.handles.ax.stim = axes('Parent', mainLayout);
                obj.handles.ax.resp = axes('Parent', mainLayout);
                set(mainLayout, 'Heights', [-1, -1.75]);
                
                switch obj.stim.type
                    case 'spot'
                        obj.handles.stim = rectangle(obj.handles.ax.stim,...
                            'Position', [0 0 2 2],...
                            'Curvature', 1,...
                            'FaceColor', obj.bColor,...
                            'EdgeColor', obj.bColor);
                        axis(obj.handles.ax.stim, 'square');
                    case {'bar', 'edge'}
                        colormap(obj.handles.ax.stim, obj.stim.colors);
                end
            else
                obj.handles.ax.resp = axes('Parent', obj.handles.fh);
                figPos(obj.handles.fh, 0.45, 0.75);
            end

            axis(findall(obj.handles.fh, 'Type', 'axes'), 'tight');
            set(findall(obj.handles.fh, 'Type', 'axes'),...
                'Color', obj.bColor,...
                'NextPlot', 'ReplaceChildren',...
                'Visible', 'off');
            
            set(obj.handles.ax.resp,...
                'YLim', [min(obj.response) max(obj.response)]);
        end
        
        function setSpot(obj, varargin)
            if isempty(timing) && length(obj.response) == 15000
                % The default ChromaticSpot stimulus timing
                obj.stim.timing = obj.ms2pts([500 500 500]);
            else
                warning('Set stimulus timing');
                return;
            end
            obj.stim.timing = obj.ms2pts(obj.stim.timing);
        end        

        function setBar(obj, varargin)            
            if isempty(obj.stim.timing) && length(obj.response) == 35000
                % The default MovingBar stimulus
                obj.stim.timing = obj.ms2pts([500 2500 500]);
            else
                warning('Set stimulus timing');
                return;
            end
            
            ip = inputParser();
            ip.CaseSensitive = false;
            addParameter(ip, 'rgFlag', false, @islogical);
            addParameter(ip, 'barWidth', 1, @isnumeric);
            parse(ip, varargin{:});
            
            obj.stim.barWidth = ip.Results.barWidth;
            obj.stim.rgFlag = ip.Results.rgFlag;
        
            obj.stim.trigger = obj.pts2frame(obj.stim.timing(1));
            
            if strcmp(obj.stim.type, 'edge')
                obj.stim.map = zeros(ceil(obj.pts2frame(obj.stim.timing(2))));
                for i = 1:size(obj.stim.map, 1)
                    obj.stim.map(i, 1:i) = 1;
                end
            else
                obj.stim.map = eye(ceil(obj.pts2frame(obj.stim.timing(2))));
            end
            obj.stim.map = padarray(obj.stim.map,...
                [obj.stim.trigger 0], 'pre');
            obj.stim.map = cat(1, obj.stim.map,...
                ones(obj.numFrames - size(obj.stim.map,1), length(obj.stim.map)));
            obj.handles.stim = [];
        end
    end

    % Conversions for pts, frames, ms
    methods (Access = private) 
        function pts = frame2pts(obj, frames)
            pts = frames * obj.params('sampleRate')/obj.params('frameRate');
        end

        function frames = pts2frame(obj, pts)
            frames = pts * obj.params('frameRate')/obj.params('sampleRate');
        end

        function pts = ms2pts(obj, ms)
            pts = ms * obj.params('sampleRate')/1e3;
        end

        function frames = ms2frame(obj, ms)
            pts = obj.ms2pts(ms);
            frames = obj.pts2frame(pts);
        end
    end
end

