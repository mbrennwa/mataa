function [Vas,Cms,Mms,Sd] = mataa_speaker_TSP_addmass (fs,fsM,M,D);

% function [Vas,Cms,Mms,Sd] = mataa_speaker_TSP_addmass (fs,fsM,M,D);
%
% DESCRIPTION:
% Determine Thiele-Small parameters Vas, Cms and Mms using the "added mass method". This works by comparing the resonance frequency of the unmodified driver (fs) with the resonance frequency (fsM) obtained after adding a mass (M) to cone. Make sure the mass M is firmly attached to the cone!
%
% INPUT:
% fs: driver resonance frequency (Hz)
% fsM: resonance frequency with added mass (Hz)
% M: added mass (g)
% D: cone diameter including part of the surround, typically 1/3 to 1/2 the width of the surround (cm)
%
% OUTPUT:
% Vas: driver compliance equivalent volume (litres)
% Cms: Compliance of the driver's suspension (mm/N)
% Mms: Mass of the diaphragm/coil, including acoustic load (g)
% Sd: Projected area of the driver diaphragm (cm²)
%
% EXAMPLE (measured driver resonance at fs = 46.1 Hz, fsM = 21.9 Hz with added mass M = 166 g, cone diameter with 1/2 surround on both sides D = 25.0 cm):
% > [Vas,Cms,Mms,Sd] = mataa_speaker_TSP_addmass (46.1,21.9,166,25.0);
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
% Copyright (C) Matthias S. Brennwald.
% Contact: info@audioroot.net
% Further information: http://www.audioroot.net/MATAA

rho = 1.184;	% density of air (kg/m³)
c   = 345;	% speed of sound (m/s)

Mms = M / ( (fs/fsM)^2 - 1 );				% in grams
Cms = 1 / (2*pi*fs)^2 / (Mms/1000) * 1000;		% in s²/g = mm/N
Sd  = pi * (D/2)^2;					% in cm²
Vas = rho * c^2 * (Sd/10000)^2 * (Cms/1000) * 1000;	% in L
