function [s,t] = mataa_signal_crop (s,t,t_start,t_end);

% function [s,t] = mataa_signal_crop (s,t,t_start,t_end);
%
% DESCRIPTION:
% This function crops out the part of the signal s(t) in the range t = t_start...t_end
% 
% INPUT:
% s: siglal samples
% t: time coordinates of impulse response samples (vector, in seconds), or, alternatively, the sampling frequency of s(t) (scalar, in Hz)
%
% OUPTUT:
% s: signal samples of cropped signal
% t: time coordinates of cropped signal (in seconds)
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
% Copyright (C) 2006, 2007 Matthias S. Brennwald.
% Contact: info@audioroot.net
% Further information: http://www.audioroot.net/MATAA.html

keyboard


if isscalar(t) % t is the sampling frequency
    t = [0 : 1/t : (length(s)-1)/t];
end

% crop the signal:
i=find((t>=t_start) & (t<=t_end));
t=t(i); t = t-min(t);
s=s(i);

