function [h, t, tN, unit] = mataa_measure_IR_HD (P, T, fs, N, att, latency, cal)

% function [h, t, tN, unit] = mataa_measure_IR_HD (P, T, fs, N, att, latency, cal)
%
% DESCRIPTION:
% Measures the impulse response and the harmonic distortion products using the "Farina method". This uses an exponential sine sweep (chirp) as a test signal. The sweep of length T contains an integer number of octaves down from the Nyquist frequency. The impulse responses of the fundamental and harmonic distorion products are determined by convolving the DUT response with the inverse filter corresponding to the chirp signal. The magnitude spectrum ripple in the high-frequency extreme is minimized due to the sweep beginning and ending in phase zero. A Hanning fade-in is applied for the first octave, so the flat spectrum is (P - 1) octaves long. Similarly, a Hanning fade-out is applied to the last 1/24 octave to reduce the ripple even more.
% The REF input channel is not used.
%
% REFERENCES:
% A. Farina, “Simultaneous Measurement of Impulse Response and Distortion with a Swept-Sine Technique”, presented at 108th AES Convention, Paris, France, Feb. 19-22, 2000. Paper 5093. 
% Ian H. Chan: "Swept Sine Chirps for Measuring Impulse Response", Technical Note, Stanford Research Systems, Inc, 2010. Available at http://www.thinksrs.com/downloads/PDFs/ApplicationNotes/SR1_SweptSine.pdf
% K. Vetter, S. di Rosario: "ExpoChirpToolbox: a Pure Data implementation of ESS impulse response measurement", Rotterdam/London, July 2011. Available at http://www.uni-weimar.de/medien/wiki/PDCON:Conference/Pure_Data_implementation_of_an_ESS-based_impulse_response_acoustic_measurement_tool. ExpoChirpToolbox page: http://www.katjaas.nl/expochirp/expochirp.html.
%
% NOTE:
% This code was contributed by estearg (github) on 24.12.2017+30.12.2017 and modified to better suit the MATAA way of code.
%
% INPUT:
% P: integer number of octaves, of which the first will be spent on a fade-in window
% T: desired sweep duration
% fs: sampling frequency
% N: see tN (OUTPUT) below
% att (optional): attenuation factor (0...1) for output signal, such that max(abs(signal)) = att. (default: att = 1);
% latency (optional): see mataa_measure_signal_response
% cal (optional): see mataa_measure_signal_response
% 
% OUTPUT:
% h: impulse response
% t: time
% tN: time shift of the k-th impulse responses relative to the linear response (k = 1...N).
% unit: unit of data in h
%
% EXAMPLE:
% > % Measure DUT response using chirp test signal:
% > P = 8; T=10; fs = 44100; N = 3; att = 0.5; % measurement parameters
% > [h,t,tN] = mataa_measure_IR_HD (P,T,fs,N,att); % perform measurement
% > % Determine start of main (fundamental) impulse response and plot the impulse response data:
% > k = round(length(h)*0.45); t0 = mataa_guess_IR_start(h(k:end),t(k:end)); t = t-t0; % set linear response to t = 0
% > figure(1);semilogy (t,abs(h)); axis([t(1) t(end) 1E-7 2]); grid on; % plot the IR data
% > % separate the fundamental and harmonics, convert to frequency domain, and plot result:
% > [h1,t1] = mataa_signal_crop(h,t,0,t(end)); % extract the linear response
% > [h2,t2] = mataa_signal_crop(h,t,-tN(2),-tN(1)-0.2*(tN(2)-tN(1))); % extract the second order response
% > [h3,t3] = mataa_signal_crop(h,t,-tN(3),-tN(2)-0.2*(tN(3)-tN(2))); % extract the third order response
% > [m1, p1, f1] = mataa_IR_to_FR (h1, fs, 1/8); % get the linear frequency response
% > [m2, p2, f2] = mataa_IR_to_FR (h2, fs, 1/8); % get the second order frequency response
% > [m3, p3, f3] = mataa_IR_to_FR (h3, fs, 1/8); % get the third order frequency response
% > figure(2); semilogx (f1, m1, ';Fundamental;' , f2, m2, ';2nd harmonic;' , f3, m3, ';3rd harmonic;'); axis([100 fs/2])% plot the linear and second order response
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
% Copyright (C) 2017 Matthias S. Brennwald.
% Contact: info@audioroot.net
% Further information: http://www.audioroot.net/MATAA

