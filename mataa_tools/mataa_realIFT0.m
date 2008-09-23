function [s,t] = mataa_realIFT0 (S,f);

% function [s,t] = mataa_realIFT0 (S,f);
%
% DESCRIPTION:
% Calculates the inverse Fourier transform of a spectrum S(f) of a signal with real-valued samples. Only the 'positive' half of the spectrum is used, i.e. only positive frequencies (including f=0) must be given as input. See also mataa_realFT0.
%
% INPUT:
% S: complex fourier spectrum of the signal ('positive' half, see also DESCRIPTION).
% f: frequency values (vector)
%
% OUTPUT:
% s: signal samples (real-valued samples)
% t: time values of the signal
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
%
% HISTORY:
% 23. Sept. 2008: created this file (Matthias Brennwald)

if ~any (size (S) == 1)
    error ('mataa_realFT0: the input signal s must be of dimension 1xN or Nx1 !')
end


S = S(:); f = f(:); % make sure these are column vectors

if f(1) ~= 0
    f = [0 ; f];
    S = [0 ; S];
    warning ('mataa_realIFT0: first frequency value was not zero; padded sample for f=0.');
end

N = length(f); % number of positive frequency values, including f=0
f0 = min (f (find(f~=0)));

% construct full complex spectrum with negative frequencies
S(1) = 2 * S(1); % S(1) is the DC component, which is the sum of both sides of the spectrum
if imag (S(end)) == 0   % S can be expressed by a signal with an even number of samples
    S(end) = 2 * S(end); % S(end) belongs to both sides of the spectrum
    S = [ S ; flipud(conj(S(2:end-1))) ];
    L = 2 * (N-1);
    
else % an additional sample is needed, giving a signal with an odd number of samples
    S = [ S ; flipud(conj(S(2:end))) ];
    L = 2 * (N-1) + 1;
end

s = ifft (S); s = real(s);
t = ([0 : (L-1)] / f0 / L)';