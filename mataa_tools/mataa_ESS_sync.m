function [h, t] = mataa_ESS_sync(P, T, fs, latency, cal)

% function [h, t] = mataa_ESS_sync(P, T, fs, latency, cal)
%
% DESCRIPTION:
% Generates an exponential sine sweep containing an integer number of octaves down from the Nyquist frequency and lasting approximately T seconds, then measures the response signal and applies the inverse filter to it, thus obtaining the impulse response h.
% All impulse responses of a non-linear system are phase-synchronized, and the magnitude spectrum ripple in the high-frequency extreme is minimized due to the sweep beginning and ending in phase zero.
% A Hanning fade-in is applied for the first octave, so the flat spectrum is (P - 1) octaves long. Similarly, the last 1/24 octave is faded out with a Hanning window to reduce the ripple even more.
% The REF input is not used.
% REFERENCE:
% K. Vetter, S. di Rosario: "ExpoChirpToolbox: a Pure Data implementation of ESS impulse response measurement", Rotterdam/London, July 2011. Available at http://www.uni-weimar.de/medien/wiki/PDCON:Conference/Pure_Data_implementation_of_an_ESS-based_impulse_response_acoustic_measurement_tool. ExpoChirpToolbox page: http://www.katjaas.nl/expochirp/expochirp.html.
%
% INPUT:
% P: integer number of octaves, of which the first will be spent on a fade-in window
% T: desired sweep duration
% fs: sampling frequency
% latency (optional): see mataa_measure_signal_response
% cal (optional): see mataa_measure_signal_response
% 
% OUTPUT:
% h: impulse response
% t: time
%
% EXAMPLE:
%
% > P = 8;																										% number of octaves down from Nyquist, plus 1 for fade-in
% > T = 10;																										% approximate duration of swepp
% > fs = 96000;																									% sampling frequency
% > mataa_ESS_sync(P, T, fs, 0.22);																				% perform an ESS with 0.22 s latency
% > mataa_plot_IR(h, t);																						% plot the IR
% > set(findall(gcf, 'type', 'axes'), 'xgrid', 'on', 'xminorgrid', 'on', 'ygrid', 'on', 'yminorgrid', 'on');	% make it easier to see the coordinates of a part of the response
% > t0 = mataa_guess_IR_start(h, fs);																			% find the beginning of the linear response
% > xlim([t0 t0+0.01]);																							% focus on the first 10 ms of the linear response
% > tfirstecho = 5.0511-t0;																						% time of first reflexion, as seen in the plot, relative to beginning of response
% > tharm = round(fs * T) .* log([2:5]) ./ (fs * log(2 ^ P));													% beginning of higher order responses (up to order 5) relative to beginning of linear response
% > tharm2 = t0-tharm(1);																						% beginning of second order response
% > xlim([tharm2 tharm2+tfirstecho]);																			% focus on the part of the plot corresponding to the second order response
% > ylim([-0.001 0.001]);																						% change scale to be able to see a small second order response
% > hc = mataa_signal_crop(h, fs, t0, t0+tfirstecho);															% extract the linear response
% > [mag, phase, f] = mataa_IR_to_FR(hc, fs);																	% get the linear frequency response
% > hc2 = mataa_signal_crop(h, fs, tharm2, tharm2+tfirstecho);													% extract the second order response
% > [mag2, phase2, f2] = mataa_IR_to_FR(hc2, fs);																% get the second order frequency response
% > semilogx(f, mag, ';Fundamental;');																			% plot the linear frequency response magnitude
% > hold on;																									% let other curve be on the same plot
% > semilogx(f2, mag2, ';2nd harmonic;');																		% plot the second order frequency response magnitude
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

if (P - fix(P)) ~= 0
  error("P is not an integer\n");
endif
if P <= 0
  error("P is not greater than 0\n");
endif

# Sweep Parameters
N = round(fs * T);
n = [0:N]';
M = round(N / (log(2 ^ P) * (2 ^ (P + 1))));

disp("Note that if later mataa_IR_to_FR is called, it adds 112 dB to the magnitude");
puts(["Start frequency (excl. window): " num2str(2 * fs * M * log(2 ^ P) / N) " Hz\n"]);
puts(["End frequency (excl. window): " num2str(fs * (2 ^ (P - 1/24)) * M * log(2 ^ P) / N) " Hz\n"]);
for i = 2:5
  puts(["Order " num2str(i) " IR begins " num2str(N * log(i) / (fs * log(2 ^ P))) " s before the linear IR\n"]);
endfor

# ESS generation
x = sin(2 .* pi .* M .* exp(n .* log(2 ^ P) ./ N));
# 1 octave fade-in
fadeinlen = floor(N / P);
window = hanning(2 * fadeinlen);
window = window(1:fadeinlen);
window = postpad(window, length(x), 1);
x = x .* window;
# 1/24 octave fade-out
fadeoutlen = floor(N / (24 * P));
window = hanning(2 * fadeoutlen);
window = window((fadeoutlen + 1):end);
window = prepad(window, length(x), 1);
x = x .* window;
# Inverse filter
invfilter = flipud(x) .* ((2 ^ (P / N)) .^ (-n)) .* (P * log(2)) ./ (1 - (2 ^ (-P)));
# Impulse response
if ~exist ('latency','var')
  latency = [];
endif
if ~exist ('cal','var')
  cal = [];
endif
[responseSignal, inputSignal, t, unit] = mataa_measure_signal_response(x,...
      fs, latency, 1, mataa_settings ('channel_DUT'), cal);
h = fftconv(responseSignal, invfilter);
h = (2 / length(responseSignal)) .* h;
h = shift(h, -floor(length(responseSignal) / 2) + 1);
h = resize(h, length(responseSignal), 1);

endfunction
