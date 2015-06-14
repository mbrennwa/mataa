function [h,t,h_unit] = mataa_measure_IR (input_signal,fs,N,latency,hw_info);

% function [h,t,h_unit] = mataa_measure_IR (input_signal,fs,N,latency,hw_info);
%
% DESCRIPTION:
% This function measures the impulse response h(t) of a system using sample rate fs. The sampling rate must be supported by the audio device and by the TestTone program. See also mataa_measure_signal_response. h(t) is determined from the deconvolution of the DUT's response and the original input signal.
%
% INPUT:
% input_signal: input signal, vector of signal samples or name to file with sample data. Files must be in ASCII format and contain a one-column vector of the signal samples, where +1.0 is the maximum and -1.0 is the minimum value. The file should be in the 'test_signals' path. NOTE: it can't hurt to have some zeros padded to the beginning and the end of the input_signal. This helps to avoid that the DUT's response is cut off due to the latency of the audio hardware (and possibly the 'flight time'  of the sound from a loudspeaker to a microphone).
% N (optional): the impulse response is measured N times and the mean response is calculated from these measurements. N = 1 is used by default.
% latency: see mataa_measure_signal_response
% hw_info (optional): struct containing information relating the measurement hardware (DAC, ADC, microphone, etc.). This information is used determine the correct signal level and unit and to compensate for non-ideal frequency response of the measurement equipment. See also mataa_measure_signal_response. If hw_info is not given, the raw impulse response is measured, i.e. no compensation for the transfer functions of the test hardware is applied.
% 
% OUTPUT:
%
% h: impulse response
% t: time
% h_unit: unit of h data
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
% Further information: http://www.audioroot.net/MATAA

if ~exist ('N','var')
	N=1;
end

for i = 1:N

	% do the sound I/O	
	if exist ('hw_info','var')
		[out,in,t,h_unit] = mataa_measure_signal_response (input_signal,fs,1,latency,hw_info);
	else
		[out,in,t,h_unit] = mataa_measure_signal_response (input_signal,fs,1,latency);
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
		
	dummy = ifft (H);
	dummy = dummy (1:l,:); % the other half is redundant since the signal is real
	
	% h (i.e. dummy) should be purely real, but numerical artefacts may generate small
	% shifts into the complex domain. Compensate for this:
	dummy = abs (dummy) .* sign (real(dummy)); % turn it back to the real-axis (complex part is much smaller than real part, so this works fine)
	disp ('...deconvolution done.');
	
	dummy = dummy(:, mataa_settings ('channel_DUT')); % use DUT-data only
	
	if i == 1
		h = dummy / N;
	else
		h = h + dummy / N;
	end
	h = -h; % get polarity right.
end
