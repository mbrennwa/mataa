function y = mataa_running_mean(x,n,w);

% function y = mataa_running_mean(x,n,w);
%
% DESCRIPTION:
% Returns a running mean of a data series x.
% 
% INPUT:
% x: vector conaining the original data series
% n: width of the smoothing window (number of samples, should be an odd number, n > 0)
% w (optional): name of window type to be used. Default is 'rectangular', for other window types see mataa_signal_window
% 
% OUTPUT:
% y: running mean of y, length(ym) = length(y)
% 
% EXAMPLE:
% > N=1000; f0=500; fs=96000; t=[0:N-1]/fs; s = sin(2*pi*f0*t); % prepare a 500-Hz sine
% > x = s+randn(size(s))/10;                % create a noisy version of s
% > y = mataa_running_mean(x,41,'hamm');      % remove the noise using a 41 samples wide Hamming window
% > plot(t,x,'k',t,s,'g',t,y,'r')           % plot the different versions of s
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
% Copyright (C) 2006 Matthias S. Brennwald.
% Contact: info@audioroot.net
% Further information: http://www.audioroot.net/MATAA.html
%
% HISTORY:
% first version: 21. July 2006, Matthias Brennwald

if ~exist('w')
    w = 'rectangular';
end

if mod(n,2)==0
    error('Length of averaging window is even.');
end

% make sure x is a column vector

[rows, cols] = size(x);

if ~any([rows,cols] == 1)
    error('mataa_running_mean: need vector as input');
end

transpose = (rows < cols);

if transpose
    x = x';
end

% setup the window
w = mataa_signal_window(repmat(1,n,1),w); % NOTE: n should be odd
w = w/sum(w); % normalize w

% pad x to minimize end effects:
x = [ repmat(x(1),n,1) ; x ; repmat(x(end),n,1) ];

% convolve x and w:
y=conv(x,w);

% remove padded 'ends'
y = y(n+(n-1)/2:end-(n+(n+1)/2));

y = reshape(y,rows,cols); % make sure y is of the same format as the input vector