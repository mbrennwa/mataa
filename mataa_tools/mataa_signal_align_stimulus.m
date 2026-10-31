function [y_crop, x_ref, rho] = mataa_signal_align_stimulus (y, x, fs);

% function [y_crop, x_ref, rho] = mataa_signal_align_stimulus (y, x, fs);
%
% DESCRIPTION:
% Find the bare stimulus x inside the recording y and crop y so that it
% starts at that onset and keeps whatever tail is still in the buffer.
% x_ref is x with trailing zeros so that it has the same length as y_crop.
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
%
% OUTPUT:
% y_crop: recording from the stimulus onset through the end of the buffer.
% x_ref: bare stimulus padded with trailing zeros to length(y_crop).
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
