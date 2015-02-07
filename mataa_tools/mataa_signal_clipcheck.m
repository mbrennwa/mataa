function n = mataa_signal_clipcheck (s,N);

% function n = mataa_signal_clipcheck (s,N);
%
% DESCRIPTION:
% Returns the number of samples with amplitude less than N percent% lower than the maximum amplitude of the signal (absolute values).
% 
% INPUT:
% s: vector of signal samples
% N (optional): percentage of deviation from maximum amplitude. Default value is N = 1 (i.e. 1%).
% 
% OUTPUT:
% n: number of samples with amplitude less than 1% lower than the maximum amplitude of the signal (absolute values).
% 
% EXAMPLES:
% * White-noise signal (not clipped):
% > wn = mataa_signal_generator('pink',1000,1); % a white-noise signal with 1000 samples (with sample ranges distributed in the range between -1...+1).
% > n = mataa_signal_clipcheck(wn,0.1); % find number of samples with (absolute) amplitudes that are within 0.1% of the maximum (absolute) amplitude. This will result in a low value of n (i.e. n=1, 2, or 3, but higher values are unlikely).
%
% * Clipped white-noise signal:
% > wn = 2.5*mataa_signal_generator('pink',1000,1); % a white-noise signal with 1000 samples (with sample ranges distributed in the range between -2.5...+2.5).
% > wn(wn > 1) = 1; wn(wn < -1) = -1; % fake clipping, i.e. truncate the samples to the range (-1...+1).
% > n = mataa_signal_clipcheck(wn,0.1); % find number of samples with (absolute) amplitudes that are within 0.1% of the maximum (absolute) amplitude. This will result in a much higher value of n than in the previous example (n ~ 200).
%
% * Square-wave signal:
% > sq = mataa_signal_generator('square',10000,0.1,1000); % a square wave signal with 1000 samples (i.e. a signal with sample values of either +1 or -1).
% > n = mataa_signal_clipcheck(sq,0.01); % find number of samples with (absolute) amplitudes that are within 0.01% of the maximum (absolute) amplitude. This results in n=1000, because the amplitude of all samples is equal to 1.
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
% Copyright (C) 2007, 2008 Matthias S. Brennwald.
% Contact: info@audioroot.net
% Further information: http://www.audioroot.net/MATAA

x = size(s);
if x(1) < x(2)
    s = s';
    x = size(s);
end

s = abs(s);

n_chan = x(2);
n_samp = x(1);

n = repmat(NaN,1,n_chan);

for chan=1:n_chan
    if ~any(s(:,chan))
        % signal is all zero
        n(chan) = 0;
    else
        m = max(s(:,chan));
        i = find(abs(s(:,chan) - m)/m < 0.01);
        n(chan) = length(i);
    end
end



