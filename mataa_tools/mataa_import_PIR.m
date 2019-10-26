function [t,s,info] = mataa_import_PIR (file);

% function [t,s,info] = mataa_import_PIR (file);
%
% DESCRIPTION:
% Import time-domain data from a PIR file (binary ARTA data file).
%
% INPUT:
% file: string containing the name of the file containing the data to be imported. The string may contain a complete path. If no path is given, the file is assumed to be located in the current working directory.
% 
% OUTPUT:
% t: time values (s)
% s: signal amplitude values
% info: data information (as described in ARTA manual, see also m-file code in this file)
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
% Copyright (C) 2019 Matthias S. Brennwald.
% Contact: info@audioroot.net
% Further information: http://www.audioroot.net/MATAA
%
% HISTORY:
% 26. October 2019  (Matthias Brennwald): first version

warning ('mataa_import_PIR: this function is under development -- use with caution!')

if nargin == 0
	file = '';
end

if length (file) == 0
	error ('mataa_import_PIR: the file name must not be empty.');
end

t = [];
s = [];
info = [];

[fid,msg] = fopen (file);

if fid == -1
	error (sprintf ('mataa_import_PIR: %s (file: %s).',msg,file))
end

% read the header / file info
info.filesignature = char(fread(fid,4,"uchar")'); % file signature, should be PIR\0
if ~strcmp(info.filesignature,"PIR\0")
	error (sprintf ('mataa_import_PIR: incorrect file signature (file: %s).',file))
end

info.version          = fread(fid,1,"uint32"); % file format version
info.infosize         = fread(fid,1,"int32"); % length of user defined text at end of file
info.reserved1        = fread(fid,1,"int32");
info.reserved2        = fread(fid,1,"int32");
info.fskHz            = fread(fid,1,"float32"); % sample rate in kHz
info.samplerate       = fread(fid,1,"int32"); % sample rate in Hz
info.length           = fread(fid,1,"int32"); % length of signal (number of samples)
info.inputdevice      = fread(fid,1,"int32"); % 0: voltage probe, 1: mic, 2: accelerometer
info.devicesens       = fread(fid,1,"float32"); % V/V or V/Pa (mic input)
info.measurement_type = fread(fid,1,"int32"); % 0: signal recorded, external excitation / 1: IR, single channel correlation, 2: IR, dual channel IR
info.avgtype          = fread(fid,1,"int32"); % type of averaging (0: time, 1: freq)
info.numavg           = fread(fid,1,"int32"); % number of averages used in measurements
info.bfiltered        = fread(fid,1,"int32"); % forced antialiasing filtering in 2ch
info.gentype          = fread(fid,1,"int32"); % generator type
info.peakleft         = fread(fid,1,"float32"); % peak value (ref 1.0) in left input channel
info.peakright        = fread(fid,1,"float32"); % peak value (ref 1.0) in right input channel
info.gensubtype       = fread(fid,1,"int32"); % 0: male, 1: female for Speech PN ...
info.reserved3        = fread(fid,1,"float32");
info.reserved4        = fread(fid,1,"float32");

% read signal data:
s = fread(fid,info.length,"float32");

% read user defined infotext:
info.usertext         = char(fread(fid,info.infosize,"uchar"));

% clean up
fclose (fid);

% determine time values;
t = [0:info.length-1]'/info.fskHz/1000;
