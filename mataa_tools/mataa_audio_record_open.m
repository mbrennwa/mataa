function mataa_audio_record_open (fs, channels);

% function mataa_audio_record_open (fs, channels);
%
% DESCRIPTION:
% Open Playrec for capture only (play device -1). The first call scans ALSA
% and initialises PortAudio, which is slow. Later calls return immediately
% when Playrec is already open at this sample rate with no play device and
% enough input channels. Call this before asking the user to start playback,
% then call mataa_audio_record, which only queues the capture.
%
% mataa_settings('audio_IO_method') must already be Playrec. This function
% does not change the setting.
%
% INPUT:
% fs: sample rate (Hz).
% channels (optional): Playrec input channel list. Default is
%   mataa_settings('channel_DUT').
%
% OUTPUT:
% (none)
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

if nargin < 1
	error('mataa_audio_record_open: need fs.');
end
if ~isscalar(fs) || ~(fs > 0)
	error('mataa_audio_record_open: fs must be a positive sample rate.');
end
if ~exist('channels', 'var') || isempty(channels)
	channels = mataa_settings('channel_DUT');
end
channels = channels(:)';
if isempty(channels) || any(channels < 1)
	error('mataa_audio_record_open: channels must be positive Playrec input channel numbers.');
end

method = mataa_settings('audio_IO_method');
if ischar(method)
	method_label = method;
else
	method_label = num2str(method);
end
if ~ischar(method) || ~strcmpi(method, 'Playrec')
	error(sprintf('mataa_audio_record_open: audio_IO_method is ''%s''. Set it to Playrec before recording. This function does not change the setting.', method_label));
end

if ~exist('playrec', 'file')
	error('mataa_audio_record_open: Playrec is not available.');
end

if __capture_already_open(fs, channels)
	return
end

input_id = __playrec_input_id(mataa_settings('audio_PlayRec_InputDeviceName'));

% Drop a previous full-duplex init. Opening play and capture together can
% hang (seen with PipeWire behind a default device) and never finish.
if playrec('isInitialised')
	playrec('reset');
end
% framesPerBuffer 0 lets PortAudio pick the period. On PipeWire that period
% was 104 frames and the callback then ran at about half the sample rate:
% 5 s of samples took about 10 s of real time. 1024 frames matches a typical
% PipeWire quantum and keeps the capture clock at fs.
playrec('init', fs, -1, input_id, 1, max(channels), 1024);
if ~playrec('isInitialised')
	error('mataa_audio_record_open: could not configure Playrec for capture.');
end
if playrec('getRecMaxChannel') < max(channels)
	error(sprintf('mataa_audio_record_open: capture device does not provide channel %d.', max(channels)));
end

end


function ready = __capture_already_open (fs, channels);

ready = false;
if ~playrec('isInitialised')
	return
end
if playrec('getSampleRate') ~= fs
	return
end
if playrec('getRecMaxChannel') < max(channels)
	return
end
% Suggested frames per buffer. 0 is the automatic period that runs slow.
frames = playrec('getFramesPerBuffer');
if isempty(frames) || frames(1) ~= 1024
	return
end
play_id = playrec('getPlayDevice');
% Capture-only init uses play device -1.
if isempty(play_id) || play_id ~= -1
	return
end
ready = true;

end


function input_id = __playrec_input_id (input_device);

% Match the full PortAudio name, or that name up to the ": host (hw:…)"
% suffix. A substring search would select sysdefault when the name is default.

if isempty(input_device) || (ischar(input_device) && strcmpi(input_device, 'unknown'))
	error('mataa_audio_record_open: set mataa_settings(''audio_PlayRec_InputDeviceName'') to the Playrec capture device.');
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
	error(sprintf('mataa_audio_record_open: no Playrec capture device matches <%s>.', input_device_label));
elseif length(match) > 1
	warning(sprintf('mataa_audio_record_open: several Playrec capture devices match <%s>. Using the first.', input_device_label));
end
input_id = devices(match(1)).deviceID;

end
