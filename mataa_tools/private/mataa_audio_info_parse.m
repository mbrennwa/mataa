function audioInfo = mataa_audio_info_parse (fid, audioInfo);

% function audioInfo = mataa_audio_info_parse (fid, audioInfo);
%
% DESCRIPTION:
% Private helper for mataa_audio_info. It is not on the user path. Read one
% TestDevices transcript from fid and fill audioInfo. The file pointer may
% already be at the start. Reading stops when fgetl returns a non-character
% (end of file), so the numeric end marker is never passed to strfind.
%
% A blank line is kept in the scan. Full-duplex sample rates are used when
% the input and output device names match; otherwise the half-duplex lists
% are used. Device-name lines are shortened to the text after '= ' before
% the later tests on that same line.
%
% INPUT:
% fid: file id of a TestDevices transcript, opened for reading.
% audioInfo: struct with input and output fields, used for any value the
%   transcript does not set.
%
% OUTPUT:
% audioInfo: input struct with names, channel counts, host APIs, and sample
%   rates taken from the transcript.
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
% Copyright (C) 2006, 2007, 2008, 2026 Matthias S. Brennwald.
% Contact: info@audioroot.net
% Further information: http://www.audioroot.net/MATAA

input_sampleRates_halfDuplex = [];
input_sampleRates_fullDuplex = [];
output_sampleRates_halfDuplex = [];
output_sampleRates_fullDuplex = [];

l = fgetl (fid);
while ischar (l)
	% disp (l)
	if strfind (l,'Default input device')
		l = l(strfind(l,'=')+2:end);
		if length(l) > 0
			audioInfo.input.name = l;
		end
	end;
	if strfind (l,'Host API (input)'), audioInfo.input.API = l(20:end); end;
	if strfind (l,'Host API (output)'), audioInfo.output.API = l(21:end); end;
	if strfind (l,'Max input channels'), audioInfo.input.channels = str2num(l(strfind(l,'=')+1:end)); end;
	if strfind (l,'Supported standard sample rates (input, full-duplex'), input_sampleRates_fullDuplex = str2num(l(strfind(l,'=')+1:end)); end;
	if strfind (l,'Supported standard sample rates (input, half-duplex'), input_sampleRates_halfDuplex = str2num(l(strfind(l,'=')+1:end)); end;
	if strfind (l,'Default output device')
		l = l(strfind(l,'=')+2:end);
		if length(l) > 0
			audioInfo.output.name = l;
		end
	end;

	if strfind (l,'Max output channels'), audioInfo.output.channels = str2num(l(strfind(l,'=')+1:end)); end;
	if strfind (l,'Supported standard sample rates (output, full-duplex'), output_sampleRates_fullDuplex = str2num(l(strfind(l,'=')+1:end)); end;
	if strfind (l,'Supported standard sample rates (output, half-duplex'), output_sampleRates_halfDuplex = str2num(l(strfind(l,'=')+1:end)); end;
	l = fgetl (fid);
end

if strcmp (audioInfo.input.name, audioInfo.output.name) % full-duplex operation
	audioInfo.input.sampleRates = input_sampleRates_fullDuplex;
	audioInfo.output.sampleRates = output_sampleRates_fullDuplex;
else % half-duplex operation
	audioInfo.input.sampleRates = input_sampleRates_halfDuplex;
	audioInfo.output.sampleRates = output_sampleRates_halfDuplex;
end

end
