function [THD,kn,l0DUT,l0REF] = mataa_measure_HD (f1,T,fs,N);

% function [THD,kn,l0DUT,l0REF] = mataa_measure_HD (f1,T,fs,N);
%
% DESCRIPTION:
% This function measures harmonic distortion using a sine wave with a given frequency.
% 
% INPUT:
% f1: base frequency in Hz.
% T: sine-signal length in seconds.
% fs: sampling frequency in Hz
% N (optional): number of harmonics to be analyzed. By default, N=12 is assumed.
% 
% OUTPUT:
% THD = total harmonic distortion, see below.
% kn: harmonic distortion spectrum, in voltage units (not power). kn is a vector containing the harmonic components (k1, k2, k3, ... kN), where k1 corresponds to f1. The spectrum is normalised such that k1 is equal to one.
% f1: true value of f1 used for analyses (value may be adjusted slightly to fit in the resolution of the fourier spectrum).
% l0DUT, l0REF: RMS level of the DUT and REF signals at the soundcard input (useful for repeated tests at different levels)
%
% NOTE 1: THD is computed WITHOUT the noise in the spectrum ranges between the harmoics.
%
% NOTE 2: There exist different definitions of THD (see e.g. http://en.wikipedia.org/wiki/THD and the external links cited there for some of these definitions). Here, the following definition is used:
% THD = sqrt( k2^2 + k3^2 + ... + kN^2 ) / k1
% 
% NOTE 3: THD is returned in relative units, not percentage or dB. For instance, THD = 0.02 corresponds to 2% THD.
% 
% NOTE 4: Only the harmonic components up to kN are analysed. Signal components in between the harmonic components (noise, hum, etc.) are NOT included in THD. The result is therefore NOT THD + noise !
%
% EXAMPLE:
% > [thd,k] = mataa_measure_HD(1000,1,96000); % measure THD and harmonic power distortion spectrum for a base-frequency of 1 kHz.
% > mataa_plot_HD(k,'f1: 1kHz'); % plot the distortion spectrum
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
% Further information: http://www.audioroot.net/MATAA

if ~exist('N','var')
    N = 12;
end

if f1<=0, error('f1 must be > 0'), end;

dt = 1/fs;
n = round(T/dt);
t = [0:n-1]*dt; t = t(:);

f = mataa_t_to_f(t); df = f(1);

[v,i] = min(abs(f-f1));
if f(i)~=f1
    f1 = f(i);
    warning('mataa_measure_HD: adjusted f1 to nearest value resolved.');
end;

x = sin(2*pi*f1*t);

%z = repmat(0,round(0.1*fs),1);

%x = [ z ; x ; z ];

[out,in] = mataa_measure_signal_response(x,fs);

yDUT=out(:,mataa_settings('channel_DUT'));
yREF=out(:,mataa_settings('channel_REF'));

% figure(20)
% plot(yDUT(15000:17000))
% axis

% remove the zero padding and make the remaining signal length equal to length(t):
i = find(abs(yREF) > 0.2*max(abs(yREF)));
i1=min(i); i2=max(i);
i1=round((i1+i2)/2 - length(t)/2); i2=i1+length(t)-1;
yDUT = yDUT(i1:i2);
yREF = yREF(i1:i2);

% window the signal to minimize frequency leakage
w = sin(pi*t/max(t)).^2;
yDUT = yDUT.*w;
yREF = yREF.*w;

% pre-normalize signals by their RMS value
l0DUT = sqrt (sum(yDUT.^2)) / length (yDUT); yDUT = yDUT / l0DUT;
l0REF = sqrt (sum(yREF.^2)) / length (yREF); yREF = yREF / l0REF;

% calculate signal spectra (voltages!)
[YDUT,f] = mataa_realFT(yDUT,t);
[YREF,f] = mataa_realFT(yREF,t);

% discard phase information
YDUT = abs(YDUT);
YREF = abs(YREF);

% normalize the spectra
n=[1:N]*find(f==f1);
YDUT = YDUT/YDUT(n(1));
YREF = YREF/YREF(n(1));

% subtract YREF from YDUT to remove artifacts of sound card on DUT signal:
YDUT = YDUT - YREF;

kn=repmat(NaN,length(n),1);
i = find(n<=length(YDUT));
n = n(i);
kn(1:length(n)) = YDUT(n);

kn(1) = 1; % that's zero otherwise, because YREF was subtracted from YDUT

i = find(kn < 0);
if any(i)
    warning('mataa_measure_HD: some signal harmonics are negative. Is the REF signal clipped or otherwise corrupted? Too much noise?');
end

THD = sqrt( sum( kn(2:end).^2 ) ) / kn(1);
