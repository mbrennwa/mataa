function [mag,phase,f,unit] = mataa_IR_to_FR (h,t,smooth_interval,unit);

% function [mag,phase,f,unit] = mataa_IR_to_FR (h,t,smooth_interval,unit);
%
% DESCRIPTION:
% Calculate frequency response (magnitude in dB and phase in degrees) of a system with impulse response h(t)
%
% INPUT:
% h: impulse response (in volts, Pa, FS, etc.)
% t: time coordinates of samples in h (vector, in seconds) or sampling rate of h (scalar, in Hz)
% smooth_interval (optional): if specified, the frequency response is smoothed over the octave interval smooth_interval.
% unit (optional): unit of h. If no unit is given, unit = 'FS' is assumed.
%	Known units:
%	unit = 'V' (Volt)
%	unit = 'Pa' (Pascal)
%	unit = 'FS' (digital Full Scale, values ranging from -1 to +1).
%
% OUTPUT:
% mag: magnitude of frequency response (in dB). Depending on the unit of h, mag is references to different levels:
%	- Unit of h is 'Pa' (Pascal) --> mag is referenced to 20 microPa (standard RMS reference sound pressure level).
%	- Unit of h is 'V' (Volt) --> mag is referenced to 1.0 V(RMS).
% phase: phase of frequency response (in degrees). This is the TOTAL phase including the 'excess phase' due to (possible) time delay of h(h). phase is unwrapped (i.e. it is not limited to +/-180 degrees, and there are no discontinuities at +/- 180 deg.)
% f: frequency coordinates of mag and phase
% unit: unit of mag (depends on unit given at input):
%	input unit = 'V'  ---> output unit = 'dB-V(rms)'   // a sine wave with a RMS level of 1V(rms) corresponds to 0 dB-V(rms)
%	input unit = 'Pa' ---> output unit = 'dB-SPL(rms)' // a sine wave with a RMS SPL of 2E-5Pa(rms) corresponds to 0 dB-SPL(rms)
%	input unit = 'FS' ---> output unit = 'dB-FS(rms)'  // a sine wave with a RMS level of 0.707FS (1.0FS peak amplitude) corresponds to 0 dB-FS(rms)
%
% EXAMPLE:
% > [h,t,unit_h] = mataa_IR_demo ('FE108'); % load demo IR (Fostex FE-108 speaker)
% > [mag,phase,f,unit_mag] = mataa_IR_to_FR(h,t,1/12,unit_h); % calculate magnitude(f) and phase(f), smoothed to 1/12 octave resolution
% > subplot (2,1,1); semilogx (f,mag); ylabel (sprintf('SPL (%s)',unit_mag)); % plot magnitude response
% > subplot (2,1,2); semilogx (f,phase); ylabel ('Phase (deg.)'); xlabel ('Frequency (Hz)'); % plot phase response
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

if ~exist ('unit','var')
	warning ("mataa_IR_to_FR: unit of input data not given. Assuming unit = 'FS' (digital full scale ranging from -1 to +1).")
	unit = 'FS';
end

if isscalar(t)
    t = [0:1/t:(length(h)-1)/t];
end

h = h(:); % make sure h is column vector

%%% Don't do this (just consider what happens if h(1) = 1 and h(2:end) = 0):
%%% h = h - linspace(h(1),h(end),length(h))' + mean(h); % make sure s is periodic

% if exist('smooth_interval','var')
% 	T = max(t)-min(t);
% 	fMin = 1/T;
% 	df = fMin*smooth_interval;
% 	T = 1/df;
% 	[h,t] = mataa_signal_pad_Zeros(h,t,T); % pad the impulse response to length T, so we can calculate the freqeuncy response with (faked) frequency resolution of df
% end

[p,f] = mataa_realFT(h,t);

% Determine RMS levels:
%%% - p is only half of the full (symmetric) spectrum, therefore needs to be multiplied by 2 to get the full RMS level
%%% - Each frequency bin corresponds a sine/cosine AMPLITUDE, so RMS = 0.707 x AMPLITUDE
%%% p_rms = 2 * sqrt(0.5) * abs(p); THIS GIVES 3 dB too high results!!

p_rms = abs(p); % this gives correct levels

% NOTE: above normalisation was checked to be accurate using the following test:
% - test normalisation: p_rms = abs(p);
% - measure RMS signal of a bass loudspeaker (nearfield) playing a slow sweep from 110 Hz to 140 Hz (flat respons), determine RMS level of DUT output (RMS1 = 96.29 dB-SPL)
% - Use mataa_IR_to_FR to determine SPL nearfield response from the nearfield impulse response of the same loudspeaker with no smoothing and long time-gate, determined mean SPL from 110 Hz to 140 Hz (RMS2 = 96.28 dB-SPL)
% - RMS1 and RMS2 are identical, so the above normalisation seems to be correct

switch unit
	case 'Pa'
		% convert to dB-SPL(rms):
		p_ref = 20E-6; % reference sound pressure level (RMS)
		unit = 'dB-SPL(rms)';

	case 'V'
		% convert to dB-V(rms):
		p_ref = 1.0; % reference voltage (RMS)
		unit  = 'dB-V(rms)';

	case 'FS' % digital Full Scale (values ranging from -1 to +1)
		% convert to dB-FS(rms):
		p_ref = sqrt(0.5); % reference = sine wave with full amplitude in FS range, RMS level = sqrt(1/2) x FULL-AMPLITUDE
		unit  = 'dB-FS(rms)';
		
	otherwise
		warning (sprintf("mataa_IR_to_FR: unknown unit '%s', mag reference level is undefined!",unit))
		p_ref = 1.0; % do not change RMS level
		unit = 'dB-NOREF';

end

mag = 20*log10(p_rms/p_ref); % determine magnitude levels in dB


% unwrap the phase, and convert from radians to degrees
phase = unwrap(angle(p))/pi*180;

if exist("smooth_interval","var")
	if ~isempty (smooth_interval)
		disp ('mataa_IR_to_FR: smoothing data...')
		[mag,phase,f] = mataa_FR_smooth(mag,phase,f,smooth_interval);
		disp ('mataa_IR_to_FR: ...done.')
	end
end
