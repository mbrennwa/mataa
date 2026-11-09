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

% A sine instead of an impulse has no onset, so the Farina time is used.
h3 = h;
t_lo = -0.5 * (tN(2) + tN(3));
t_hi = -0.5 * tN(2);
i_sine = (t >= t_lo) & (t <= t_hi);
h3(i_sine) = 0.05 * sin(2*pi*1000*t(i_sine));
weak = mataa_IR_HD_extract(h3, t, tN, tL);
__check(~weak(2).onset_found, 'a sine was accepted as harmonic 2');
__check(abs(weak(2).t_start - (-tN(2))) < 1e-12, 'harmonic 2 did not fall back to the Farina time');
__check(weak(1).onset_found && weak(3).onset_found, 'the other harmonics lost their onsets');

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
