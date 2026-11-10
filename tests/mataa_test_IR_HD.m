function mataa_test_IR_HD

% function mataa_test_IR_HD
%
% DESCRIPTION:
% Checks harmonic cutting and windowing. Does not open a sound device and does not change MATAA settings.
%
% EXAMPLE:
% > addpath /path/to/mataa/tests
% > mataa_test_IR_HD
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
% Copyright (C) 2026 Matthias S. Brennwald.
% Contact: info@audioroot.net
% Further information: http://www.audioroot.net/MATAA

script_dir = fileparts(mfilename('fullpath'));
if isempty(script_dir)
	script_dir = pwd;
end
addpath(fullfile(fileparts(script_dir), 'mataa_tools'));

if exist('OCTAVE_VERSION', 'builtin')
	more('off');
end

fs = 48000;
P = 8;
T = 3;
N = 3;
tL = 1/300;
tN = round(fs * T) .* log(1:N) ./ (fs * log(2 ^ P));
[h, t] = __record(fs, tN);

pieces = mataa_IR_HD_extract(h, t, tN, tL);
__check(length(pieces) == N, 'extract did not return one piece per harmonic');

for k = 1:N
	__check(pieces(k).onset_found, sprintf('harmonic %d onset was not found', k));
	__check(pieces(k).tL_fit, sprintf('harmonic %d did not keep tL', k));
	__check(pieces(k).h(1) == 0, sprintf('harmonic %d first sample is not zero', k));
	__check(pieces(k).h(end) == 0, sprintf('harmonic %d last sample is not zero', k));

	t_abs = pieces(k).t + pieces(k).t_piece_start;
	[~, ip] = min(abs(t_abs - (-tN(k))));
	__check(abs(pieces(k).h(ip) - 1) < 1e-9, sprintf('harmonic %d peak was changed by the window', k));
	__check(abs(pieces(k).t_ref - (pieces(k).t_start - pieces(k).t_piece_start)) < 1e-12, sprintf('harmonic %d phase reference is not its beginning', k));
	__check(abs(pieces(k).t_piece_end - (pieces(k).t_start + tL)) < 1.5/fs, sprintf('harmonic %d does not end tL after its beginning', k));
end

% A reflection at the end of each piece is the last sample, and the window sets it to zero.
h_ref = h;
for k = 1:N
	[~, ir] = min(abs(t - pieces(k).t_piece_end));
	h_ref(ir) = h_ref(ir) + 0.5;
end
reflected = mataa_IR_HD_extract(h_ref, t, tN, tL);
for k = 1:N
	__check(reflected(k).h(end) == 0, sprintf('harmonic %d reflection was not removed', k));
	t_abs = reflected(k).t + reflected(k).t_piece_start;
	[~, ip] = min(abs(t_abs - (-tN(k))));
	__check(abs(reflected(k).h(ip) - 1) < 1e-9, sprintf('harmonic %d peak moved when the reflection was added', k));
end

% A gap shorter than tL ends the earlier harmonic at the next one.
gap = 0.005;
tL_close = 0.02;
tN_close = [0; gap];
t2 = ((-round(fs*(gap + 0.02))):round(fs*0.02))' / fs;
h2 = zeros(size(t2));
short = __pulse_n(8);
half = floor(length(short)/2);
for k = 1:2
	h2 = __add_at(h2, t2, -tN_close(k), short, half);
end
close_pieces = mataa_IR_HD_extract(h2, t2, tN_close, tL_close);
__check(close_pieces(1).onset_found && close_pieces(2).onset_found, 'close harmonics lost their onsets');
__check(~close_pieces(2).tL_fit, 'a harmonic closer than tL was kept for the full tL');
__check(close_pieces(2).t_piece_end <= close_pieces(1).t_piece_start + 1/fs, 'harmonic 2 runs into the fundamental');

% One harmonic replaced by a sine stays on the grid fitted to the others.
h3 = h;
t_lo = -0.5 * (tN(2) + tN(3));
t_hi = -0.5 * tN(2);
i_sine = (t >= t_lo) & (t <= t_hi);
h3(i_sine) = 0.05 * sin(2*pi*1000*t(i_sine));
weak = mataa_IR_HD_extract(h3, t, tN, tL);
__check(all([weak.onset_found]), 'one sine made the grid fit fail');
__grid(weak, tN, 'a sine');

