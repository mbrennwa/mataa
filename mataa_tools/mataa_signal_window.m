function s = mataa_signal_window (s0,window,par,len);

% function s = mataa_signal_window (s0,window,par,len);
%
% DESCRIPTION:
% Multiplies the signal s0 by the window function with the name 'window', and returns the result in s.
% Some window functions rely on a parameter, which can be specified by par (par can be omitted for those functions that don't rely on an extra parameter)
%
% The following window functions are available (see e.g. http://en.wikipedia.org/wiki/Window_function for a description of these functions):
% 'rectangular', 'rect', 'nowindow' : rectangular window (i.e. no window at all)
% 'gauss': gauss window, whith shape parameter sigma = par (par <= 0.5)
% 'hamming', 'hamm': Hamming window
% 'hann': Hann window (cosine window). Note: in anology to the 'Hamming' window, this is often wrongly referred to as 'Hanning'. However, the name relates to a guy called Julius von Hann.
% 'bartlett','bart','triangular': Bartlett (triangular) window.
% 'blackman', 'black': Blackman window
% 'kaiser': Kaiser window with parameter alpha = par
% 'bingham': Bingham window with parameter par (par = 0 --> rectangular window, par = 1 --> Hann window).
%
% Also, 'half' windows may be used, whereby the second half of the window is used. This is done by appending '_half' to the window name. This is useful, for instance, to attenuate echoes towards the end in an impulse response, while retaining the information at the beginning of the signal.
%
% Furthermore, mataa_signal_window can also be used to return the window function itself, see example below.
%
% INPUT:
% s0: vector containing the samples values of the original signal (i.e. the signal that will be windowed).
% window: string contining the name of the window type to be used (see above).
% par: parameter(s) to further specify the window function. Depending on the window type, par may not be required (and will be ignored in these cases).
% len: fractional length of full-amplitude range inserted between rise / fall of window slopes (optional, default: len = 0)
% 
% OUTPUT:
% s: vector containing the sample value of the windowed signal.
% 
% EXAMPLES:
%
% > s = mataa_signal_window(s,'hamming'); replaces s by a hamming-windowed version of itself
%
% > s = mataa_signal_window(s,'hamming_half'); replaces s by a version of s windowed by the second half of a hamming window
%
% > s = mataa_signal_window(repmat(1,1,1000),'gauss',0.4); returns just the gauss % 
% DISCLAIMER:
% This file is part of MATAA.
% 
% MATAA is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2 of the License, or
% (at your option) any later version.
% 
% MATAA is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
% 
% You should have received a copy of the GNU General Public License
% along with MATAA; if not, write to the Free Software
% Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
% 
% Copyright (C) 2006, 2007, 2008 Matthias S. Brennwald.
% Contact: info@audioroot.net
% Further information: http://www.audioroot.net/MATAA

N = length(s0);
n = [0:N-1];

window = lower(window);
if length(window) > 5
    if strcmp(window(end-4:end),'_half')
    	window = window(1:end-5);
    	n = n/2 + (N-1)/2;
    	ishalf = true;
    else
    	ishalf = false;
    end
end

if ~exist ('len','var')
	len = 0;
end

if len > 0 % fade-in and fade-out with unchanged part in between

	if ~ishalf % fade-in and fade-out
		NF = round (N*(1-len)/2); % number of samples in fade-in and fade-out range
		if NF > 0
			u = mataa_signal_window (s0([1:NF N-NF+1:N]),window,par,0); % apply window at fade-in and fade-out ranges of s0
			s = [	u(1:NF) ; ... 			% fade-in part
					s0(NF+1:N-NF) ; ... 	% middle part (no change)
					u(NF+1:length(u)) ...	% fade-out part
				];
		end % if NF > 0	
	else % half window -- no fade-in
		NF = round (N*(1-len)); % number of samples in fade-in range
		if NF > 0
			u = mataa_signal_window (s0(N-NF+1:N),sprintf('%s_half',window),par,0); % apply window at fade-out range of s0
			s = [ s0(1:N-NF) ; u ]; % combine unchanged part before fade-out with fade-out part at end
		end % if NF > 0	
	end % ishalf?

else % full window
		
	w = [];
	
	switch window
		case {'rect', 'rectangular', 'nowindow'}
			% leave the cropped signal as it is
			s = s0;
		case {'gauss'}        
			w = exp( -0.5 * ( (n-(N-1)/2) ./ (par*(N-1)/2) ).^2 );
		case {'hamm', 'hamming'}
			w = 0.53836 - 0.46164*cos(2*pi*n/(N-1));
		case {'hann', 'hanning'}
			w = 0.5*(1-cos(2*pi*n/(N-1)));
		case {'bart', 'bartlett', 'triangular'}
			w = 1 - 2*abs(n/(N-1)-0.5);
		case {'black', 'blackman'}
			w = 0.42 - 0.5*cos(2*pi*n/(N-1)) + 0.08*cos(4*pi*n/(N-1));
		case {'kaiser'}
			w = pi*par*sqrt(1-(2*n/(N-1)-1).^2);
			w = besseli(0,w)./besseli(0,pi*par);
		case {'bingham'}
			if (nargin < 3)
				par = 0.2;
			end
			if (par > 1 || par < 0)
				error ('mataa_signal_window: Bingham parameter must be between 0 and 1!');
			end
			if ~ishalf
				n1=floor(par/2*N);
				n2=N-2*n1;
				w1 = 0.5 * (1 - cos(2*pi*(1:n1)/(par*(N+1))));
				w=[w1 ones(1,n2) w1(n1:-1:1) ]';
			else
				w = mataa_signal_window (repmat(1,1,2*N),'bingham',par); % get a full Bingham window
				w = w(N+1:end); % keep only second half
			end
		otherwise
			error('Unknown window function!');
	end
	
	
	if isempty(w)
		s = s0; % rectangular window, 'no window'
	else
		w = reshape(w,size(s0));
		s = s0 .* w;
	end
	
end
