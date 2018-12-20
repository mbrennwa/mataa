function [mag,phase] = mataa_impedance_speaker_model_WRIGHT (f,Rdc,f0,Qe,Qm,Kr,Xr,Ki,Xi)

% function [mag,phase] = mataa_impedance_speaker_model_WRIGHT (f,Rdc,f0,Qe,Qm,Kr,Xr,Ki,Xi)
%
% DESCRIPTION:
% Calculate speaker impedance (magnitude and phase) as a function of frequency f according to the "Wright model" (see "An Empirical Model for Loudspeaker Motor Impedance", J R Wright, AES Preprint, 2776 (S-2), 1989). This model essentially consists of a combination of three impedance elements connected in series (where w = 2*pi*f, w0 = 2*pi*f0):
% (a) The DC resistance of the voice coil (Rdc)
% (b) A parallel LCR circuit, reflecting the the low-frequency part of the impedance curve (resonance peak).
% (c) an empirical term that describes the impedance rise above the resonance peak: Z = Kr w^Xr + i Ki w^Xi
%
% INPUT:
% f: frequency values for which impedance will be calculatedq
% Rdc: DC resistance of the voice coil (Ohm)
% f0: resonance frequency of the speaker (Hz)
% Qe: electrical quality factor of the speaker (at resonance)
% Qm: mechanical quality factor of the speaker (at resonance)
% Kr,Xr,Ki,Xi (optional): see above
%
% OUTPUT:
% mag: magnitude of impedance (Ohm)
% phase: phase of impedance (degrees)
%
% NOTES:
%    - The ratio Qm/Qe reflects the height of the impedance peak. If Zmax is the impedance maximum (at resonance) then Zmax/Rdc = Qm/Qe+1.
%    - Qe reflects the width of the impedance peak (large Qe corresponds to a narrow peak)
%
% EXAMPLE:
% > f = logspace(1,4,1000);
% > Rdc = 6.1; f0 = 45; Qe = 0.35; Qm = 5.0;
% > Kr = 4.5E-3; Ki = 27E-3; Xr = 0.65; Xi = 0.68;
% > [mag,phase] = mataa_impedance_speaker_model_WRIGHT (f,Rdc,f0,Qe,Qm,Kr,Xr,Ki,Xi);
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
% Copyright (C) 2008 Matthias S. Brennwald.
% Contact: info@audioroot.net
% Further information: http://www.audioroot.net/MATAA

if any ([Rdc,f0,Qe,Qm] == 0)
    error ('mataa_impedance_speaker_model: Rdc, f0, Qe and Qm must not be zero!')
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
Zhigh = Kr * w.^Xr + i * Ki * w.^Xi;

% total impedance:
Z = Rdc + Zlow + Zhigh;
mag = abs (Z);
phase = angle (Z) / pi * 180;