% A record with no impulse keeps the Farina times.
none = mataa_IR_HD_extract(0.05 * sin(2*pi*1000*t), t, tN, tL);
__check(~any([none.onset_found]), 'a sine was accepted as the Farina grid');
for k = 1:N
	__check(abs(none(k).t_start - (-tN(k))) < 1e-12, sprintf('harmonic %d left the Farina time', k));
end

% The same delay on every impulse slides the whole grid by that delay.
delay = 0.001;
pulse = __pulse();
half = floor(length(pulse)/2);
h_shift = zeros(size(t));
for k = 1:N
	h_shift = __add_at(h_shift, t, -tN(k) + delay, pulse, half);
end
shifted = mataa_IR_HD_extract(h_shift, t, tN, tL);
__check(all([shifted.onset_found]), 'a delayed grid was not found');
__grid(shifted, tN, 'a delay');
for k = 1:N
	t_abs = shifted(k).t + shifted(k).t_piece_start;
	[~, ip] = min(abs(t_abs - (-tN(k) + delay)));
	__check(abs(shifted(k).h(ip) - 1) < 1e-9, sprintf('harmonic %d peak was windowed after the grid slid', k));
end

% A loud click between arrivals, and no impulse for the upper harmonics,
% must not move the grid or abort the cut. This is the geometry of a
% 192 kHz, 9-octave, 3 s sweep kept for 1/300 s.
fs5 = 192000;
P5 = 9;
T5 = 3;
N5 = 5;
tL5 = 1/300;
tN5 = round(fs5 * T5) .* log(1:N5) ./ (fs5 * log(2 ^ P5));
t5 = ((-round(fs5*(tN5(end) + 0.05))):round(fs5*0.05))' / fs5;
h5 = zeros(size(t5));
for k = 1:3
	h5 = __add_at(h5, t5, -tN5(k), pulse, half);
end
click = 2 * __pulse_n(8);
h5 = __add_at(h5, t5, -0.5*(tN5(3)+tN5(4)), click, floor(length(click)/2));
decoy = mataa_IR_HD_extract(h5, t5, tN5(:), tL5);
__check(all([decoy.onset_found]), 'a click between harmonics lost the grid');
__grid(decoy, tN5, 'a click');
for k = 1:3
	t_abs = decoy(k).t + decoy(k).t_piece_start;
	[~, ip] = min(abs(t_abs - (-tN5(k))));
	__check(abs(decoy(k).h(ip) - 1) < 1e-9, sprintf('harmonic %d peak moved toward the click', k));
end

disp('mataa_test_IR_HD: ok');

end

function [h, t] = __record(fs, tN)
N = length(tN);
t = ((-round(fs*(tN(end) + 0.05))):round(fs*0.05))' / fs;
h = zeros(size(t));
pulse = __pulse();
half = floor(length(pulse)/2);
for k = 1:N
	h = __add_at(h, t, -tN(k), pulse, half);
end
end

function h = __add_at(h, t, t_at, pulse, half)
[~, i0] = min(abs(t - t_at));
i1 = i0 - half;
i2 = i1 + length(pulse) - 1;
if i1 < 1 || i2 > length(h)
	error('mataa_test_IR_HD: pulse does not fit in the record.');
end
h(i1:i2) = h(i1:i2) + pulse;
end

function pulse = __pulse()
pulse = __pulse_n(32);
end

function pulse = __pulse_n(nlen)
n = (0:nlen-1)';
pulse = sin(pi * n / (nlen-1));
pulse = pulse / max(pulse);
end

function __check(cond, msg)
if ~cond
	error(sprintf('mataa_test_IR_HD: %s.', msg));
end
end

function __grid(pieces, tN, what)
for k = 1:length(tN)
	got = pieces(1).t_start - pieces(k).t_start;
	if abs(got - tN(k)) > 1e-12
		error(sprintf('mataa_test_IR_HD: harmonic %d left the Farina grid after %s.', k, what));
	end
end
end
