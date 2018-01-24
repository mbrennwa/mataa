function [h,t,unit] = mataa_measure_IR (input_signal,fs,N,latency,loopback,cal,unit);

% function [h,t,unit] = mataa_measure_IR (input_signal,fs,N,latency,loopback,cal,unit);
%
% DESCRIPTION:
% This function measures the impulse response h(t) of a system using sample rate fs. The sampling rate must be supported by the audio device and by the TestTone program. See also mataa_measure_signal_response. h(t) is determined from the deconvolution of the DUT's response and the original input signal (if no loopback is used) or the REF channel (with loopback). The allocation of the DUT (and REF) channel is determined using mataa_settings ('channel_DUT') (and mataa_settings ('channel_REF')).
% Note that the deconvolution result is normalised to the level of signal at the DUT input / DAC(+BUFFER) output. In order to remove this normalisation of the impulse response (h), the function multiplies the deconvolution result by the RMS signal level of the signal at the DUT input (if the DUT input signal level is available from the calibraton process).
%
% INPUT:
% input_signal: input signal, vector of signal samples or name to file with sample data. Files must be in ASCII format and contain a one-column vector of the signal samples, where +1.0 is the maximum and -1.0 is the minimum value. The file should be in the 'test_signals' path. NOTE: it can't hurt to have some zeros padded to the beginning and the end of the input_signal. This helps to avoid that the DUT's response is cut off due to the latency of the audio hardware (and possibly the 'flight time'  of the sound from a loudspeaker to a microphone).
% N (optional): the impulse response is measured N times and the mean response is calculated from these measurements. N = 1 is used by default.
% latency: see mataa_measure_signal_response
% loopback (optional): flag to control the behaviour of deconvolution of the DUT and REF channels. If loopback = 0, the DUT signal is not deconvolved from the REF signal (no loopback calibration). Otherwise, the DUT signal is deconvolved from the REF channel. The allocation of the DUT and REF channels is taken from mataa_settings('channel_DUT') and mataa_settings('channel_REF'). Default value (if not specified) is loopback = 0.
% cal (optional): calibration data (struct or (cell-)string, see mataa_load_calibration and mataa_signal_calibrate)
% unit (optional): unit of input_signal (see mataa_measure_signal_response). Note that this controls the amplitude of the analog signal at the DUT input.
%
% OUTPUT:
% h: impulse response
% t: time
% unit: unit of data in h
%
% EXAMPLE:
%
% Measure impulse response of a loudspeaker using a sweep test signal (without any data calibration):
% > % measure impulse response using chirp test signal, allowing for 0.1 s latency of sound in/out
% > fs = 44100; s = mataa_signal_generator ('sweep',fs,1,[50 20000]); % test signal
% > [h,t,unit] = mataa_measure_IR (s,fs,1,0.1,0,'GENERIC_CHAIN_ACOUSTIC.txt');
% > plot (t,h); xlabel ('Time (s)'); ylabel (sprintf('Amplitude (%s)',unit)); % plot result
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
% Copyright (C) 2006, 2007, 2008,2015 Matthias S. Brennwald.
% Contact: info@audioroot.net
% Further information: http://www.audioroot.net/MATAA

if ~exist ('N','var')
	N=1;
end

if ~exist ('loopback','var')
	loopback = 0;
end

if ~loopback
	channels = mataa_settings ('channel_DUT'); % use DUT channel only
else
	channels = [ mataa_settings('channel_DUT') mataa_settings('channel_REF') ]; % use DUT and REF channel
end

for i = 1:N

	% do the sound I/O	
	if exist ('cal','var')
		if exist ('unit','var')
			[out,in,t,out_unit,in_unit,X0_RMS] = mataa_measure_signal_response (input_signal,fs,latency,1,channels,cal,unit);
		else
			[out,in,t,out_unit,in_unit,X0_RMS] = mataa_measure_signal_response (input_signal,fs,latency,1,channels,cal);
		end
	else
		[out,in,t,out_unit,in_unit,X0_RMS] = mataa_measure_signal_response (input_signal,fs,latency,1,channels);
	end
	
	% deconvolve in and out signals to yield h:
	if exist ('OCTAVE_VERSION','builtin')
		more ('off');
	end
		
	l = length (in);
	uu = flipud ([1:l]'/l);
	
	if ~loopback % no loopback calibration
		disp ('Deconvolving data using raw test signal as reference (no loopback data available)...')
		dut = out(:,1); dut_unit = out_unit;
		ref = in; 	ref_unit = in_unit;
		
	else % use loopback / REF data
		disp ('Deconvolving data using loopback signal as reference...')
		dut = out(:,1); dut_unit = out_unit{1};
		ref = out(:,2);	ref_unit = out_unit{2};
		warning ("mataa_measure_IR: DUT/REF deconvolution needs proper testing! Be careful with results...")
		
	end

	dut = [ dut ; uu*dut(end) ];	
	ref = [ ref ; uu*ref(end) ];		
	H = fft(dut) ./ fft(ref) ; % normalize by 'ref' signal

	dummy = ifft (H);	
	dummy = dummy(1:l); % the other half is redundant since the signal is real
	dummy = abs (dummy) .* sign (real(dummy)); % turn it back to the real-axis (complex part is much smaller than real part, so this works fine)
	
	disp ('...deconvolution done.');
	
	if i == 1
		h = dummy / N;
	else
		h = h + dummy / N;
	end
end

if isna(X0_RMS)
	warning ('mataa_measure_IR: DUT input voltage level is unknown, IR result is relative to DUT input signal level!')
	if exist ('cal','var')
		unit = sprintf ('%s/%s',dut_unit,ref_unit);
	else
		unit = '???';
	end
else
	% remove normalisation to amplitude of DUT input signal due to deconvolution:
	h = h * X0_RMS;
	if exist ('cal','var')
		unit = sprintf ('%s',dut_unit);
	else
		unit = '???';
	end
end
