function hi = mataa_measure_IR_HD (P, T, fs, N, tL, latency, cal, A, unit)

% function hi = mataa_measure_IR_HD (P, T, fs, N, tL, latency, cal, A, unit)
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
% NOTEs:
% (1) The original code was contributed by estearg (github) on 24.12.2017+30.12.2017 and modified to better suit the MATAA way of code.
% (2) This code went through substantial changes and fixes (Aug 2019), because it was hard to use and gave wrong results. After substantial testing and comparison with discrete distortion testing, the distortion results now seem to be consistent with those obtained from conventional (discrete frequency) methods.
%
% INPUT:
% P: integer number of octaves, of which the first will be spent on a fade-in window
% T: desired sweep duration
% fs: sampling frequency
% N: number of harmonics included in the analysis
% tL: length of anechoic part of impulse response (seconds)
% latency (optional): see mataa_measure_signal_response
% cal (optional): see mataa_measure_signal_response
% A and unit (optional): amplitude and unit of test signal at DUT input (see mataa_measure_signal_response). Note that the 'unit' controls the amplitude of the analog signal at the DUT input. Default: amplitude = 1, unit = 'digital'
% 
% OUTPUT:
% hi: vector of structs with measured data. hi(1) corresponds to the fundamental, h(k) to the k-th harmonic, with k = 2...N.
%	hi(k).mag: magitude data
%	hi(k).phase: phase data
%	hi(k).mag_unit: unit of mag
%	hi(k).percent: percentage of harmonic amplitude relative to fundamental
%	hi(k).f: frequency values for mag, phase and percent
%	hi(k).h: impulse response data
%	hi(k).h_unit: unit of h
%	hi(k).t: time values for impulse response data
%
% EXAMPLE:
% > % Measure anechoic loudspeaker response (above 300 Hz) and harmonic distortions (2nd and 3rd) using P=8 octaves, T=3 s, fs=96 kHz, default latency, and 1 V (peak-to-zero) drive voltage:
% > h = mataa_measure_IR_HD (8,3,96000,3,1/300,[],'MB_ACOUSTIC_CHAIN_DUT.txt',1,'V');
% > figure(1);
% > semilogx (h(1).f,h(1).mag,'k-;Fundamental;' , h(2).f,h(2).mag,'b-;2nd;' , h(3).f,h(3).mag,'r-;3rd;'); % plot absolute levels
% > xlim([300 20E3]); ylabel ('dB-SPL'); xlabel ('Frequency (Hz)');
% > figure(2);
% > loglog(h(2).f,h(2).percent,'-b;2nd;' , h(3).f,h(3).percent,'r-;3rd;') % plot levels relative to fundamental
% > xlim([300 20E3]); ylabel ('HD (%)'); xlabel ('Frequency (Hz)');
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


% check input:
if (P - fix(P)) ~= 0
  error('mataa_measure_IR_HD: P must be an integer');
end
if P <= 1
  error('mataa_measure_IR_HD: P must be greater than 1 (first octave is used for fade in of test signal)');
end

if ~exist('A','var')
	A = 1; % use default value
end
if ~exist('unit','var')
	unit = 'digital';
end

if (N - fix(N)) ~= 0
  error('mataa_measure_IR_HD: N must be an integer');
end
if N <= 0
  error('mataa_measure_IR_HD: N must be greater than 0');
end

if ~exist ('latency','var')
	latency = [];
end
if ~exist ('cal','var')
	cal = [];
end

% Sweep Parameters
Ns = round(fs * T);
n = [0:Ns]';
M = round(Ns / (log(2 ^ P) * (2 ^ (P + 1))));

% Generate test signal (sweep):
x = sin(2 .* pi .* M .* exp(n .* log(2 ^ P) ./ Ns));

% 1 octave fade-in at beginning of test signal:
fadeinlen = floor(Ns / P);
window = flipud (mataa_signal_window (repmat(1,fadeinlen,1),'hann_half'));
window = postpad(window, length(x), 1);
x = x .* window;

% 1/24 octave fade-out at end of test signal:
fadeoutlen = floor(Ns / (24 * P));
window = mataa_signal_window (repmat(1,fadeoutlen,1),'hann_half');
window = prepad(window, length(x), 1);
x = x .* window;

% Measure sweep response:
[responseSignal, inputSignal, t, unit] = mataa_measure_signal_response(A*x, fs, latency, 1, mataa_settings('channel_DUT'), cal, unit);
if iscell (unit)
	unit = unit{1};
end

% Inverse filter
invfilter = flipud(x) .* ((2 ^ (P / Ns)) .^ (-n)) .* (P * log(2)) ./ (1 - (2 ^ (-P)));
L = length (responseSignal);
invfilter = [ invfilter ; zeros(L-Ns-1,1) ]; % pad x with zeros to match the true length of the test signal (zero padding for latency)

% Convolve the response with the inverse filter to get the IR and the harmonics:
h = mataa_convolve (responseSignal,invfilter);
h = real(h); % discard imaginary part
h = (2 / Ns) * h; % scale the amplitude
t = [0:length(h)-1]' ./ fs;

% Find the start of main (fundamental) impulse response:
k = round(length(h)*0.45);
t0 = mataa_guess_IR_start(h(k:end),t(k:end));
t = t-t0; % set pulse of fundamental to t = 0

% Time shifts of harmonics:
tN = 0; % fundamental is at t = 0
if N > 1
	tN = [ tN , round(fs * T) .* log([2:N]) ./ (fs * log(2 ^ P)) ];
end

% separate the fundamental and harmonics, convert to frequency domain:
hi = [];
for k = 1:N
	if k == 1
		[u.h,u.t] = mataa_signal_crop(h,t,0,tL); % extract the fundamental
	else
		L = min ( tL/k , 0.9*(tN(k)-tN(k-1)) );
		[u.h,u.t] = mataa_signal_crop(h,t,-tN(k),-tN(k)+L); % extract the k-th harmonic
	end
	u.h_unit = unit;

	[u.mag,u.phase,u.f,u.mag_unit] = mataa_IR_to_FR (u.h,u.t,[],u.h_unit); % convert to frequency domain
	u.f = u.f / k;
	kNyq = find (u.f < fs/2);
	u.mag = u.mag(kNyq);
	u.phase = u.phase(kNyq);
	u.f = u.f(kNyq);
	if k > 1
		ref = interp1 (hi(1).f,hi(1).mag,u.f);
		u.percent = 10.^((u.mag - ref)/20) * 100; % difference relative to fundamental, in percent
	else
		u.percent = repmat (100,size(u.f)); % set fundamental to 100%
	end
	hi = [ hi u ];
end
