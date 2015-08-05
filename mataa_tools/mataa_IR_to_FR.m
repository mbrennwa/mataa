function [mag,phase,f] = mataa_IR_to_FR (h,t,smooth_interval,unit);

% function [mag,phase,f] = mataa_IR_to_FR (h,t,smooth_interval,unit);
%
% DESCRIPTION:
% Calculate frequency response (magnitude in dB and phase in degrees) of a system with impulse response h(t)
%
% INPUT:
% h: impulse response (in volts)
% t: time coordinates of samples in h (vector, in seconds) or sampling rate of h (scalar, in Hz)
% smooth_interval (optional): if specified, the frequency response is smoothed over the octave interval smooth_interval.
% unit (optional): unit of h.
%
% OUTPUT:
% mag: magnitude of frequency response (in dB). If unit of h is 'Pa' (Pascal), then mag is referenced to 20 microPa (standard reference sound pressure level).
% phase: phase of frequency response (in degrees). This is the TOTAL phase including the 'excess phase' due to (possible) time delay of h(h). phase is unwrapped (i.e. it is not limited to +/-180 degrees, and there are no discontinuities at +/- 180 deg.)
% f: frequency coordinates of mag and phase
%
% EXAMPLE:
% > [h,t] = mataa_IR_demo; 
% > [mag,phase,f] = mataa_IR_to_FR(h,t); % calculates magnitude(f) and phase(f)
% > [mag,phase,f] = mataa_IR_to_FR(h,t,1/8); % same as above, but smoothed to 1/8 octave resolution
% (use mataa_plot_FR(mag,phase,f) to plot the results)
%
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

if ~exist ('unit','var')
	unit = 'unknown';
end

if isscalar(t)
    t = [0:1/t:(length(h)-1)/t];
end

h = h(:); % make sure h is column vector

%%% Don't do this (just consider what happens if h(1) = 1 and h(2:end) = 0):
%%% h = h - linspace(h(1),h(end),length(h))' + mean(h); % make sure s is periodic

% if exist('smooth_interval','var')
% 	T = max(t)-min(t);
% 	fMin = 1/T;
% 	df = fMin*smooth_interval;
% 	T = 1/df;
% 	[h,t] = mataa_signal_pad_Zeros(h,t,T); % pad the impulse response to length T, so we can calculate the freqeuncy response with (faked) frequency resolution of df
% end

[p,f] = mataa_realFT(h,t);

% mag:
if strcmp (unit,'Pa')
	p_ref = 20E-6; % reference sound pressure
	mag = 20*log(abs(p)/p_ref);
	unit = 'dB SPL';
else
	mag = 20*log10(abs(p));
	mag = mag + 112;
	unit = 'dB';
end

% unwrap the phase, and convert from radians to degrees
phase = unwrap(angle(p))/pi*180;

if exist("smooth_interval","var")
	disp ('mataa_IR_to_FR: smoothing data...')
	[mag,phase,f] = mataa_FR_smooth(mag,phase,f,smooth_interval);
	disp ('mataa_IR_to_FR: ...done.')
end
	
end
