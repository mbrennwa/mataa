function [h,t,unit] = mataa_FR_to_IR (mag,phase,f,unit_mag);

% function [h,t,unit] = mataa_FR_to_IR (mag,phase,f,unit_mag);
%
% DESCRIPTION:
% Calculate impulse response  (magnitude in dB and phase in degrees) of a system with frequency response mag(f) and phase(f).
%
% INPUT:
% mag: magnigude (in dB-SPL, dB-V, dB-FS)
% phase: phase (in deg.)
% f: time coordinates of mag and phase data (vector, in Hz)
% unit_mag (optional): unit of mag. If no unit is given, unit = 'dB-FS' is assumed.
%	Known units:
%	unit_mag = 'dB-V' (voltage)
%	unit_mag = 'dB-SPL' (sound pressure level)
%	unit_mag = 'dB-FS' (FS = digital Full Scale)
%
% OUTPUT:
% h: impulse response (in units corresponding to unit_mag, see also mataa_IR_to_FR)
% t: time (in seconds).
% unit: unit of h (see mataa_IR_to_FR)
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
% Copyright (C) Matthias S. Brennwald.
% Contact: info@audioroot.net
% Further information: http://www.audioroot.net/MATAA

if ~exist ('unit_mag','var')
	warning ("mataa_FR_to_IR: unit of input data not given. Assuming unit_mag = 'dB-FS' (FS = digital full scale ranging from -1 to +1).")
	unit_mag = 'dB-FS';
end


f = f(:); mag = mag(:); phase = phase(:);


% Check for missing DC component:
if f(1) > 0
	warning ('mataa_FR_to_IR: DC component is missing. Assuming mag = -Inf dB at DC...');
	f = [ 0 ; f ];
	mag = [ -1/eps ; mag ]; % use proper numeric value so the code below does explode
	phase = [ 0 ; phase ];
end


% check f spacing, resample if necessary:
function [mag, phase, f] = __resample(mag, phase, f, df)
	warning('mataa_FR_to_IR: irregular f grid! Resampling data to regular frequency values...');
	ff = [0:df:f(end)]';
	u = mag;
	mag = interp1 (f, mag, ff, 'extrap');
	phase = interp1 (f, phase, ff, 'extrap');
	f = ff;
endfunction
df = mean(diff(f)); % mean f step
sf = std(f); % standard deviation of f steps
if abs(df/f(2)-1) > 0.0001
	[mag, phase, f] = __resample(mag, phase, f, df);
elseif sf/df > 0.0001
	[mag, phase, f] = __resample(mag, phase, f, df);
end


% convert phase from degrees to radians (can be wrapped or unwrapped, does not matter):
phase = unwrap(phase/180*pi);


% convert mag from dB(RMS) to natural scale:
mag = 10.^(mag/20); 


% determing RMS reference level of mag, depending on unit_mag:
switch unit_mag
	case 'dB-SPL'
		% convert to Pa(rms):
		mag_ref = 20E-6; % reference sound pressure level (RMS)
		unit = 'Pa';

	case 'dB-V'
		% convert to V(rms):
		mag_ref = 1.0; % reference voltage (RMS)
		unit  = 'V';

	case 'dB-FS'
		% convert to FS(rms):
		mag_ref = sqrt(0.5); % reference = sine wave with full amplitude in FS range, RMS level = sqrt(1/2) x FULL-AMPLITUDE
		unit  = 'FS';
		
	otherwise
		warning (sprintf("mataa_FR_to_IR: unknown unit '%s', mag reference level is undefined!",unit_mag))
		mag_ref = 1.0; % do not change RMS level
		unit = '???';
end

% apply unit conversion using referece level:
mag = mag_ref * mag; % [mag] = unit


% complex spectrum (positive half, including f=0 / DC):
H = mag .* exp(-i*phase);


% convert S(f) from frequency domain to time domain h(t):
[h,t] = mataa_realIFT0 (H,f);
h = flipud(h(:));

endfunction
