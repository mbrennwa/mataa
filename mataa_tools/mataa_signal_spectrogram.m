function [m,t,f] = mataa_signal_spectrogram (s,t,dt,smooth);

% function [m,t,f] = mataa_signal_spectrogram (s,t,dt,smooth);
%
% DESCRIPTION:
% Calculate spectrogram (aka sonogram) of the signal s(t).
%
% INPUT:
% s: vector containing the samples values of the signal.
% t: time values of samples in h (vector, in seconds) or sampling rate of h (scalar, in Hz)
% dt: width time chunks used to calculate of spectrogram lines
% smooth (optional): if specified, the data is smoothed in the frequency domain over the octave interval smooth_interval.
% 
% OUTPUT:
% m: magnitude values in dB (matrix)
% t: time values
% f: frequency values
%
% EXAMPLE:
% fs = 44100; L = 3;
% [s1,t] = mataa_signal_generator ("sweep_lin",fs,L,[1000 20000]);
% s2     = mataa_signal_generator ("sweep_log",fs,L,[1000 20000]);
% s3     = s1+s2;
% [M1,T1,F1] = mataa_signal_spectrogram (s1,t,0.05);
% [M2,T2,F2] = mataa_signal_spectrogram (s2,t,0.05);
% [M3,T3,F3] = mataa_signal_spectrogram (s3,t,0.05);
% subplot (3,1,1); surf (T1,F1/1000,M1); shading interp; view (0,90); ylabel ('Frequency (kHz)');
% subplot (3,1,2); surf (T2,F2/1000,M2); shading interp; view (0,90); ylabel ('Frequency (kHz)');
% subplot (3,1,3); surf (T3,F3/1000,M3); shading interp; view (0,90); xlabel ('Time (s)'); ylabel ('Frequency (kHz)');
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
% Copyright (C) 2014 Matthias S. Brennwald.
% Contact: info@audioroot.net
% Further information: http://www.audioroot.net/MATAA.html

if isscalar(t)
    fs = t;
    t = [0:1/fs:(length(s)-1)/fs];
else
    fs = (length(t)-1)/(max(t)-min(t));
    t  = t-t(1); % shift impulse response to zero-based time
end

% make sure we've got column vectors:
s = s(:);
t = t(:);

T  = t(end) + 1/fs; % total length of signal
tt = [0:dt:T]; % time bins
nt = ceil ( length (t) / (length(tt)-1) ) ; % number of samples per signal chunk

nf = floor (nt/2); % number of frequency values in each spectrogram line

m = [];
for i = 1:length(tt)-1
    j = find ( t >= tt(i)  &  t < tt(i+1) );
    x = s(j); x = x(:);
    x = detrend (x); 
    x = mataa_signal_window (x,'hann');
    if length(x) < nt % pad zeros
        x = [ x ; repmat(0,nt-length(x),1) ];
    end
    x = x(1:nt); % in case there's one too many
        
    if exist ('smooth','var')
	    [M,u,f] = mataa_IR_to_FR (x,fs,smooth);
	    
	else
	    [M,u,f] = mataa_IR_to_FR (x,fs);
	end
	m = [ m M ];
end

t = ( tt(1:end-1) + tt(2:end) ) / 2;