% Use this script for analysis of harmonic distortion of an amplifier or similar DUT.
% Measure harmonic distortion spectra and THD as a function (i) of output voltage and (ii) of the frequency of the fundamental.
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


warning('This script is just a draft / work in progress!')


% sample rate:
if ~exist('fs','var')
	fs = input ('Enter sampling rate (Hz, default = 44100): ');
end
if isempty(fs)
	fs = 44100;
end
disp (sprintf('Sampling rate fs = %g Hz',fs))

% test signal length:
if ~exist('T','var')
	T= input ('Test signal length (seconds, default = 1 s): ');
end
if isempty(T)
	T = 1.0;
end
disp (sprintf('Test signal length T = %g s',T))

% DUT Output voltage steps:
if ~exist('U0rms_start','var')
	U0rms_start = input ('DUT output voltage, start value (V-RMS, default = 0.1): ');
end
if isempty(U0rms_start)
	U0rms_start = 0.1;
end
if ~exist('U0rms_end','var')
	U0rms_end = input ('DUT output voltage, end value (V-RMS, default = 10): ');
end
if isempty(U0rms_end)
	U0rms_end = 10;
end

if U0rms_start ~= U0rms_end
	if ~exist('N_U0','var')
		N_U0 = max([1, round(input('Number of voltage steps (default = 5): '))]);
	end
	if isempty(N_U0)
		N_U0 = 5;
	end
else
	N_U0 = 1;
end
V_out_RMS = logspace(log10(U0rms_start),log10(U0rms_end),N_U0);
u = sprintf('%.3f, ',V_out_RMS);
disp(['DUT output voltage target values (V-RMS): ', u(1:end-2)])

% Fundamental frequency steps:
if ~exist('f0_start','var')
	f0_start = input ('Fundamental frequency, start value (Hz, default = 100): ');
end
if isempty(f0_start)
	f0_start = 100;
end
if ~exist('f0_end','var')
	f0_end = input ('Fundamental frequency, end value (Hz, default = 10000): ');
end
if isempty(f0_end)
	f0_end = 10000;
end
if f0_start ~= f0_end
	if ~exist('N_f0','var')
		N_f0 = max([1, input('Number of fundamental steps (default = 5): ')]);
	end
	if isempty(N_f0)
		N_f0 = 5;
	end
else
	N_f0 = 1;
end
f0 = linspace(f0_start,f0_end,N_f0);
u = sprintf('%.1f, ',f0);
disp(['Fundamental frequency values (Hz): ', u(1:end-2)])

% number of harmonics to include in the analysis
if ~exist('N_h','var')
	N_h = input('Number of harmonics to include in the analysis (default = 5): ');
end
if isempty(N_h)
	N_h = 5;
end
if N_h < 2
	N_h = 2;
end
disp(sprintf('Number of harmonics included in the analysis: %i', N_h))

% frequency bandwith of analysis:
if ~exist('fLow','var')
	fLow = max([0, input('Low-frequency limit of HD analysis (Hz, default = 0): ')]);
end
if isempty(fLow)
	fLow = 0;
end
if fLow < 0
	fLow = 0;
end
if ~exist('fHigh','var')
	fHigh = input(sprintf('High-frequency limit of HD analysis (Hz, default = %g): ',fs/2));
end
if isempty(fHigh)
	fHigh = fs/2;
end
if fHigh > fs/2
	fHigh = fs/2;
end
disp(sprintf('Analysis bandwidth: %g -- %g Hz', fLow, fHigh))

% number of averages:
if ~exist('N_avg','var')
	N_avg = max([1, input('Number of averages per measurement step (default = 1): ')]);
end
if isempty(N_avg)
	N_avg = 1;
end
disp(sprintf('Number of averages per measurement: %i', N_avg))

% DUT label:
if ~exist('DUT_label','var')
	DUT_label = input ('Name / label of the DUT setup (default = UNKNOWN): ', 's');
end
if isempty(DUT_label)
	DUT_label = 'UNKNOWN';
end
disp (sprintf('DUT label: %s',DUT_label))

% DUT voltage gain (approx. estimate):
if ~exist('gain_ini','var')
	gain_ini = input ('DUT voltage gain (approximate value, default = 10): ');
end
if isempty(gain_ini)
	gain_ini = 10;
end
disp (sprintf('DUT voltage gain (approx. initial value) gain = %g (%g dB)',gain_ini,20*log10(gain_ini)))

% Save graphics:
if ~exist('do_save_plots','var')
	do_save_plots = upper(input(sprintf('Save data plots to PDF files in current working directory %s (Y/N, default = N): ', pwd),'s'));
	if ~strcmp(do_save_plots,'Y')
		do_save_plots = 'N';
	end
	if strcmp(do_save_plots,'Y')
		do_save_plots = true;
	else
		do_save_plots = false;
	end
end
if do_save_plots
	disp (sprintf('Saving PDF plots in %s.',pwd))
else
	disp ('Not saving PDF plots.')
end

% Calibration file:
if ~exist('cal','var')
	if ~exist('calfile','var')
		calfile = uigetfile ('*', 'Choose Audio I/O calibration file', mataa_path('calibration'));
	end
	cal = mataa_load_calibration (calfile);
end
disp (sprintf('Audio I/O calibration file: %s',calfile))

% set audio I/O things:
latency = 0.1; % latency for audio I/O
unit    = 'V';
window  = 'hann';

% prepare figures:
if ~exist('fig_spectrum','var')
	fig_spectrum = figure(); clf;
end

% determine DUT voltage gain:
if ~exist('gain','var')
	Vx_RMS = median(V_out_RMS); % target DUT output voltage to determine the gain
	Vx_out_pk = Vx_RMS*sqrt(2) / gain_ini; % DUT input voltage
	[L,f,fi,L0,unit] = mataa_measure_sine_distortion (f0,T,fs,latency,cal,Vx_out_pk,unit,window);
	gain = L0 / Vx_out_pk
end
disp(sprintf('* DUT voltage gain = %g (%g dB)', gain, 20*log10(gain)))

% Run measurements at specified voltages and fundamental frequencies:
for VV_RMS = V_out_RMS
	for ff = f0
					
		[HD,fHD,THD,THDN,L,f,unit] = mataa_measure_HD_noise ( ff,T,fs,N_h,latency,cal,VV_RMS*sqrt(2)/gain,unit,window,fLow,fHigh,N_avg );
		
		% plot data:
		figure(fig_spectrum)
		y = L(:,1) / sqrt(2); % RMS voltage values
		semilogy (f, y, 'r', 'linewidth', 4 );
		xlim ( [ 0 fs/2 ] )
		ylim ( [ 0.1*floor(min(y)/10) 10*ceil(min(y)/10) ] );
		xlabel ('Frequency (Hz)');
		ylabel(sprintf('Amplitude (%s-RMS)',unit));
		grid on;
		title ( sprintf("%s\n%g V-RMS, %g Hz",DUT_label,VV_RMS,ff));
		
		if do_save_plots
			print ("-S650,400",sprintf("%s_%gVRMS_%gHz_SINE_SPECTRUM.pdf",DUT_label,VV_RMS,ff))
		end
	end
end


bang here!


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

