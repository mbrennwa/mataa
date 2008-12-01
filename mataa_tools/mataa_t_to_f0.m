function f = mataa_t_to_f0 (t);

% function f = mataa_t_to_f0 (t);
%
% DESCRIPTION:
% This function returns the frequency bins of the fourier spectrum of a signal sampled at times t (vector). t must be  be sorted and evenly spaced for this.
%
% INPUT:
% t: time values (vector, in seconds) of the signal
%
% OUTPUT:
% f: vector of the fourier-frequency bins (in Hz)
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

t = sort(t); % t should be sorted anyway, but it does not hurt to make sure it is.
u = diff(t);
dt = mean(u);

if (dt/std(u) < 100) % if the variability in the time values exceeds 1%:
    error('mataa_t_to_f0: t must be even spaced!')
end

N = length(t); % number of samples in signal
T = N*dt; % duration of the signal

% determine N (number of positive frequencies, including f=0):
if mod(N,2)
    N = (N-1)/2+1;
else
    N = N/2+1;
end

% frequency vector:
f = [0:N-1]/T;

if size(t,1) > size(t,2) % t is a column vector
	f = f';
end
