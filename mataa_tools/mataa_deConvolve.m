function [y] = mataa_deConvolve(z,x);

% function [y] = mataa_deConvolve(z,x);
%
% DESCRIPTION:
% This function deconvolves z from x. In other words: if z = x*y ('z is the convolution of x and y'), then this function calculates y from z and x. The deconvolution is done using the fourier-transform method. z and x should have the same length (pad zeroes, if necessary).
%
% see also http://rkb.home.cern.ch/rkb/AN16pp/node38.html
%
% Example (calculate impulse response of a loudspeaker or other DUT):
%   x: the input signal sent to the speaker (known), length(x) = Lx
%   y: the impulse response of the speaker (not known), length(y) = Ly
%   z: the measured response of the speaker to signal x (known), length(z) = Lz
%  then: z = x*y
%  note: Lz = Lx + Ly -1
%
% then: Z = XY (where the uppercase letters denote the complex fourier transforms of x, y, and z)
% or: fft(z) = fft(x) fft(y), where x and y are padded with zeros to length Lz
% hence fft(y) = fft(z) / fft(x), or y = ifft( fft(z) / fft(x) )
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

x=x(:); z= z(:);

y=ifft(fft(z)./fft(x));

% get rid of the complex 'noise':
y=real(y);
