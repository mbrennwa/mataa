function [L,f,fi,L0,unit] = mataa_measure_sine_distortion (fi,T,fs,latency,cal,amplitude,unit,window,N_avg);

% function [L,f,fi,L0,unit] = mataa_measure_sine_distortion (fi,T,fs,latency,cal,amplitude,unit,window,N_avg);
%
% DESCRIPTION:
% Play sine signals with frequencies fi and return the spectrum of the resulting signal in the DUT channel (e.g., measure harmonic distortion spectrum, or intermodulation distortion spectrum).
% 
% INPUT:
% fi: base frequency in Hz (if fi is a scalar), or frequency values of simultaneous sine signals (if fi is a vector).
% T: length of sine signal in seconds.
% fs: sampling frequency in Hz
% latency (optional): see mataa_measure_signal_response (default: latency = [])
% cal (optional): calibration data for data calibration (see mataa_signal_calibrate for details).
% amplitude and unit (optional): amplitude and unit of test signal at DUT input (see mataa_measure_signal_response). Note that the 'unit' controls the amplitude of the analog signal at the DUT input. Default: amplitude = 1, unit = 'digital'
% window (optional): window function to be applied to the DUT response before calculating the spectrum (default: window = 'none'). See also mataa_signal_window(...). If the window function requires additional parameter, then window can be given as a struct with three fields corresponding to the mataa_signal_window(...) arguments as follows:
%	window.name = 'window' input argument of mataa_signal_window(...)
%	window.par  = 'par' input argument of mataa_signal_window(...)
% 	window.len  = 'len' input argument of mataa_signal_window(...) 
% N_avg (optional): number of averages (integer, default: N_avg = 1). If N_avg > 1, the measurement is repeated N_avg times, and the mean result is returned. This is useful to reduce the noise floor.
%
% OUTPUT:
% L: spectrum, level of DUT output signal at frequency values f.
% f: frequency values of spectrum (Hz).
% fi: frequency value(s) of fundamental(s)they may have been adjusted to align with the frequency resolution of the spectrum to avoid frequency leakage)
% L0: signal level of fundamental(s) (useful for normalising plots)
% unit: unit of data in L and L0.
%
% EXAMPLE-1 (distortion spectrum from 1000 Hz fundamental, with 1.0 V-pk amplitude test signal):
% > [L,f,fi,L0,unit] = mataa_measure_sine_distortion (1000,1,44100,0.2,'GENERIC_CHAIN_DIRECT.txt',1.0,'V','flattop'); % perform measurement with 1V-pk test signal
% > loglog (f,L); xlabel ('Frequency (Hz)'); ylabel(sprintf('Amplitude (%s)',unit)); % plot result
%
% EXAMPLE-2 (IM distortion spectrum from 10000 // 11000 Hz fundamentals):
% > [L,f,fi,L0] = mataa_measure_sine_distortion ([10000 11000],10,44100,0.2); % perform measurement
% > loglog (f,L/L0*100); xlabel('Frequency (Hz)'); ylabel('Amplitude rel. fundamentals (%)'); % plot result
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
if ~exist('cal','var')
    cal=[];
end
if ~exist('amplitude','var')
	amplitude = 1; % use default value
end
if ~exist('unit','var')
	unit = 'digital';
end
if ~exist('window','var')
	window = 'none';
end
if ~exist ('N_avg','var')
	N_avg = 1;
end

for i = 1:length(fi)
	[v,k] = min(abs(f-fi(i)));
	if v > 1E-10
	    disp(sprintf('mataa_measure_sine_distortion: note that fi(%i) = %.3f Hz is between FFT frequenicies (nearest FFT frequency would be fi(%i) = %.3f Hz).',i,fi(i),i,f(k)));
	    % warning(sprintf('mataa_measure_sine_distortion: adjusted fi(%i) = %g Hz to nearest value resolved (fi(%i) = %g Hz).',i,fi(i),i,f(k)));
	    % fi(i) = f(k);
	end	
	x = mataa_signal_generator ('sine',fs,T,fi(i));
	if i == 1
		s = x;
	else
		s = s + x;
	end
end
s = s / max(abs(s));

s = s * amplitude;

L = [];

for k = 1:N_avg
	% do sound I/O:
	[y,in,t,unit] = mataa_measure_signal_response(s,fs,latency,1,mataa_settings('channel_DUT'),cal,unit);
	
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
	if isstruct (window)
		y = mataa_signal_window (y,window.name,window.par,window.len);
	else
		y = mataa_signal_window (y,window);
	end
	
	if length(y) < n % pad zeros to maintain frequency resolution
		y = [ y ; repmat(0,n-length(y),1) ];
	end
	
	% calculate signal spectrum (voltages!)
	[LL,f] = mataa_realFT (y,t);
	
	% discard phase information
	LL = abs (LL);
	
	% normalize L to length of spectrum:
	LL = LL / length(LL)*2;
		
	if k == 1
		L  = LL/N_avg;
	else
		L  = L + LL/N_avg;
	end
	
end

% find signal level of fundamental(s)
L0 = interp1 (f,L,fi,'nearest');
L0 = mean (L0);
