function min_phase = mataa_minimum_phase (mag,f);

% function min_phase = mataa_minimum_phase (mag,f);
%
% DESCRIPTION:
% Calculates minimum phase from magnitude frequency response using the Hilbert transform (see http://en.wikipedia.org/wiki/Minimum_phase#Relationship_of_magnitude_response_to_phase_response).
%
%
% INPUT:
% mag: magnitude of frequency response (in dB)
% f: frequency coordinates of mag (in Hz)
%
% OUTPUT:
% min_phase: minimum phase at frequnecies f (unwrapped, in degrees)
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

%%%%    % calculate minimum phase using the Hilbert transform:
%%%%    % see: http://www.fourelectronics.com/Hilbert-transform-to-calculate-Magnitude-from-Phase-10052397.html
%%%%    % and: http://www.dsprelated.com/showmessage/29416/1.php
%%%%    % this should use the NATURAL log, and 'abs(p)' rather than '10*abs(p)'!

% convert mag from dB to natural units:
mag = mag/20;
mag = 10.^mag;

mag = log(mag);
% normalize mag to avoid dependency of min_phase on the scaling of mag
mag = mag-mean(mag);

min_phase = -mataa_hilbert(mag)/pi*180;
