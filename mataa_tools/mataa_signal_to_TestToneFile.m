function pathToFile = mataa_signal_to_TestToneFile (s,pathToFile,zeroTime,fs);

% function pathToFile = mataa_signal_to_TestToneFile (s,pathToFile,zeroTime,fs);
%
% DESCRIPTION:
% Saves the test signals in matrix s to a file on disk (for use with TestTone). Optionally, the signals are  padded with zeroes at the beginning and the end.
%
% INPUT:
% s: the signal samples (in the range of [-1..+1]). In general, s is a matrix with each column corresponding to one data channel, and each row corresponding to a signal frame (i.e. all samples corresponding to the same time step). For single-channel data (i.e. mono signals), s is a column vector. A warning will be printed if s has more columns than rows.
%
% pathToFile (optional): the path (including the file name) of the destination file. If not specified, a temporary file will be used. If you want to specify zeroTime and fs, but not pathToFile, use pathToFile = '';
%
% zeroTime (optional): duration of 'zero signal' to be padded to the beginning and the end of the signal (in seconds). If not specified, no zeros will be padded to the signal.
%
% fs (only if zeroTime is specified): the sample rate of the signal (in Hz). This is required to determine the number of 'zero samples'.
% 
% OUTPUT:
% pathToFile: the path (including the file name) of the file to which the data was written.
% 
% NOTE 1: TestTone assumes that all information regarding the sample rate / time interval in between the samples is handled appropriately. mataa_signal_to_TestToneFile therefore does NOT handle any sample timing information. Only the sample VALUES are written to disk.
%
% NOTE 2: the data in s should be padded with zeros at the beginning and the end of the signal to avoid problems with sound-I/O latency. If s does not include zeros at the beginning and the end, use the zeroTime option.
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
% Copyright (C) 2006, 2007, 2008 Matthias S. Brennwald.
% Contact: info@audioroot.net
% Further information: http://www.audioroot.net/MATAA.html

% check format of input data:
nFrames = size(s,1);
nChannels = size(s,2);
if nFrames < nChannels
    warning('mataa_signal_to_TestToneFile: the test-signal data contains more channels than frames. Is this intended? Or has the input data been transposed by accident?')
end

if ~exist('pathToFile','var')
    pathToFile = '';
end

if strcmp(pathToFile,'')
    pathToFile = mataa_tempfile;
end

if exist('zeroTime','var')
    if ~exist('fs','var')
        error('mataa_signal_to_TestToneFile: need fs to determine number of zeros to be padded the the signal')
    end
    n = zeroTime*fs;
    z = repmat(0,n,nChannels);
    s = [ z ; s ; z ];
end

% open the file for writing:
fid = fopen(pathToFile,'wt');
if fid == -1
    error('mataa_signal_to_TestToneFile: could not open file for writing data.');
end

% write the data to the file:
format = '';
for i=1:nChannels
    if i > 1
        format = sprintf('%s , ',format); % add a comma
    end
    format = sprintf('%s %%0.24g',format);
end
format = sprintf('%s\n',format); % add newline character

fprintf(fid,format,s');

% close the file:
if fclose(fid) == -1
    error('mataa_signal_to_TestToneFile: could not close file after writing data.');
end
