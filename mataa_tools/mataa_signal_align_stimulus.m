function [y_crop, x_ref, rho] = mataa_signal_align_stimulus (y, x, fs, span);

% function [y_crop, x_ref, rho] = mataa_signal_align_stimulus (y, x, fs, span);
%
% DESCRIPTION:
% Find the stimulus x inside the recording y.
%
% Without span, crop y so that it starts at the correlation peak and keeps
% whatever tail is still in the buffer. x_ref is x with trailing zeros so
% that it has the same length as y_crop. For a raw copy of x that peak is
% the first sample of x. For a sweep played through a loudspeaker it is the
% impulse peak, and the rise before that peak is not in the crop.
%
% With span 'file', x is the whole stimulus file. The crop is length(x)
% samples of y: the part of the recording that corresponds to that file.
% Samples outside it are the fudge and are left out. The correlation peak
% is the impulse peak, so the window starts at the beginning of the impulse
% rather than on that peak. x_ref is x.
%
% The lag comes from xcorr(y, x). For that call, the first sample of x lies
% at index lag+1 in y (checked with a delayed impulse: a lag of 4 placed a
% 5-sample pattern at sample 5). A one-sample stimulus is not passed to
% xcorr, because a scalar second argument is maxlag; the onset is the
% largest sample instead.
%
% Reject the take when x does not lie strictly inside y: the whole stimulus
% must be in the buffer, and at least one sample must remain after it.
% For a stimulus of at least 0.1 s, also reject when the absolute correlation
% of x with that aligned slice is below 0.2. The correlation is computed on
% the slice, not on the whole buffer. A shorter stimulus, including a Dirac,
% uses the geometric test only.
%
% INPUT:
% y: recording (vector).
% x: stimulus (vector). Without span, the bare stimulus. With span 'file',
%   the whole stimulus file.
% fs: sample rate of y and x (Hz).
% span (optional): pass 'file' to keep length(x) samples aligned to the
%   whole file. Omit it to keep the tail after the correlation peak.
%
% OUTPUT:
% y_crop: recording from the chosen onset through the end of the buffer,
%   or, when span is 'file', the file span only.
% x_ref: stimulus padded with trailing zeros to length(y_crop), or x itself
%   when span is 'file'.
% rho: absolute correlation of x with the aligned slice (NaN if the slice
%      does not lie in the buffer).
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

if nargin < 3
	error('mataa_signal_align_stimulus: need y, x, and fs.');
end
if ~isvector(y) || ~isvector(x) || isempty(y) || isempty(x)
	error('mataa_signal_align_stimulus: y and x must be non-empty vectors.');
end
if ~isscalar(fs) || ~(fs > 0)
	error('mataa_signal_align_stimulus: fs must be a positive sample rate.');
end
if exist('span', 'var')
	if ~ischar(span) || ~strcmp(span, 'file')
		error('mataa_signal_align_stimulus: the fourth argument must be ''file''.');
	end
	[y_crop, x_ref, rho] = __align_file(y, x, fs);
	return
end

y = y(:);
x = x(:);
rho = NaN;

if length(x) == 1
	% xcorr(y, scalar) treats the scalar as maxlag, not as a one-sample stimulus.
	[~, i0] = max(abs(y) * abs(x));
else
	if exist('xcorr') ~= 2
		if exist('OCTAVE_VERSION', 'builtin')
			pkg load signal;
		end
	end
	if exist('xcorr') ~= 2
		error('mataa_signal_align_stimulus: xcorr is not available. Install the Octave signal package.');
	end
	[c, lags] = xcorr(y, x);
	[~, k] = max(abs(c));
	i0 = lags(k) + 1;
end
i1 = i0 + length(x) - 1;

if i0 < 1 || i1 > length(y)
	disp('mataa_signal_align_stimulus: correlation with aligned stimulus = (stimulus is not inside the buffer)');
	error('mataa_signal_align_stimulus: the stimulus does not lie fully inside the recording. Playback started too late, or the recording was shorter than the player delay plus the stimulus.');
end

slice = y(i0:i1);
nx = norm(x);
ns = norm(slice);
if nx == 0 || ns == 0
	error('mataa_signal_align_stimulus: stimulus or aligned slice has zero energy.');
end
rho = abs(dot(slice, x)) / (nx * ns);
disp(sprintf('mataa_signal_align_stimulus: correlation with aligned stimulus = %.3f', rho));

