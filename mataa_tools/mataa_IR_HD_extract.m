function pieces = mataa_IR_HD_extract (h, t, tN, tL)

% function pieces = mataa_IR_HD_extract (h, t, tN, tL)
%
% DESCRIPTION:
% Cut the fundamental and each harmonic out of an impulse response that was
% obtained with the Farina inverse filter. Harmonic k is expected at time
% -tN(k), with the fundamental at time zero. The piece ends tL after its own
% beginning, unless the next harmonic arrives sooner. A half-sine fade brings
% both ends of the piece to zero. The middle, including the beginning of the
% impulse, stays at unity gain.
%
% INPUT:
% h: impulse response, column vector
% t: time of each sample in h (seconds, column vector)
% tN: expected time of harmonic k before the fundamental. tN(1) is 0. Length N.
% tL: length kept after the beginning of each harmonic (seconds)
%
% OUTPUT:
% pieces: struct array, one element per harmonic.
%	pieces(k).h, pieces(k).t: windowed samples. t(1) is 0.
%	pieces(k).t_start: beginning of this impulse (seconds, same clock as t)
%	pieces(k).t_rise: rise time used for the fades (seconds)
%	pieces(k).t_ref: time from the first sample of the piece to t_start
%	pieces(k).onset_found: false when the Farina time was used instead
%	pieces(k).tL_fit: false when the next harmonic arrived before tL
%
% EXAMPLE:
% > dt = 1/48000; t = (0:1000)'*dt; h = zeros(size(t)); h(500) = 1;
% > p = mataa_IR_HD_extract(h, t, 0, 0.005);
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

if tL <= 0
	error('mataa_IR_HD_extract: tL must be greater than 0');
end

h = h(:);
t = t(:);
tN = tN(:);
N = length(tN);
if length(h) ~= length(t)
	error('mataa_IR_HD_extract: h and t must have the same length');
end
if N < 1
	error('mataa_IR_HD_extract: tN must contain one time per harmonic');
end

dt = mean(diff(t));
t_start = zeros(N, 1);
t_rise = zeros(N, 1);
onset_found = false(N, 1);

for k = 1:N
	[t_lo, t_hi] = hd_search_limits(t, tN, k);
	[t_start(k), t_rise(k), onset_found(k)] = hd_find_onset(h, t, -tN(k), t_lo, t_hi, dt);
end

% Earlier harmonics are placed first, so a later piece can stop at the one before it.
t_block = t(1);
pieces = cell(N, 1);
for k = N:-1:1
	u.t_start = t_start(k);
	u.t_rise = t_rise(k);
	u.onset_found = onset_found(k);

	t_ps = t_start(k) - 2*t_rise(k);
	if t_ps < t_block
		t_ps = t_block;
		warning(sprintf('mataa_IR_HD_extract: harmonic %d fade-in shortened to keep clear of the previous harmonic.', k));
	end

	t_pe = t_start(k) + tL;
	u.tL_fit = true;
	if k > 1
		t_limit = t_start(k-1) - 2*t_rise(k-1);
		if t_pe > t_limit
			t_pe = t_limit;
			u.tL_fit = false;
			warning(sprintf('mataa_IR_HD_extract: harmonic %d ends before tL because harmonic %d arrives.', k, k-1));
		end
	end
	if t_pe <= t_ps
		error(sprintf('mataa_IR_HD_extract: harmonic %d has no room between its neighbors.', k));
	end
	t_block = t_pe;

	i = find((t >= t_ps) & (t <= t_pe));
	if isempty(i)
		error(sprintf('mataa_IR_HD_extract: harmonic %d piece (%g s .. %g s) contains no samples.', k, t_ps, t_pe));
	end
	t_abs = t(i);
	w = hd_window(t_abs, t_start(k) - t_rise(k), t_pe - t_rise(k));
	u.h = h(i) .* w;
	u.t = t_abs - t_abs(1);
	u.t_ref = t_start(k) - t_abs(1);
	u.t_piece_start = t_abs(1);
	u.t_piece_end = t_abs(end);
	pieces{k} = u;
end
pieces = [pieces{:}];

end

function [t_lo, t_hi] = hd_search_limits(t, tN, k)
% Time range around harmonic k that does not contain a neighboring arrival.
N = length(tN);
t_anchor = -tN(k);
if k < N
	t_lo = -0.5 * (tN(k) + tN(k+1));
else
	if N > 1
		t_lo = t_anchor - (tN(N) - tN(N-1));
	else
		t_lo = t(1);
	end
end
if k > 1
	t_hi = -0.5 * (tN(k) + tN(k-1));
else
	if N > 1
		t_hi = 0.5 * tN(2);
	else
		t_hi = t(end);
	end
end
t_lo = max(t_lo, t(1));
t_hi = min(t_hi, t(end));
end

function [t_start, t_rise, found] = hd_find_onset(h, t, t_anchor, t_lo, t_hi, dt)
t_start = t_anchor;
t_rise = 8 * dt;
found = false;
i = find((t >= t_lo) & (t <= t_hi));
if length(i) < 8
	warning(sprintf('mataa_IR_HD_extract: onset search around %g s is too short. Using the Farina time.', t_anchor));
	return
end
try
	[t_start, t_rise] = mataa_guess_IR_start(h(i), t(i), [], 0);
	found = true;
catch
	t_start = t_anchor;
	t_rise = 8 * dt;
	warning(sprintf('mataa_IR_HD_extract: harmonic onset not found near %g s. Using the Farina time.', t_anchor));
end
if ~isfinite(t_rise) || t_rise <= 0
	t_rise = 8 * dt;
end
end

function w = hd_window(t_abs, t_unity_begin, t_unity_end)
n = length(t_abs);
w = ones(n, 1);
if n == 1
	w(1) = 0;
	return
end
i_in = find(t_abs < t_unity_begin);
i_out = find(t_abs > t_unity_end);
if ~isempty(i_in) && ~isempty(i_out) && i_in(end) >= i_out(1)
	imid = max(2, min(n-1, round(n/2)));
	i_in = (1:imid-1)';
	i_out = (imid+1:n)';
end
if ~isempty(i_in)
	w(i_in) = hd_sine_rise(length(i_in));
end
if ~isempty(i_out)
	w(i_out) = hd_sine_fall(length(i_out));
end
w(1) = 0;
w(end) = 0;
end

function w = hd_sine_fall(n)
if n < 2
	w = 0;
	return
end
w = mataa_signal_window(ones(n, 1), 'sine_half');
w(1) = 1;
w(end) = 0;
end

function w = hd_sine_rise(n)
w = flipud(hd_sine_fall(n));
end
