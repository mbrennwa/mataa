function mataa_test_audio_info

% function mataa_test_audio_info
%
% DESCRIPTION:
% Soak test for the TestDevices parser. This file lives in tests/, which is
% not part of the user path. It does not open a sound device, does not run
% TestDevices, and does not change MATAA settings.
%
% Each pass reads a transcript in the TestDevicesPA19 format, including a
% short line, a blank line, and the end of the file. The same two transcripts
% are parsed many times. A legacy-function warning is an error.
%
% EXAMPLE:
% > addpath /path/to/mataa/tests
% > mataa_test_audio_info
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

script_dir = fileparts (mfilename ('fullpath'));
if isempty (script_dir)
	script_dir = pwd;
end
priv_dir = fullfile (fileparts (script_dir), 'mataa_tools', 'private');
addpath (priv_dir);

if exist ('OCTAVE_VERSION', 'builtin')
	more ('off');
end

full_text = __transcript ('USB Audio CODEC', 'USB Audio CODEC');
half_text = __transcript ('USB Audio CODEC', 'HDMI');
n_soak = 200;

legacy = warning ('query', 'Octave:legacy-function');
warning ('error', 'Octave:legacy-function');
unwind_protect
	for k = 1:n_soak
		full = __parse (full_text);
		__check (strcmp (full.input.name, 'USB Audio CODEC'), 'full-duplex input name');
		__check (strcmp (full.output.name, 'USB Audio CODEC'), 'full-duplex output name');
		__check (strcmp (full.input.API, 'ALSA'), 'full-duplex input API');
		__check (strcmp (full.output.API, 'ALSA'), 'full-duplex output API');
		__check (isequal (full.input.channels, 2), 'full-duplex input channels');
		__check (isequal (full.output.channels, 2), 'full-duplex output channels');
		__check (isequal (full.input.sampleRates, [44100 48000]), 'full-duplex input rates');
		__check (isequal (full.output.sampleRates, [44100 48000]), 'full-duplex output rates');

		half = __parse (half_text);
		__check (strcmp (half.output.name, 'HDMI'), 'half-duplex output name');
		__check (isequal (half.input.sampleRates, [44100 48000 96000]), 'half-duplex input rates');
		__check (isequal (half.output.sampleRates, [44100 48000 96000]), 'half-duplex output rates');
	end
unwind_protect_cleanup
	warning (legacy.state, 'Octave:legacy-function');
	if any (strcmp (strsplit (path, pathsep), priv_dir))
		rmpath (priv_dir);
	end
end_unwind_protect

disp (sprintf ('mataa_test_audio_info: %d passes, all checks passed.', n_soak));

end


function info = __parse (text)
	path = [tempname() '.txt'];
	fid = fopen (path, 'wt');
	fwrite (fid, text);
	fclose (fid);
	fid = fopen (path, 'rt');
	info = mataa_audio_info_parse (fid, __blank ());
	fclose (fid);
	delete (path);
end


function text = __transcript (in_name, out_name)
	text = sprintf ([ ...
		'Default\n' ...
		'\n' ...
		'Default input device = %s\n' ...
		'Host API (input) = ALSA\n' ...
		'Max input channels = 2\n' ...
		'Supported standard sample rates (input, half-duplex, 16 bit, 2 channels) = \t44100.00, 48000.00, 96000.00\n' ...
		'Supported standard sample rates (input, full-duplex, 16 bit, 2 channels) = \t44100.00, 48000.00\n' ...
		'\n' ...
		'Default output device = %s\n' ...
		'Host API (output) = ALSA\n' ...
		'Max output channels = 2\n' ...
		'Supported standard sample rates (output, half-duplex, 16 bit, 2 channels) = \t44100.00, 48000.00, 96000.00\n' ...
		'Supported standard sample rates (output, full-duplex, 16 bit, 2 channels) = \t44100.00, 48000.00\n' ...
		'----------------------------------------------\n' ], in_name, out_name);
end


function audioInfo = __blank ()
	audioInfo.input.name = '(UNKNOWN)';
	audioInfo.input.channels = [];
	audioInfo.input.sampleRates = [];
	audioInfo.input.API = 'UNKNOWN';
	audioInfo.output.API = 'UNKNOWN';
	audioInfo.output = audioInfo.input;
end


function __check (cond, msg)
	if ~cond
		error (sprintf ('mataa_test_audio_info: %s.', msg));
	end
end
