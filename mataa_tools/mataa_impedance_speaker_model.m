function [mag,phase] = mataa_impedance_speaker_model (f,Rdc,f0,Qe,Qm,L1,L2,R2)

% function [mag,phase] = mataa_impedance_speaker_model (f,Rdc,f0,Qe,Qm,L1,L2,R2)
%
% DESCRIPTION:
% Calculate speaker impedance (magnitude and phase) as a function of frequency f according to the MLSSA model (see Figure 7.16 in J. d'Appolito, "Testing Loudspeakers", Audio Amateur Press). This model essentially consists of a combination of three impedance elements connected in series (where w = 2*pi*f, w0 = 2*pi*f0):
% (a) The DC resistance of the voice coil (Rdc)
% (b) A parallel LCR circuit, reflecting the the low-frequency part of the impedance curve (resonance peak).
% (c) L1 in series with a parallel combination of R2 and L2. L1, L2, and R2 reflect the high-frequency part of the impedance curve. For L2 = 0 and R2 = Inf, this model reduces to the simpler concept where the voice-coil inductance Le is constant with frequency (and L1 = Le).
%
% INPUT:
% f: frequency values for which impedance will be calculatedq
% Rdc: DC resistance of the voice coil (Ohm)
% f0: resonance frequency of the speaker (Hz)
% Qe: electrical quality factor of the speaker (at resonance)
% Qm: mechanical quality factor of the speaker (at resonance)
% L1, L2, R2 (optional): see above (in H or Ohm, respectively)
%
% OUTPUT:
% mag: magnitude of impedance (Ohm)
% phase: phase of impedance (degrees)
%
% NOTES:
%    - The ratio Qm/Qe reflects the height of the impedance peak. If Zmax is the impedance maximum (at resonance) then Zmax/Rdc = Qm/Qe-1.
%    - Qe reflects the width of the impedance peak (at least I think so; large Qe corresponds to a narrow peak)
%
% EXAMPLE:
% The following gives a good approximation of the data shown in Fig. 7.18 in J. d'Appolito, "Testing oudspeaker" on page 122:
% [mag,phase] = mataa_impedance_speaker_model (f,7.66,33.22,0.45,3.4,0.4e-3,1.1e-3,13);
% semilogx (f,mag,f,phase)
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
% 29. January 2008 (Matthias Brennwald): added a check for non-zero values of Rdc, f0, Qe, Qm, and R2.
% 12. January 2008 (Matthias Brennwald): first version

if nargin < 8;
    R2 = Inf;
end

if nargin < 7;
    L2 = 0;
end

if nargin < 6;
    L1 = 0;
end

if nargin < 5;
    error ('mataa_impedance_speaker_model: not enough input arguments!')
end

if any ([Rdc,f0,Qe,Qm,R2] == 0)
    error ('mataa_impedance_speaker_model: Rdc, f0, Qe, Qm, and R2 must not be zero!')
end

w0 = 2*pi*f0;
w  = 2*pi*f;

% low-frequency impedance (resonance peak, LCR part):
Res = Rdc*Qm/Qe;
Ces = Qe/w0/Rdc;
Les = 1/w0^2/Ces;

ZCes = 1./(i*w*Ces);
ZLes = i*w*Les;
Zlow = 1 ./ ( 1/Res + 1./ZCes + 1./ZLes );

% high-frequency impedance:
Z1 = i*w*L1;
Z2 = 1 ./ ( 1./(i*w*L2) + 1/R2 );
Zhigh = Z1 + Z2;

% total impedance:
Z = Rdc + Zlow + Zhigh;
mag = abs (Z);
phase = arg (Z) / pi * 180;