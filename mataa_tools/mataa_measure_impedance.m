function [Zmag,Zphase,f] = mataa_measure_impedance(fLow,fHigh,R,fs,resolution);

% function [Z,f] = mataa_measure_impedance(fLow,fHigh,R,fs,resolution);
%
% DESCRIPTION:
% Measures the complex, frequency-dependent impedance Z(f) in the frequency range [fLow,fHigh].
% The measurement relies on the setup described in the MATAA manual.
%
% INPUT:
% fLow: lower limit of the frequency range (Hz)
% fHigh: upper limit of the frequency range (Hz)
% R: resistance of the reference resistor (Ohm)
% fs (optional): sampling frequency to be used for sound I/O. If not value is given, the lowest possible sampling frequency will be used.
% resolution (optional): frequency resolution in octaves (example: resolution = 1/24 will give 1/24 octave smoothing). Default is resolution = 1/48. If you want no smoothing at all, use resolution = 0.
% 
% OUTPUT:
% Z: vector of complex impedance values (Ohm)
% f: vector of frequency values
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
% 25. November 2007 (Matthias Brennwald): added compensation for interchannel delay (interchannel delay is taken from the MATAA settings). Improved MATLAB compatibility (replaced function call 'arg' by 'angle').
% 8. November 2007 (Matthias Brennwald): use sample rate (scalar) rather than all time values (vector) for conversion from time domain to frequency domain. This avoids problems with slight time variations if the timing is not accurate (this can be a problem especially with long test signals, and might also depend on the sound hardware).
% 4. Feb: adapted to work with new TestDevices program (change from Portaudio-18 to Portaudio-19).
% first version: 12. Aug. 2006, Matthias Brennwald

if ~exist('fs')
    fs = [];
end

if ~exist('resolution')
    resolution = [];
end

if isempty(fs)
    info = mataa_audio_info;
    if exist('intersect')==3
        % find rates that are supported both by input and output
        rates = intersect(info.input.sampleRates,info.output.sampleRates);
    else
        % assume the sampling rates available for input and output are the same
        rates = info.input.sampleRates ;
    end
    fs = min(rates(find(rates > 2*fHigh)));
end

if isempty(resolution)
    resolution = 1/48;
end

% setup test signal:
T = max(1/fLow,log2(fHigh/fLow)/2); % set length of test signal (seconds)
s = mataa_signal_generator('sweep',fs,T,[fLow fHigh]);

% play the test signal and record the response signals:
[response,original] = mataa_measure_signal_response(s,fs,0.1); % play the test signal and record the response signals
U_A = response(:,mataa_settings('channel_DUT'));    % extract U_A from the measured data
U_B = response(:,mataa_settings('channel_REF'));    % extract U_B from the measured data

% apply fourier transforms
[U_A,f] = mataa_realFT(U_A,fs);
[U_B,f] = mataa_realFT(U_B,fs);

% remove interchannel delay:
delay = mataa_settings('interchannel_delay');
phi = delay*2*pi*f;
U_A = exp (-i*phi) .* U_A; % remove the excess phase in U_A due to interchannel delay

Z = R * U_A ./ (U_B - U_A);

% remove data outside frequency range of test signal:
index = find( f<= fHigh & f >= fLow );
f = f(index);
Z = Z(index);

% smooth data:
if resolution > 0
    [Z,f] = mataa_smooth_log(Z,f,resolution);
end

Zmag = abs(Z);
Zphase = angle(Z)/pi*180;