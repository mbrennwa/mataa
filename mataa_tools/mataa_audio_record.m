function [y, t] = mataa_audio_record (fs, T, channels);

% function [y, t] = mataa_audio_record (fs, T, channels);
%
% DESCRIPTION:
% Record for T seconds with Playrec. The play device stays closed
% (playrec init with play device -1). This function does not prompt, does
% not calibrate, and does not read a stimulus file. The caller must finish
% any wait before calling, because playrec('rec') returns as soon as the
% recording is queued.
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

method = mataa_settings('audio_IO_method');
if ischar(method)
	method_label = method;
else
	method_label = num2str(method);
end
if ~ischar(method) || ~strcmpi(method, 'Playrec')
	error(sprintf('mataa_audio_record: audio_IO_method is ''%s''. Set it to Playrec before recording. This function does not change the setting.', method_label));
end

if ~exist('playrec', 'file')
	error('mataa_audio_record: Playrec is not available.');
end

input_id = __playrec_input_id(mataa_settings('audio_PlayRec_InputDeviceName'));

% Drop a previous full-duplex init. Opening play and capture together can
% hang (seen with PipeWire behind a default device) and never finish.
if playrec('isInitialised')
	playrec('reset');
end
playrec('init', fs, -1, input_id);
if ~playrec('isInitialised')
	error('mataa_audio_record: could not configure Playrec for capture.');
end
if playrec('getRecMaxChannel') < max(channels)
	error(sprintf('mataa_audio_record: capture device does not provide channel %d.', max(channels)));
end

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


function input_id = __playrec_input_id (input_device);

% Match the full PortAudio name, or that name up to the ": host (hw:…)"
% suffix. A substring search would select sysdefault when the name is default.

if isempty(input_device) || (ischar(input_device) && strcmpi(input_device, 'unknown'))
	error('mataa_audio_record: set mataa_settings(''audio_PlayRec_InputDeviceName'') to the Playrec capture device.');
end

devices = playrec('getDevices');
if ischar(input_device)
	input_device_label = input_device;
else
	input_device_label = num2str(input_device);
end

match = [];
for k = 1:length(devices)
	if devices(k).inputChans < 1
		continue
	end
	name = devices(k).name;
	if exist('undo_string_escapes')
		name = undo_string_escapes(name);
	end
	if ischar(input_device)
		is_match = strcmp(name, input_device) || strncmp(name, [input_device ':'], length(input_device) + 1);
	else
		is_match = devices(k).deviceID == input_device;
	end
	if is_match
		match(end+1) = k;
	end
end

if isempty(match)
	error(sprintf('mataa_audio_record: no Playrec capture device matches <%s>.', input_device_label));
elseif length(match) > 1
	warning(sprintf('mataa_audio_record: several Playrec capture devices match <%s>. Using the first.', input_device_label));
end
input_id = devices(match(1)).deviceID;

end
