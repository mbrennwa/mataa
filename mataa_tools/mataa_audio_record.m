function [y, t] = mataa_audio_record (fs, T, channels);

% function [y, t] = mataa_audio_record (fs, T, channels);
%
% DESCRIPTION:
% Record for T seconds with Playrec. The play device stays closed.
% mataa_audio_record_open does the slow PortAudio startup; call that first
% when a user is about to start an external player. This function opens
% Playrec itself when it is not already open, then queues the capture.
% It does not prompt, does not calibrate, and does not read a stimulus file.
% playrec('rec') returns as soon as the recording is queued.
%
% mataa_settings('audio_IO_method') must already be Playrec. TestTone, or
% any other setting, is an error. This function does not change the setting.
% The capture device is mataa_settings('audio_PlayRec_InputDeviceName').
% Do not use mataa_audio_playrec_init here: that function always opens a
% play device.
%
% INPUT:
% fs: sample rate (Hz).
% T: recording length (seconds).
% channels (optional): Playrec input channel list. Default is
%   mataa_settings('channel_DUT').
%
% OUTPUT:
% y: recorded samples (double, one column per channel). Playrec returns
%    single; this function casts to double.
% t: time vector (seconds), starting at 0.
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

if nargin < 2
	error('mataa_audio_record: need fs and T.');
end
if ~isscalar(fs) || ~(fs > 0)
	error('mataa_audio_record: fs must be a positive sample rate.');
end
if ~isscalar(T) || ~(T > 0)
	error('mataa_audio_record: T must be a positive duration.');
end
if ~exist('channels', 'var') || isempty(channels)
	channels = mataa_settings('channel_DUT');
end
channels = channels(:)';
if isempty(channels) || any(channels < 1)
	error('mataa_audio_record: channels must be positive Playrec input channel numbers.');
end

mataa_audio_record_open(fs, channels);

n_samples = round(T * fs);
if n_samples < 1
	error('mataa_audio_record: recording length is shorter than one sample.');
end

pageNumber = playrec('rec', n_samples, channels);
unwind_protect
	playrec('block', pageNumber);
	y = playrec('getRec', pageNumber);
unwind_protect_cleanup
	playrec('delPage', pageNumber);
end_unwind_protect

if isempty(y)
	error('mataa_audio_record: Playrec returned no samples.');
end
y = double(y);
t = (0:size(y,1)-1)' / fs;

end
