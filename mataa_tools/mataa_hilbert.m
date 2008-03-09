function y = mataa_hilbert(x)

% function y = mataa_hilbert(x)
%
% DESCRIPTION:
% Calculates the Hilbert transform of x.
%
%This code was modelled after the Hilbert transform function 'hilbert.m' available from Octave-Forge
% 
% INPUT:
% x: input signal (column vector). If x contains complex values, only the real part of these values will be used.
%
% OUTPUT:
% y: hilbert transform of x
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
% 8. November 2007 (Matthias Brennwald): improved documentation.
% 16. July 2006 (Matthias Brennwald): first version

if any(imag(x))
    warning('mataa_hilbert: complex components of input will be ignored!')
end

x = real(x); % discard any complex components from input

transpose = size(x,1)==1;
if transpose
    x = x';
end
r = length(x);
n=2^nextpow2(r);
if r < n
    x = [ x ; zeros(n-r, 1) ];
end
y = fft(x);

y = ifft([y(1,:) ; 2*y(2:n/2,:) ; y(n/2+1,:) ; zeros(n/2-1,1)]);
if r < n
    y(r+1:n,:) = [];
end

y = imag(y);

if transpose
    y = y';
end