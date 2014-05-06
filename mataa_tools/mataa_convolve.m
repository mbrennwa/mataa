function z = mataa_convolve(x,y);

% function z = mataa_convolve(x,y);
%
% DESCRIPTION:
% This function convolves two data series x and y. The convolution is done using the fourier-transform method. x and y should have the same length (pad zeroes, if necessary). The result of the convolution (z) will also be of the same length as x and y.
%
% see also http://rkb.home.cern.ch/rkb/AN16pp/node38.html
%
% EXAMPLE:
% T = 1; fs = 44100; f0 = 10;
% t = [1/fs:1/fs:T];
% x = sin(2*pi*f0*t);
% y = zeros (size(x));
% y(1000) = -1.5;
% z = mataa_convolve (x,y);
% plot (t,x,'r',t,y,'k',t,z,'b')
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

X = mataa_realFT0 (x,[1:length(x)]);
Y = mataa_realFT0 (y,[1:length(y)]);
Z = X .* Y;
z = mataa_realIFT0 (Z,[0:length(Z)-1]);