function [S,f] = mataa_realFT0 (s,t);

% function [S,f] = mataa_realFT0 (s,t);
%
% DESCRIPTION:
% Calculates the complex fourier-spectrum S of a real signal s for frequencies f >= 0. Only the half spectrum corresponding to positive frequencies is returned, because for a real signal S(-f)=S*(f). S is normalized to length of s. The fourier spectrum S therefore does not depend on the sample rate used to digitize a given signal (i.e. S does not depend on the length of the signal). s can be of any length (no padding to length of 2n or even length necessary). In order to avoid frequency leakage, mataa_realFT does NOT pad s to even length. Each column of s represents one audio channel.
%
% INPUT:
% s: signal samples (vector containing the real-valued samples)
% t: time values of the signal samples (vector, with evenly spaced values) or sample rate (scalar)
%
% OUTPUT:
% S: complex fourier spectrum of s ('positive' half, see also DESCRIPTION).
% f: frequency values (vector)
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
% Copyright (C) 2006,2007, 2008 Matthias S. Brennwald.
% Contact: info@audioroot.net
% Further information: http://www.audioroot.net/MATAA

if ~any (size (s) == 1)
    error ('mataa_realFT0: the input signal s must be of dimension 1xN or Nx1 !')
end

if isscalar(t) % sample rate given instead of time values
	t = [0:1/t:(length(s)-1)/t];
end

s=s(:); t=t(:);

L = length(t);

% calculate fourier transform(s)
S = fft(s); % matlab checks for real or complex input signals, so we don not need to do it on our own to save CPU-time

% determine N (number of positive frequencies, including f=0):
if mod(L,2) % L is odd
    N = (L-1)/2+1;
else % L is even
    N = L/2+1;
end

% Discard negative half of spectrum:
S = S(1:N);

% Normalize S:
%%%% S    = S / (L/2);
S(1) = S(1)/2;  % normalize DC component, which reflects the sum of both halves of the spectrum (the two halfes overlap)
if ~mod(L,2)
    S(N) = S(N) / 2;  % for L even, last value reflects sum of both halfs of spectrum
end

% construct frequency vecor:
f = mataa_t_to_f0(t);
