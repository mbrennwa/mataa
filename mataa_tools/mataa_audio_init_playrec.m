function success = mataa_audio_init_playrec (fs, output_ID, input_ID, num_output_chan, num_input_chan);

% function success = mataa_audio_init_playrec;
%
% DESCRIPTION:
% Check if PlayRec is initialised with the given sample rate and audio input / output devices, and reset/init PlayRec accordingly if needed.
%
% INPUT:
% fs: sample rate (samples per second)
% output_ID, input_ID: PlayRec IDs of the audio devices used for audio output and input
% num_output_chan, num_input_chan: number of input channels needed for audio output and input
%
% OUTPUT:
% success: flag indicating of PlayRec is initialised properly according to the INPUTs (bool)
% 
% EXAMPLE:
% > mataa_audio_init_playrec (44100, 0, 0, 2, 2)
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

% Test if current PlayRec initialisation is ok
if(playrec('isInitialised'))
	if playrec('getSampleRate') ~= fs
		% fprintf('Changing playrec sample rate from %d to %d\n', playrec('getSampleRate'), Fs);
		playrec('reset');
	elseif playrec('getPlayDevice') ~= output_ID
		% fprintf('Changing playrec play device from %d to %d\n', playrec('getPlayDevice'), output_ID);
		playrec('reset');
	elseif playrec('getRecDevice') ~= input_ID
		% fprintf('Changing playrec record device from %d to %d\n', playrec('getRecDevice'), input_ID);
		playrec('reset');
	elseif playrec('getPlayMaxChannel') < num_output_chan
		% fprintf('Resetting playrec to configure device to use more input channels\n');
		playrec('reset');
	elseif playrec('getRecMaxChannel') < num_input_chan
		% fprintf('Resetting playrec to configure device to use more input channels\n');
		playrec('reset');
	end
end

%Initialise if necessary
if ~playrec('isInitialised')
	% fprintf('Initialising playrec to use sample rate: %d, recDeviceID: %d and no play device\n', Fs, recDeviceID);
	playrec('init', fs, output_ID, input_ID);
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
