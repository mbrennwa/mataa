function pieces = mataa_IR_HD_extract (h, t, tN, tL)

% function pieces = mataa_IR_HD_extract (h, t, tN, tL)
%
% DESCRIPTION:
% Cut the fundamental and each harmonic out of an impulse response that was
% obtained with the Farina inverse filter. The Farina times fix the spacing:
% harmonic k lies tN(k) before the fundamental. That grid is slid across the
% impulse response to the position that best matches every harmonic together.
% Each piece ends tL after its beginning, unless the next harmonic arrives
% sooner. A half-sine fade brings both ends of the piece to zero. The middle,
% including the beginning of the impulse, stays at unity gain.
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
%	pieces(k).onset_found: false when the grid could not be fitted. Every harmonic
%	  carries the same value. The beginnings are then the Farina times.
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

dt = median(diff(t));
[t_start, t_rise, found] = hd_fit_grid(h, t, tN, tL, dt);
t_rise = repmat(t_rise, N, 1);
onset_found = repmat(found, N, 1);

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

function [t_start, t_rise, found] = hd_fit_grid(h, t, tN, tL, dt)
% Slide the rigid grid across h. The score at a fundamental time is the sum
% of the envelopes at every harmonic, so the spacing stays exactly tN. The
% rise is read once from the fundamental and used for every harmonic.
N = length(tN);
t_start = -tN;
t_rise = 8 * dt;
found = false;

if N > 1
	half = 0.5 * min(diff(tN));
else
	half = inf;
end
t_lo = t(1);
t_hi = t(end);
if isfinite(half)
	t_lo = max(t_lo, -half);
	t_hi = min(t_hi, half);
end
% The earliest harmonic has to stay inside the record.
t_lo = max(t_lo, t(1) + tN(end));
t_hi = min(t_hi, t(end));
i = find((t >= t_lo) & (t <= t_hi));
if length(i) < 8
	warning('mataa_IR_HD_extract: the Farina grid does not fit this record. Using the Farina times.');
	return
end

mag = abs(mataa_signal_analytic(h));
n = length(t);
stack = zeros(n, 1);
for k = 1:N
	shift = round(tN(k) / dt);
	if shift <= 0
		stack = stack + mag;
	elseif shift < n
		stack(shift+1:n) = stack(shift+1:n) + mag(1:n-shift);
	end
end

seg = stack(i);
crest = (max(seg) - mean(seg)) / std(seg);
[~, im] = max(seg);
stack_ok = isfinite(crest) && crest >= 7 && im > 1 && im < length(i);

% The envelope sum places the peaks when it has a real impulse. Otherwise
% the fundamental alone anchors the same grid.
try
	[t_begin, t_rise] = mataa_guess_IR_start(h(i), t(i), [], 0);
	raw_ok = isfinite(t_begin) && isfinite(t_rise) && t_rise > 0;
catch
	raw_ok = false;
	t_begin = NaN;
	t_rise = NaN;
end
if stack_ok
	t_peak = t(i(im));
elseif raw_ok
	[~, ip] = max(abs(h(i)));
	t_peak = t(i(ip));
else
	warning('mataa_IR_HD_extract: the Farina grid does not match the impulse response. Using the Farina times.');
	t_rise = 8 * dt;
	return
end
if ~raw_ok
	t_begin = t_peak;
	t_rise = 8 * dt;
end
t_rise_fit = t_rise;
if N > 1
	t_rise_max = 0.25 * min(diff(tN));
	if t_rise > t_rise_max
		t_rise = t_rise_max;
	end
end
if t_rise > 0.5 * tL
	t_rise = 0.5 * tL;
end
if t_rise < dt
	t_rise = 8 * dt;
end
if t_rise < t_rise_fit
	warning(sprintf('mataa_IR_HD_extract: rise time %g s does not fit the harmonic grid. Using %g s.', t_rise_fit, t_rise));
end

% Keep every peak in the flat middle of its piece.
lead = t_peak - t_begin;
if ~isfinite(lead) || lead < 0
	lead = 0;
end
if lead + t_rise > tL
	lead = tL - t_rise;
end
t_start = (t_peak - lead) - tN;
found = true;
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
