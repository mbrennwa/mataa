function [s, fs, T_lead, T_trail] = mataa_stimulus_wav_read (file);

% function [s, fs, T_lead, T_trail] = mataa_stimulus_wav_read (file);
%
% DESCRIPTION:
% Read a WAV written by mataa_stimulus_wav_write (or the same layout).
% s is the whole file, including the leading and trailing silence. That is
% the signal the external player plays. T_lead and T_trail are the lengths
% of the exact-zero padding at each end.
%
% INPUT:
% file: path of the mono WAV copy kept for MATAA.
%
% OUTPUT:
% s: whole file (column), including leading and trailing silence.
% fs: sample rate (Hz).
% T_lead: leading silence (seconds).
% T_trail: trailing silence (seconds).
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

if nargin < 1 || ~ischar(file) || isempty(file)
	error('mataa_stimulus_wav_read: file name must be a non-empty string.');
end
if ~exist(file, 'file')
	error(sprintf('mataa_stimulus_wav_read: could not find ''%s''.', file));
end

[y, fs] = audioread(file);
if size(y, 2) ~= 1
	error('mataa_stimulus_wav_read: the WAV must be mono.');
end
y = y(:);

k = find(y ~= 0);
if isempty(k)
	error('mataa_stimulus_wav_read: the file contains no stimulus.');
end

s = y;
T_lead = (k(1) - 1) / fs;
T_trail = (length(y) - k(end)) / fs;

end
