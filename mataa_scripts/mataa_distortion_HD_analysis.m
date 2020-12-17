function distortion_HD_analysis (amp_label,R_load,P_out,cal)

% distortion_HD_analysis (amp_label,R_load,P_out,cal)
%
% DESCRIPTION:
% Harmonic distortion analysis of power amplifier.
% - Measure sine spectrum at specified power / load
% - Measure THD vs frequency at specified power / load
% - plot results and save plots
%
% INPUT:
% amp_label: label to use in plot titles and filenames
% R_load: load resistance (Ohm)
% P_out: target output power (W)
% cal: calibration file (see mataa_load_calibration)
% 
% INPUT:
% (none)
%
% EXAMPLE:
% > mataa_distortion_HD_analysis ('USSA5',8.2,1,'MB_ELECTRONIC_CHAIN_SEout.txt')
%
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
% 
% Copyright (C) 2020 Matthias S. Brennwald.
% Contact: info@audioroot.net
% Further information: http://www.audioroot.net/MATAA.html

load_name = sprintf('%i Ohm', R_load)

V_out_target = sqrt( R_load * P_out ) % RMS voltage of output signal at which the test should be carried out

fs = 44100; % sampling rate
T = 131072 / fs; % length of test signal (seconds)
latency = 0.3; % latency for audio I/O
f0 = 1017.0; % frequency of test signal (sine)
amplitude = 0.17 * V_out_target; % estimated starting value (try to get this right from the beginning to avoid trouble with the level switch)
unit = 'V';
window = 'hann';

% perform first measurement with sine test signal (to determine level):
[L,f,fi,L0,unit] = mataa_measure_sine_distortion (f0,T,fs,latency,cal,amplitude,unit,window);

% determine signal attenuation to obtain target RMS output voltage:
L0 = L0 / sqrt(2)
amplitude = V_out_target / L0 * amplitude;

% repeat measurement at correct level:
% [L,f,fi,L0,unit] = mataa_measure_sine_distortion ([f0 f0+300],T,fs,latency,cal,amplitude,unit,window);
[L,f,fi,L0,unit] = mataa_measure_sine_distortion (f0,T,fs,latency,cal,amplitude,unit,window);
L0 / sqrt(2)

% plot spectrum
semilogy (f,L(:,1)*sqrt(0.5),'r' , 'linewidth',4 );
xlabel ('Frequency (Hz)'); ylabel(sprintf('Amplitude (%s-RMS)',unit));
axis([25 1E4 1E-7 100]); grid on;
title ( sprintf("%s (%gW into %s load)",amp_label,P_out,load_name));

% save plot to file:
print ("-S650,400",sprintf("%s_%gW_%s_SINE_SPECTRUM.pdf",amp_label,P_out,load_name))



% Measure THD vs frequency:
N = 25;
fLow = 100;
fHigh = 20e3;
ff = logspace(log10(fLow),log10(fHigh),N);
THD = repmat(NA,size(ff));
fs = [ 44100 96000 192000 ]; N_h = 4;
latency = 0.45;
for k = 1:N
	l = find (fs > ff(k)*2*N_h);
	if any(l)
		[HD,fHD,THD(k),THDN,L,f,unit] = mataa_measure_HD_noise ( ff(k),T,fs(l(1)),N_h,latency,cal,amplitude,unit,window );
	end
end

% plot THD vs frequency
loglog (ff,THD*100,'r.-' , 'linewidth',4 , 'markersize',10 );
xlabel ('Frequency (Hz)'); ylabel ("THD (%)");
axis([fLow fHigh 1E-4 100]); grid on;
title ( sprintf("%s (%gW into %s load)",amp_label,P_out,load_name));

% save plot to file:
print ("-S650,400",sprintf("%s_%gW_%s_THD_vs_frequency.pdf",amp_label,P_out,load_name))