duration = length(x) / fs;
if duration >= 0.1
	if rho < 0.2
		error(sprintf('mataa_signal_align_stimulus: correlation %.3f is below 0.2. The recording does not contain this stimulus.', rho));
	end
else
	warning('mataa_signal_align_stimulus: stimulus is shorter than 0.1 s. The correlation threshold is not applied.');
end

if i1 >= length(y)
	error('mataa_signal_align_stimulus: no samples remain after the stimulus. Increase fudge so the response tail fits in the recording.');
end

y_crop = y(i0:end);
x_ref = [ x ; zeros(length(y_crop) - length(x), 1) ];

end


function [y_crop, x_ref, rho] = __align_file (y, x, fs)

% Keep length(x) samples of y. x is the whole stimulus file. The correlation
% peak is the impulse peak, which is later than the start of the file, so a
% window that starts there cuts off the rise.

y = y(:);
x = x(:);
rho = NaN;
if length(y) <= length(x)
	error('mataa_signal_align_stimulus: the recording is not longer than the stimulus file. Increase fudge so playback can be early or late.');
end
if length(x) == 1
	[~, i0] = max(abs(y) * abs(x));
else
	if exist('xcorr') ~= 2
		if exist('OCTAVE_VERSION', 'builtin')
			pkg load signal;
		end
	end
	if exist('xcorr') ~= 2
		error('mataa_signal_align_stimulus: xcorr is not available. Install the Octave signal package.');
	end
	[c, lags] = xcorr(y, x);
	[~, k] = max(abs(c));
	i0 = lags(k) + 1;
end

% 50 ms is enough look-back for the direct sound. One millisecond before
% the detected onset keeps the foot of the rise inside the file span.
n_look = round(0.05 * fs);
n_margin = round(1e-3 * fs);
i_last = length(y) - length(x) + 1;
i_early = i0 - n_look;
if i_early < 1
	i_early = 1;
end
if i_early > i_last
	i_early = i_last;
end
h = mataa_IR_deconvolve(y(i_early:i_early + length(x) - 1), x, 1);
[pk, i_peak] = max(abs(h));
if pk == 0
	error('mataa_signal_align_stimulus: deconvolution of the stimulus file is zero.');
end
thr = 0.05 * pk;
if i_early == 1 && abs(h(1)) >= thr
	error('mataa_signal_align_stimulus: the impulse is already under way at the start of the recording. Start playback after recording starts, and increase fudge so that delay fits.');
end
need = max(1, round(0.3e-3 * fs));
run = 0;
i_on = 1;
for n = i_peak:-1:1
	if abs(h(n)) < thr
		run = run + 1;
		if run >= need
			i_on = n + need;
			break
		end
	else
		run = 0;
	end
end
i_start = i_early + i_on - 1 - n_margin;
if i_start < 1
	i_start = 1;
end
i_end = i_start + length(x) - 1;
if i_end > length(y)
	error('mataa_signal_align_stimulus: the stimulus file runs past the end of the recording. Playback started too late. Increase fudge.');
end

y_crop = y(i_start:i_end);
x_ref = x;

% Correlation is judged at the peak, where a missing stimulus is obvious.
% The crop itself starts earlier, at the beginning of the impulse.
k = find(x ~= 0);
if isempty(k)
	error('mataa_signal_align_stimulus: stimulus file is silent.');
end
i_sig = i0 + k(1) - 1;
j_sig = i0 + k(end) - 1;
if i_sig < 1 || j_sig > length(y)
	disp('mataa_signal_align_stimulus: correlation with aligned stimulus = (stimulus is not inside the buffer)');
	error('mataa_signal_align_stimulus: the stimulus does not lie fully inside the recording. Playback started too late, or the recording was shorter than the player delay plus the stimulus.');
end
x_sig = x(k(1):k(end));
slice = y(i_sig:j_sig);
nx = norm(x_sig);
ns = norm(slice);
if nx == 0 || ns == 0
	error('mataa_signal_align_stimulus: stimulus or aligned slice has zero energy.');
end
rho = abs(dot(slice, x_sig)) / (nx * ns);
disp(sprintf('mataa_signal_align_stimulus: correlation with aligned stimulus = %.3f', rho));
if length(x_sig) / fs >= 0.1 && rho < 0.2
	error(sprintf('mataa_signal_align_stimulus: correlation %.3f is below 0.2. The recording does not contain this stimulus.', rho));
end

end
