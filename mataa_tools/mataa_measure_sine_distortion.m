function [L,f,fi] = mataa_measure_sine_distortion (fi,T,fs,latency,attenuation);

% function [L,f,fi] = mataa_measure_sine_distortion (fi,T,fs,latency,attenuation);
%
% DESCRIPTION:
% Play sine signals with frequencies fi and return the (normalised) spectrum of the resutling signal in the DUT channel (e.g., measure harmonic distortion spectrum, or intermodulation distortion spectrum).
% 
% INPUT:
% fi: base frequency in Hz (if fi is a scalar), or frequency values of simultaneous sine signals (if fi is a vector).
% T: length of sine signal in seconds.
% fs: sampling frequency in Hz
% latency: see mataa_measure_signal_response (optional, default: latency = [])
% attenuation: attenuation factor (0...1) for output signal (optional, default: attenuation = 1);
% 
% OUTPUT:
% L: spectrum, level of DUT output signal at frequency values f. L is normalized to 1 at fi (if fi conains more than one frequency value, L is normalized to the mean level at these frequencies).
% f: frequency values of spectrum.
% fi: frequency value(s) of fundamental(s) (they may have been adjusted to align with the frequency resolution of the spectrum to avoid frequency leakage)
%
% EXAMPLE-1 (distortion spectrum from 1000 Hz fundamental):
% > [L,f,fi] = mataa_measure_sine_distortion (1000,1,44100,0.1);
% > loglog (f,L); xlabel ('Frequency (Hz)'); ylabel ('Amplitude (rel. to fundamental)'); % plot result
%
% EXAMPLE-2 (IM distortion spectrum from 19000 // 20000 Hz fundamentals):
% > [L,f,fi] = mataa_measure_sine_distortion ([19000 20000],3,192000);
% > semilogx (f,20*log10(L)); xlabel ('Frequency (Hz)'); ylabel ('Level (dB, rel.)'); % plot result
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
% Copyright (C) 2016 Matthias S. Brennwald.
% Contact: info@audioroot.net
% Further information: http://www.audioroot.net/MATAA

fi = unique (fi);

dt = 1/fs;
n = round(T/dt);
t = [0:n-1]*dt; t = t(:);

f = mataa_t_to_f(t); df = f(1);

if ~exist('latency','var')
	latency = []; % use default value (best guess)
end
if ~exist('attenuation','var')
	attenuation = 1; % use default value (no attenuation)
end
if attenuation > 1
	warning('mataa_measure_HD: attenuation factor cannot be larger than 1. Adjusted attenuation to 1.')
elseif attenuation < 0
	warning('mataa_measure_HD: attenuation factor cannot be less than 0. Adjusted attenuation to 0 (silence).')
end

for i = 1:length(fi)
	[v,k] = min(abs(f-fi(i)));
	if f(k)~=fi(i)
	    % warning(sprintf('mataa_measure_HD: adjusted fi(%i) = %g Hz to nearest value resolved (fi(%i) = %g Hz).',i,fi(i),i,f(k)));
	    % fi(i) = f(k);
		disp(sprintf('mataa_measure_HD: note that fi(%i) = %g Hz is between FFT frequenicies (nearest FFT frequency would be fi(%i) = %g Hz).',i,fi(i),i,f(k)));
	end	
	x = mataa_signal_generator ('sine',fs,T,fi(i));
	if i == 1
		s = x;
	else
		s = s + x;
	end
end
s = s / max(abs(s));

% apply attenuation factor
if attenuation ~= 1
	s = s * attenuation;
end

% do sound I/O:
[y,in,t] = mataa_measure_signal_response(s,fs,latency,1,mataa_settings('channel_DUT'),'FLAT_SOUNDCARD.txt');

% plot (t,y)

% remove the zero padding and make the remaining signal length equal to length(t):
i = find(abs(y) > 0.5*max(abs(y)));
i1=min(i); i2=max(i);
i1=round((i1+i2)/2 - T*fs/2);
if i1 < 1
	i1 = 1;
end
i2=i1+T*fs-1;
if i2 > length(y)
	i2 = length (y);
	i1 = i2 - (T*fs-1);
end
y = y(i1:i2);
t = [0:length(y)-1]/fs;

% window the signal to minimize frequency leakage
w = sin(pi*t/max(t)).^2;
y = y(:) .* w(:) ;

if length(y) < n % pad zeros to maintain frequency resolution
	y = [ y ; repmat(0,n-length(y),1) ];
end

% plot (t,y)

% pre-normalize signal by its RMS value
L0 = sqrt (sum(y.^2)) / length (y);
y = y / L0;

% calculate signal spectrum (voltages!)
[L,f] = mataa_realFT (y,t);

% discard phase information
L = abs (L);

% normalize the spectrum to fundamental(s)
L0 = interp1 (f,L,fi,'nearest');
L = L / mean (L0);
