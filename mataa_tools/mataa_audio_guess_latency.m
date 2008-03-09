function latency = mataa_audio_guess_latency(fs,maxLatency);

% function latency = mataa_audio_guess_latency(fs,maxLatency);
%
% DESCRIPTION:
% This function measures the latency of the audio hardware at sampling frequency fs, including the connected DUT.
%
% The latency is defined as follows:
% t1: the time needed by the audio output device to process the signal
% t2: the time needed by the signal to travel from the audio output to the audio input of the computer (this will be determined by the analytical setup. In case of loudspeaker analysis, t2 will be deteremined mainly by the distance between microphone and loudspeaker).
% t3: the time needed by the audio input device to process the signal
%
% Then: latency = t1 + t2 + t3
% 
% INPUT:
% fs: sampling frequency to be used for audio I/O (in seconds)
% maxLatency (optional): the expected maximum of the latency (in seconds). If not specified, the user will be asked to supply a value.
%
% OUTPUT:
% latency: the latency of the system, as defined above (in seconds)
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
% Copyright (C) 2006 Matthias S. Brennwald.
% Contact: info@audioroot.net
% Further information: http://www.audioroot.net/MATAA.html
%
% HISTORY:
% 8. November 2007 (Matthias Brennwald): improved documentation
% 4. Feb. 2007: removed unnecessary call to mataa_audio_info (Matthias Brennwald)
% first version: 9. July 2006, Matthias Brennwald

% a = mataa_audio_info;

if ~exist('maxLatency')
    maxLatency = input('Enter maximum expected latency (in ms):');
    maxLatency=maxLatency/1000;
end

t=[1/fs:1/fs:2*maxLatency]';
out=repmat(0,size(t));
k=round(length(out)/2);
out(k)=1;

testfile = mataa_signal_to_TestToneFile(out);
in = mataa_measure_signal_response(testfile,fs,0);

delete(testfile);

in = in(:,1); % discard second channel

% plot(t,in)

latency = mataa_guess_IR_start(in,t,0)-t(k);