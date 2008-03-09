function s = mataa_signal_window(s0,window,par);

% function [s,t] = mataa_signal_window(s0,window,par);
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
%
% Also, 'half' windows may be used, whereby the second half of the window is used. This is done by appending '_half' to the window name. This is useful, for instance, to attenuate echoes towards the end in an impulse response, while retaining the information at the beginning of the signal.
%
% Furthermore, mataa_signal_window can also be used to return the window function itself, see example below.
%
% INPUT:
% s0: vector containing the samples values of the original signal (i.e. the signal that will be windowed).
% window: string contining the name of the window type to be used (see above).
% par: parameter(s) to further specify the window function. Depending on the window type, par may not be required (and will be ignored in these cases).
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
% Copyright (C) 2006 Matthias S. Brennwald.
% Contact: info@audioroot.net
% Further information: http://www.audioroot.net/MATAA.html
%
% HISTORY:
% 9. July 2006  (Matthias Brennwald): first version

N = length(s0);
n = [0:N-1];

window = lower(window);

if length(window)>5
    if strcmp(window(end-4:end),'_half')
        window = window(1:end-5);
        n = n/2 + (N-1)/2;
    end
end

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
    otherwise
        error('Unknown window function!');
end


if isempty(w)
    s = s0; % rectangular window, 'no window'
else
    w = reshape(w,size(s0));
    s = s0 .* w;
end