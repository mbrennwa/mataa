function [y_crop, x_ref, rho] = mataa_signal_align_stimulus (y, x, fs, T_lead, T_trail);

% function [y_crop, x_ref, rho] = mataa_signal_align_stimulus (y, x, fs, T_lead, T_trail);
%
% DESCRIPTION:
% Find the bare stimulus x inside the recording y.
%
% Without T_lead and T_trail, crop y so that it starts at the correlation
% peak and keeps whatever tail is still in the buffer. x_ref is x with
% trailing zeros so that it has the same length as y_crop. For a raw copy
% of x that peak is the first sample of x. For a sweep played through a
% loudspeaker it is the impulse peak, and the rise before that peak is not
% in the crop.
%
% With T_lead and T_trail, the crop is the time span of the stimulus file:
% T_lead of silence, the bare stimulus, and T_trail of silence. Samples
% past that span (the recording fudge) are left out. The correlation peak
% is not used as the start of the bare stimulus. A first deconvolution,
% with the sweep placed T_lead before that peak, locates the sweep onset
% so the rise stays inside the file span. x_ref is that file: lead silence,
% x, trail silence.
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
% x: bare stimulus (vector).
% fs: sample rate of y and x (Hz).
% T_lead, T_trail (optional): leading and trailing silence of the stimulus
%   file, in seconds. Pass both to crop to that file instead of the
%   correlation peak. Omit both to keep the tail after the peak.
%
% OUTPUT:
% y_crop: recording from the chosen onset through the end of the buffer,
%   or, when T_lead and T_trail are given, the file span only.
% x_ref: bare stimulus padded with trailing zeros to length(y_crop), or
%   the file (lead silence, x, trail silence) when T_lead and T_trail are given.
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
file_span = false;
if exist('T_lead', 'var') || exist('T_trail', 'var')
	if ~exist('T_lead', 'var') || ~exist('T_trail', 'var') || isempty(T_lead) || isempty(T_trail)
		error('mataa_signal_align_stimulus: pass both T_lead and T_trail, or neither.');
	end
	if ~isscalar(T_lead) || ~isscalar(T_trail) || T_lead < 0 || T_trail < 0
		error('mataa_signal_align_stimulus: T_lead and T_trail must be durations >= 0 seconds.');
	end
	file_span = true;
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

if ~file_span
	y_crop = y(i0:end);
	x_ref = [ x ; zeros(length(y_crop) - length(x), 1) ];
	return
end

% The correlation peak is the impulse peak. Place the bare stimulus T_lead
% before that peak and deconvolve once: the sweep onset is the start of
% that impulse, which is earlier than the peak. The file span is then
% T_lead before that onset through T_trail after the bare stimulus.
n_lead = round(T_lead * fs);
n_trail = round(T_trail * fs);
i_c = i0 - n_lead;
n_file = n_lead + length(x) + n_trail;
if i_c < 1
	error('mataa_signal_align_stimulus: the lead-in silence is not fully inside the recording. Start playback after the recording has started.');
end
if i_c + n_file - 1 > length(y)
	error('mataa_signal_align_stimulus: the trailing silence is not fully inside the recording. Increase fudge so it covers T_trail and the playback delay.');
end
y_probe = y(i_c:i_c + n_file - 1);
x_probe = [ x ; zeros(n_file - length(x), 1) ];
h_probe = mataa_IR_deconvolve(y_probe, x_probe, 1);
% The probe impulse is complete. Its peak is not the sweep onset: walk
% back to the first sample of the rise. guess_IR_start stops near the
% half-amplitude point and would still cut the beginning.
[~, i_peak] = max(abs(h_probe));
n_look = min(i_peak - 1, round(5e-3 * fs));
thr = 0.01 * abs(h_probe(i_peak));
i_h = i_peak;
for n = i_peak - 1:-1:i_peak - n_look
	if abs(h_probe(n)) < thr
		i_h = n + 1;
		break
	end
	i_h = n;
end
i_stim = i_c + i_h - 1;
i_start = i_stim - n_lead;
i_end = i_stim + length(x) + n_trail - 1;
if i_start < 1
	error('mataa_signal_align_stimulus: the lead-in silence is not fully inside the recording. Start playback after the recording has started.');
end
if i_end > length(y)
	error('mataa_signal_align_stimulus: the trailing silence is not fully inside the recording. Increase fudge so it covers T_trail and the playback delay.');
end

y_crop = y(i_start:i_end);
x_ref = [ zeros(n_lead, 1) ; x ; zeros(n_trail, 1) ];

end
