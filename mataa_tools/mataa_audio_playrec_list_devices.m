function [dev_names, dev_IDs] = mataa_audio_playrec_list_devices ();

% function [dev_names, dev_IDs] = mataa_audio_playrec_list_devices ();
%
% DESCRIPTION:
% Return IDs and names of all audio devices that are available with PlayRec
%
% INPUT:
% (none)
%
% OUTPUT:
% dev_names: names / labels of the audio devices (cell string)
% dev_IDs: PlayRec IDs of the audio devices (vector)
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

dev_names = {};
dev_IDs = [];

if ~exist('playrec')
	warning ('mataa_audio_playrec_list_devices: PlayRec is not available. Please see the MATAA manual for instructions on how to install PlayRec.')
else
	d = playrec('getDevices');
	for k = 1:length(d)
		dev_names{end+1} = undo_string_escapes (d(k).name);
		dev_IDs          = [ dev_IDs ; d(k).deviceID ];
	end
end
