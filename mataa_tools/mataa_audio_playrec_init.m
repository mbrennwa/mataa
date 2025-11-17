function success = mataa_audio_playrec_init (fs, output_device, input_device, num_output_chan, num_input_chan);

% function success = mataa_audio_playrec_init (fs, output_device, input_device, num_output_chan, num_input_chan);
%
% DESCRIPTION:
% Check if PlayRec is initialised with the given sample rate and audio input / output devices, and reset/init PlayRec accordingly if needed.
%
% INPUT:
% fs: sample rate (samples per second)
% output_device, input_device: device identifiers for PlayRec audio output and input, either a (partial) string label or PlayRec ID numers (string or integer)
% num_output_chan, num_input_chan: number of input channels needed for audio output and input
%
% OUTPUT:
% success: flag indicating of PlayRec is initialised properly according to the INPUTs (bool)
% 
% EXAMPLE:
% > mataa_audio_playrec_init (44100, 'RTX6001', 'RTX6001', 2, 2)
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
% Copyright (C) 2020 Matthias S. Brennwald.
% Contact: info@audioroot.net
% Further information: http://www.audioroot.net/MATAA

success = true;

if ~exist('playrec')
	success = false
	error ('mataa_audio_init_playrec: PlayRec is not available. Please see the MATAA manual for instructions on how to install PlayRec.')
end

[dev_names, dev_IDs] = mataa_audio_playrec_list_devices ();

if ischar(output_device)
	v = find(strcmp(dev_names,output_device));
	if isempty(v)
		error(sprintf('mataa_audio_init_playrec: found no PlayRec device that matches the <%s> string.',output_device))
	elseif length(v) > 1
		warning(sprintf('mataa_audio_init_playrec: found multiple PlayRec devices that match <%s> string. Using the first one...',output_device))
		v = v(1);
	end
	output_device = dev_IDs(v);
end

if ischar(input_device)
	v = find(strcmp(dev_names,input_device));
	if isempty(v)
		error(sprintf('mataa_audio_init_playrec: found no PlayRec device that matches the <%s> string.',input_device))
	elseif length(v) > 1
		warning(sprintf('mataa_audio_init_playrec: found multiple PlayRec devices that match <%s> string. Using the first one...',input_device))
		v = v(1);
	end
	input_device = dev_IDs(v);
end

% Test if current PlayRec initialisation is ok
if(playrec('isInitialised'))
	if playrec('getSampleRate') ~= fs
		playrec('reset');
	elseif playrec('getPlayDevice') ~= output_device
		playrec('reset');
	elseif playrec('getRecDevice') ~= input_device
		playrec('reset');
	elseif playrec('getPlayMaxChannel') < num_output_chan
		playrec('reset');
	elseif playrec('getRecMaxChannel') < num_input_chan
		playrec('reset');
	end
end

% Initialise if necessary
if ~playrec('isInitialised')
	warning ('mataa_audio_playrec_init: audio I/O using PlayRec in MATAA is still experimental!')
	playrec('init', fs, output_device, input_device);
	### playrec('init', fs, 10, 10,2,2);
end

if ~playrec('isInitialised')
	warning ('mataa_audio_init_playrec: unable to initialise playrec correctly');
	success = false;
elseif playrec('getPlayMaxChannel') < num_output_chan
	warning ('mataa_audio_init_playrec: selected output device does not support %d channels\n', num_output_chan);
	success = false;
elseif playrec('getRecMaxChannel') < num_input_chan
	warning ('mataa_audio_init_playrec: selected input device does not support %d channels\n', num_input_chan);
	success = false;
end

%Clear all previous pages
if playrec('isInitialised')
	playrec('delPage');
end

% Check if sample rate was one of the "conventional" values, and show a warning if necessary.
% WARNING NOTE: PortAudio / PlayRec may happily accept any "in-between" sample rate, which will involve undesired re-sampling or using the closest sample-rate value
fs_std = ([ 44100 48000 ]' * [ 0.5 1 2 4 8])(:);
if ~any(fs_std == fs)
	warning (sprintf('mataa_audio_playrec_init: the requested sample rate %g per second is not one of the conventional audio sample rate values. Be careful!',fs))
end