warning ('mataa_measure_IR_HD: this function is under development and needs more testing. Please use with care!')

if (P - fix(P)) ~= 0
  error('mataa_measure_IR_HD: P must be an integer');
end
if P <= 1
  error('mataa_measure_IR_HD: P must be greater than 1 (first octave is used for fade in of test signal)');
end

if ~exist('att','var')
	att = 1; % use default value (no att)
end
if att > 1
	warning('mataa_measure_IR_HD: att factor cannot be larger than 1. Adjusted att to 1.')
elseif att < 0
	warning('mataa_measure_IR_HD: att factor cannot be less than 0. Adjusted att to 0 (silence).')
end


% Sweep Parameters
Ns = round(fs * T);
n = [0:Ns]';
M = round(Ns / (log(2 ^ P) * (2 ^ (P + 1))));

% disp('Note that if later mataa_IR_to_FR is called, it adds 112 dB to the magnitude');
disp (['Start frequency (excl. window): ' , num2str(2 * fs * M * log(2 ^ P) / Ns) , ' Hz']);
disp (['End frequency (excl. window): ' , num2str(fs * (2 ^ (P - 1/24)) * M * log(2 ^ P) / Ns) , ' Hz']);
if N > 1
	for i = 2:N
		disp (['Order ' , num2str(i) , ' IR begins ' , num2str(Ns * log(i) / (fs * log(2 ^ P))) , ' s before the linear IR']);
	end
end

% sweep generation:
x = sin(2 .* pi .* M .* exp(n .* log(2 ^ P) ./ Ns));

% 1 octave fade-in
fadeinlen = floor(Ns / P);
% window = hanning(2 * fadeinlen);
% window = window(1:fadeinlen);
window = flipud (mataa_signal_window (repmat(1,fadeinlen,1),'hann_half'));
window = postpad(window, length(x), 1);
x = x .* window;

% 1/24 octave fade-out
fadeoutlen = floor(Ns / (24 * P));
% window = hanning(2 * fadeoutlen);
% window = window((fadeoutlen + 1):end);
window = mataa_signal_window (repmat(1,fadeoutlen,1),'hann_half');
window = prepad(window, length(x), 1);
x = x .* window;

% Inverse filter
invfilter = flipud(x) .* ((2 ^ (P / Ns)) .^ (-n)) .* (P * log(2)) ./ (1 - (2 ^ (-P)));

if att < 1
	x = x * att;
end

% Measure sweep response:
if ~exist ('latency','var')
  latency = [];
end
if ~exist ('cal','var')
  cal = [];
end
[responseSignal, inputSignal, t, unit] = mataa_measure_signal_response(x, fs, latency, 1, mataa_settings('channel_DUT'), cal);

% Convolve the response with the inverse filter to get the IR and the harmonics:
resplen = length(responseSignal);
filtlen = length(invfilter);
convlen = resplen + filtlen - 1;
responseSignalext = [responseSignal; zeros(convlen - resplen, 1)]; % extend with zeros to the length of the convolution
invfilterext = [invfilter; zeros(convlen - filtlen, 1)]; % extend with zeros to the length of the convolution
h = ifft(fft(responseSignalext) .* fft(invfilterext)); % convolve using the FFT
h = real(h); % discard imaginary part
h = (2 / resplen) * h; % scale the amplitude
t = [0:(convlen - 1)]' ./ fs;

% warning ('REPLACE THE FFTCONV CALL TO MATAA-CONV)
% h = fftconv(responseSignal, invfilter);
% h = (2 / length(responseSignal)) * h;
% h = shift(h, -floor(length(responseSignal) / 2) + 1);
% h = resize(h, length(responseSignal), 1);

% Time shifts of harmonics:
tN = 0;
if N > 1
	tN = [ tN , round(fs * T) .* log([2:N]) ./ (fs * log(2 ^ P)) ];
end
