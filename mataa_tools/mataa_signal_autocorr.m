function [c,T] = mataa_signal_autocorr (s,t);

% function [c,T] = mataa_signal_autocorr (s,t);
%
% DESCRIPTION:
% Autocorrelation c(T) of signal s(t), for positive delays (T>=0).
%
% INPUT:
% s: vector containing the samples values of the signal.
% t: time values of the signal samples (vector, in seconds, with evenly spaced values) or sample rate (scalar, in Hz).
% 
% OUTPUT:
% c: vector containing the autocorrelation of s.
% T: time lag (vector).
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
% Copyright (C) 2007, 2008 Matthias S. Brennwald.
% Contact: info@audioroot.net
% Further information: http://www.audioroot.net/MATAA.html

if isscalar(t) % sample rate given instead of time values
	t = [0:1/t:(length(s)-1)/t];
end

if exist('OCTAVE_VERSION','builtin')
    c = autocov(s);
    c = c/c(1);
else
    c = xcorr(s,'coeff');
    c = c(length(s):end);
end

T = t-t(1);
