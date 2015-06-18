function [h,t,unit] = mataa_measure_IR (input_signal,fs,N,latency,cal,loopback);

% function [h,t,unit] = mataa_measure_IR (input_signal,fs,N,latency,cal.loopback);
%
% DESCRIPTION:
% This function measures the impulse response h(t) of a system using sample rate fs. The sampling rate must be supported by the audio device and by the TestTone program. See also mataa_measure_signal_response. h(t) is determined from the deconvolution of the DUT's response and the original input signal.
%
% INPUT:
% input_signal: input signal, vector of signal samples or name to file with sample data. Files must be in ASCII format and contain a one-column vector of the signal samples, where +1.0 is the maximum and -1.0 is the minimum value. The file should be in the 'test_signals' path. NOTE: it can't hurt to have some zeros padded to the beginning and the end of the input_signal. This helps to avoid that the DUT's response is cut off due to the latency of the audio hardware (and possibly the 'flight time'  of the sound from a loudspeaker to a microphone).
% N (optional): the impulse response is measured N times and the mean response is calculated from these measurements. N = 1 is used by default.
% latency: see mataa_measure_signal_response
% cal (optional): calibration data (struct or string, see mataa_load_calibration and mataa_signal_calibrate)
% loopback (optional): flag to indicate if a loopback connection is used for signal calibration. If loopback = 1, the DUT signal is deconvolved from the REF signal (channel allocation: see mataa_settings). If loopback = 0, the DUT signal is not modified with the REF signal. Default value is loopback = 0.
% 
% OUTPUT:
% h: impulse response
% t: time
% unit: unit of data in h
%
% DISCLAIMER:
% This file is part of MATAA.
%
% EXAMPLES:
%
% measure impulse response using a sweep test signal (without any data calibration):
% > s = mataa_signal_generator ('sweep',44100,0.2,[50 20000]);	% create test signal (sine sweep from 50 to 20000 Hz, 0.2 s long, with 44.1 kHz sampling frequency
% > [h,t] = mataa_measure_IR (s,44100,1,0.1);					% measure impulse response using test signal s, allowing for 0.1 s latency of sound in/out
% > plot (t,h)													% plot result
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
% Copyright (C) 2006, 2007, 2008, 2015 Matthias S. Brennwald.
% Contact: info@audioroot.net
% Further information: http://www.audioroot.net/MATAA

if ~exist ('N','var')
	N=1;
end

if ~exist ('loopback','var')
	loopback = 0;
end

for i = 1:N

	% do the sound I/O	
	if exist ('cal','var')
		[out,in,t,unit] = mataa_measure_signal_response (input_signal,fs,1,latency,cal);
	else
		[out,in,t,unit] = mataa_measure_signal_response (input_signal,fs,1,latency);
	end
	
	% deconvolve in and out signals to yield h:
	if exist ('OCTAVE_VERSION','builtin')
		more ('off');
	end
	
	disp ('Deconvolving data (this may take a while)...');
	l = length (in);
	nChan = length (out(mataa_settings('channel_DUT'),:));
	in = [in; repmat(0,l,1)];
	out = detrend(out);
	out = [out; repmat(0,l,nChan)];
	
	OUT = fft(out);
	IN = fft(in);
	
	for j=1:nChan
	    H(:,j) = OUT(:,j) ./ IN;
	end
	
	keyboard
	
	if loopback = 1 % Deconvolve DUT and REF channel:
		H = H(:,mataa_settings ('channel_DUT')) ./ H(:,mataa_settings ('channel_REF'));
	elseif loopback = 0 % Don't deconvolve:
		H = H(:,mataa_settings ('channel_DUT'));
	else
		error (sprintf("mataa_measure_IR: loopback = %g not supported.",loopback));
	end
	
	dummy = ifft (H);
	% dummy = dummy (1:l,:); % the other half is redundant since the signal is real	
	dummy = dummy(1:l); % the other half is redundant since the signal is real
	
	% h (i.e. dummy) should be purely real, but numerical artefacts may generate small
	% shifts into the complex domain. Compensate for this:
	dummy = abs (dummy) .* sign (real(dummy)); % turn it back to the real-axis (complex part is much smaller than real part, so this works fine)
	disp ('...deconvolution done.');
	
%	dummy = dummy(:, mataa_settings ('channel_DUT')); % use DUT-data only
	unit = char(unit{mataa_settings ('channel_DUT')});
	
%%%% 	% DECONVOLUTION OF DUT AND REF CHANNELS:
%%%% 	
%%%% 	HH = H(:,1) ./ H(:,2);
%%%% 	dd = ifft (HH);
%%%% 	dd = dd(1:l);
%%%% 	dd = abs (dd) .* sign (real(dd));
	
	if i == 1
		h = dummy / N;
	else
		h = h + dummy / N;
	end
	h = -h; % get polarity right.
end
