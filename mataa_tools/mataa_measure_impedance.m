function [Zmag,Zphase,f] = mataa_measure_impedance (fLow,fHigh,R,fs,resolution);

% function [Zmag,Zphase,f] = mataa_measure_impedance (fLow,fHigh,R,fs,resolution);
%
% DESCRIPTION:
% This function measures the complex, frequency-dependent impedance Z(f) of a DUT using a swept sine signal ranging from fLow to fHigh. Note the fade-in and fade-out of the test signal results in a loss of precision at the frequency extremes, which may be compensated by using a slightly larger frequency range.
%
% The measurement relies on the following set up:
%
%	DAC-out -------+---------> ADC-in (REF)
%		       |
%		       R
%		       |
%		       +---------> ADC-in (DUT)
%		       |
%		      DUT
%		       |
%	DAC-GND -------+---------> ADC-GND
%
% Note that the current flowing through the reference resistor R is identical to the current flowing through the DUT at all times. This allows calculating the impedance of the DUT using Ohm's Law with the voltages observed at the ADC inputs of the REF and DUT channels. 
%
% INPUT:
% fLow: lower limit of the frequency range (Hz)
% fHigh: upper limit of the frequency range (Hz)
% R: resistance of the reference resistor (Ohm)
% fs (optional): sampling frequency to be used for sound I/O. If not value is given, the lowest possible sampling frequency will be used.
% resolution (optional): frequency resolution in octaves (example: resolution = 1/24 will give 1/24 octave smoothing). Default is resolution = 1/48. If you want no smoothing at all, use resolution = 0.
% 
% OUTPUT:
% Zabs: impedance magnitude (Ohm)
% Zphase: impedance phase (degrees)
% f: vector of frequency values
%
% EXAMPLE:
% [Zmag,Zphase,f] = mataa_measure_impedance (10,20000,8.2,44100);
% semilogx (f,Zmag); xlabel ('Frequency (Hz)'); ylabel ('Impedance (Ohm)')
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

if ~exist('fs','var')
    fs = [];
end

if ~exist('resolution','var')
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
s = mataa_signal_generator('sweep_smooth',fs,T,[fLow fHigh]);

% play the test signal and record the response signals:
channels = [ mataa_settings('channel_DUT') mataa_settings('channel_REF') ];
[response,original] = mataa_measure_signal_response([s s],fs,0.1,1,channels); % play the test signal and record the response signals
U_A = response(:,1);    % extract U_A from the measured data
U_B = response(:,2);    % extract U_B from the measured data

% apply fourier transforms
[U_A,f] = mataa_realFT(U_A,fs);
[U_B,f] = mataa_realFT(U_B,fs);

% remove interchannel delay:
delay = mataa_settings('interchannel_delay');
if delay ~= 0
	phi = delay*2*pi*f;
	U_A = exp (-i*phi) .* U_A; % remove the excess phase in U_A due to interchannel delay
end

% calculate impedance for REF and DUT voltages using Ohm's Law:
Z = R * U_A ./ (U_B - U_A);

% remove data outside frequency range of test signal:
index = find( f<= fHigh & f >= fLow );
f = f(index);
Z = Z(index);

Zmag = abs(Z);
Zphase = angle(Z)/pi*180;

if resolution > 0 % smooth data:
    % [Z,f] = mataa_smooth_log(Z,f,resolution);
	[Zmag,Zphase,f] = mataa_FR_smooth (Zmag,Zphase,f,resolution);
end

