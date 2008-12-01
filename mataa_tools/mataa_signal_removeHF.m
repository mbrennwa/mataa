function [s,t] = mataa_signal_removeHF (s,t,fc);

% function [s,t] = mataa_signal_removeHF (s,t,fc);
%
% DESCRIPTION:
% Removes signal components with frequencies higher than fc from s(t) by repeated convolution of s with a Hann window.
% 
% INPUT:
% s: signal samples
% t: time (vector, in seconds) or sampling frequency (scalar, in Hz)
% fc: cut-off frequency (in Hz)
% 
% OUTPUT:
% s: filtered signal samples
% t: time
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
% Further information: http://www.audioroot.net/MATAA.html

if isscalar(t)
    fs = t;
    t = [0:1/fs:(length(s)-1)/fs];
else
    fs = 1 / (t(2)-t(1)); % sampling frequency
end

w = 1/fc; % window width 

n = round(w*fs);

if ~mod(n,2)
    n = n+1;
end

% repeat to get better HF removal
s = mataa_running_mean(s,n,'hann');
s = mataa_running_mean(s,n,'hann');
