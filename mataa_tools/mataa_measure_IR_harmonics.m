function [h, t, tN, unit] = mataa_measure_IR_harmonics (P, T, fs, N, attenuation, latency, cal)

% function [h, t, tN, unit] = mataa_measure_IR_harmonics (P, T, fs, N, attenuation, latency, cal)
%
% DESCRIPTION:
% Generates an exponential sine sweep containing an integer number of octaves down from the Nyquist frequency and lasting approximately T seconds, then measures the response signal and applies the inverse filter to it, thus obtaining the impulse response h.
% All impulse responses of a non-linear system are phase-synchronized, and the magnitude spectrum ripple in the high-frequency extreme is minimized due to the sweep beginning and ending in phase zero.
% A Hanning fade-in is applied for the first octave, so the flat spectrum is (P - 1) octaves long. Similarly, a Hanning fade-out is applied to the last 1/24 octave to reduce the ripple even more.
% The REF input is not used.
% REFERENCES:
% A. Farina, “Simultaneous Measurement of Impulse Response and Distortion with a Swept-Sine Technique”, presented at 108th AES Convention, Paris, France, Feb. 19-22, 2000. Paper 5093.
% 
% K. Vetter, S. di Rosario: "ExpoChirpToolbox: a Pure Data implementation of ESS impulse response measurement", Rotterdam/London, July 2011. Available at http://www.uni-weimar.de/medien/wiki/PDCON:Conference/Pure_Data_implementation_of_an_ESS-based_impulse_response_acoustic_measurement_tool. ExpoChirpToolbox page: http://www.katjaas.nl/expochirp/expochirp.html.
%
% NOTE:
% This code was contributed by estearg (github) on 24.12.2017 and modified to better suit the MATAA way of code.
%
% INPUT:
% P: integer number of octaves, of which the first will be spent on a fade-in window
% T: desired sweep duration
% fs: sampling frequency
% N: see tN (OUTPUT) below
% attenuation: attenuation factor (0...1) for output signal, such that max(abs(signal)) = attenuation. (optional, default: attenuation = 1);
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
% > P = 8; T=10; fs= 44100; att = 0.5; % measurement paramters
% > [h,t,tN] = mataa_measure_IR_harmonics (P,T,fs,N,att); % perform measurement
% > k = round(length(h)*0.45); t0 = mataa_guess_IR_start(h(k:end),t(k:end)); t = t-t0; % set linear response to t = 0
% > figure(1);semilogy (t,abs(h)); grid on; % plot the IR data
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

warning ('mataa_measure_IR_harmonics: this function is under development and needs more testing. Please use with care!')

if (P - fix(P)) ~= 0
  error('mataa_measure_IR_harmonics: P must be an integer');
end
if P <= 0
  error('mataa_measure_IR_harmonics: P must be larger than 0');
end


if ~exist('attenuation','var')
	attenuation = 1; % use default value (no attenuation)
end
if attenuation > 1
	warning('mataa_measure_IR_harmonics: attenuation factor cannot be larger than 1. Adjusted attenuation to 1.')
elseif attenuation < 0
	warning('mataa_measure_IR_harmonics: attenuation factor cannot be less than 0. Adjusted attenuation to 0 (silence).')
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

% ESS generation
x = sin(2 .* pi .* M .* exp(n .* log(2 ^ P) ./ Ns));
% 1 octave fade-in
fadeinlen = floor(Ns / P);
window = hanning(2 * fadeinlen);
window = window(1:fadeinlen);
window = postpad(window, length(x), 1);
x = x .* window;
% 1/24 octave fade-out
fadeoutlen = floor(Ns / (24 * P));
window = hanning(2 * fadeoutlen);
window = window((fadeoutlen + 1):end);
window = prepad(window, length(x), 1);
x = x .* window;
% Inverse filter
invfilter = flipud(x) .* ((2 ^ (P / Ns)) .^ (-n)) .* (P * log(2)) ./ (1 - (2 ^ (-P)));

if attenuation < 1
	x = x * attenuation;
end

% Impulse response
if ~exist ('latency','var')
  latency = [];
end
if ~exist ('cal','var')
  cal = [];
end
[responseSignal, inputSignal, t, unit] = mataa_measure_signal_response(x,...
      fs, latency, 1, mataa_settings ('channel_DUT'), cal);
h = fftconv(responseSignal, invfilter);
h = (2 / length(responseSignal)) .* h;
h = shift(h, -floor(length(responseSignal) / 2) + 1);
h = resize(h, length(responseSignal), 1);

tN = 0;
if N > 1
	tN = [ tN , round(fs * T) .* log([2:N]) ./ (fs * log(2 ^ P)) ];
end
