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

% test signal length:
if ~exist('T','var')
	T= input ('Test signal length (seconds, default = 1 s): ');
end
if isempty(T)
	T = 1.0;
end

% output target: power or voltage level?
if ~exist('P_or_V','var')
	P_or_V = upper ([ input('Specify output levels in terms of voltage or power (enter V or P, default = P): ','s') ' '])(1);
end
if ~any(strfind('PV',P_or_V))
	P_or_V = 'P';
end

% DUT Output steps (power or voltage):
if strcmp(P_or_V,'P')
	tgt = 'power';
	tgt_unit = 'W-RMS';
else
	tgt = 'voltage';
	tgt_unit = 'V-RMS';
end

if ~exist('OUTrms_start','var')
	OUTrms_start = input (sprintf('DUT output %s, start value (%s, default = 0.1): ',tgt,tgt_unit));
end
if isempty(OUTrms_start)
	OUTrms_start = 0.1;
end
if ~exist('OUTrms_end','var')
	OUTrms_end = input (sprintf('DUT output %s, end value (%s, default = 10): ',tgt,tgt_unit));
end
if isempty(OUTrms_end)
	OUTrms_end = 10;
end
if OUTrms_end ~= OUTrms_start
	if ~exist('N_OUTLEVELS','var')
		N_OUTLEVELS = input(sprintf('Number of %s steps (default = 5): ',tgt));
	end
	if isempty(N_OUTLEVELS)
		N_OUTLEVELS = 5;
	end
else
	N_OUTLEVELS = 1;
end

% Power or voltage values:
V_out_RMS = logspace(log10(OUTrms_start),log10(OUTrms_end),N_OUTLEVELS);

if strcmp(P_or_V,'P')
	% load resistance:
	if ~exist('R_load','var')
		R_load = input ('Load resistance (Ohm, default = 8): ');
	end
	if isempty(R_load)
		R_load = 8.0;
	end
	% re-determine voltage levels:
	V_out_RMS = sqrt(V_out_RMS * R_load);
end

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
		N_f0 = input('Number of fundamental steps (default = 5): ');
	end
	if isempty(N_f0)
		N_f0 = 5;
	end
else
	N_f0 = 1;
end
f0 = logspace(log10(f0_start),log10(f0_end),N_f0);

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

% minimum upper frequency limit:
fmin = max(f0)*N_h;

% determine suggested sampling rate:
u = mataa_audio_info();
fs_x = intersect (u.input.sampleRates,u.output.sampleRates);
fs_def = fs_x(find(fs_x/2 > fmin));
if isempty(fs_def)
	fs_def = max(fs_x);
else
	fs_def = min(fs_def);
end

% sample rate:
if ~exist('fs','var')
	fs = input (sprintf('Enter sampling rate (Hz, default = %g): ',fs_def));
end
if isempty(fs)
	fs = fs_def;
end
if fs <= fmin
	warning(sprintf('mataa_electronic_HD_analysis: sampling rate (%g per second) is too low to capture all harmonics!',fs))
end

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
	fHigh = input(sprintf('High-frequency limit of HD analysis (Hz, default = %g): ',fmin));
end
if isempty(fHigh)
	fHigh = fs/2;
end
if fLow > fHigh
	u = fHigh;
	fHigh = fLow;
	fLow = u;
end
if fHigh > fs/2
	fHigh = fs/2;
end
if fHigh < fmin
	warning(sprintf('mataa_electronic_HD_analysis: upper limit of analysis bandwith (%g Hz) is too low to capture all harmonics!',fHigh))
end

% number of averages:
if ~exist('N_avg','var')
	N_avg = max([1, input('Number of averages per measurement step (default = 1): ')]);
end
if isempty(N_avg)
	N_avg = 1;
end

% DUT label:
if ~exist('DUT_label','var')
	DUT_label = input ('Name / label of the DUT setup (default = UNKNOWN): ', 's');
end
if isempty(DUT_label)
	DUT_label = 'UNKNOWN';
end

% DUT voltage gain (approx. estimate):
if exist('gain','var')
	gain_ini = gain; % use gain value from last run
end
if ~exist('gain_ini','var')
	gain_ini = input ('DUT voltage gain (approximate value, default = 10): ');
end
if isempty(gain_ini)
	gain_ini = 10;
end

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

% Calibration file:
if ~exist('cal','var')
	if ~exist('calfile','var')
		calfile = uigetfile ('*', 'Choose Audio I/O calibration file', mataa_path('calibration'));
	end
	cal = mataa_load_calibration (calfile);
end

% set audio I/O things:
latency = 0.1 * max([1 fs/44100]); % latency for audio I/O
unit    = 'V';
window  = 'hann';

% adjust f0 values to match FFT bins
t = [0:round(T*fs)-1]/fs;
for i = 1:length(f0)	
	ff = mataa_t_to_f(t(:));
	[v,k] = min(abs(ff-f0(i)));
	if v > 1E-10
		f0(i) = ff(k);
	end
end
f0 = unique(f0);
N_f0 = length(f0);

disp('')
disp('Test configuration:')
disp(sprintf('- Sampling rate fs = %g Hz',fs))
disp(sprintf('- Test signal length T = %g s',T))
disp(['- DUT output voltage target values (V-RMS): ', sprintf('%.3f, ',V_out_RMS)(1:end-2)])
disp(['- Fundamental frequency values (Hz): ', sprintf('%.1f, ',f0)(1:end-2)])
disp(sprintf('- Number of harmonics included in the analysis: %i', N_h))
disp(sprintf('- Analysis bandwidth: %g to %g Hz', fLow, fHigh))
disp(sprintf('- Number of averages per measurement: %i', N_avg))
disp(sprintf('- DUT label: %s',DUT_label))
disp(sprintf('- DUT voltage gain (approx. initial value) gain = %g (%g dB)',gain_ini,20*log10(gain_ini)))
if do_save_plots
	disp (sprintf('- Saving PDF plots in %s.',pwd))
else
	disp ('- Not saving PDF plots.')
end
disp (sprintf('- Audio I/O calibration file: %s',calfile))

disp('')
input('Press ENTER to start the test...','s');

% prepare spectrum figure:
lw = 4;
if ~exist('fig_spectrum','var')
	fig_spectrum = figure(); clf;
end
figure(fig_spectrum)
			
% determine DUT voltage gain:
disp('')
fg = f0(round(length(f0)/2));
disp(sprintf('Measuring DUT voltage gain at %g Hz...',fg))
Vx_RMS = median(V_out_RMS); % target DUT output voltage to determine the gain
Vx_out_pk = Vx_RMS*sqrt(2) / gain_ini; % DUT input voltage
[L,f,fi,L0,unit] = mataa_measure_sine_distortion (fg,T,fs,latency,cal,Vx_out_pk,unit,window);
gain = L0 / Vx_out_pk;
disp(sprintf('DUT voltage gain = %g (%g dB)', gain, 20*log10(gain)))

% Run measurements at specified voltages and fundamental frequencies:
THD = repmat(NA,length(V_out_RMS),length(f0));
for i = 1:length(V_out_RMS)
	u = [];
	for j = 1:length(f0)
		
		DAC_out_VRMS = V_out_RMS(i) / gain;
		
		disp('')
		disp (sprintf('Testing: DAC output = %g Hz at %g VRMS...', f0(j), DAC_out_VRMS))
		
		try
			[hd,f_hd,thd,thdn,L,f,unit] = mataa_measure_HD_noise ( f0(j),T,fs,N_h,latency,cal,DAC_out_VRMS*sqrt(2),unit,window,fLow,fHigh,N_avg );
						
			% store THD result:
			THD(i,j) = thd;
			
			% plot spectrum:
			y = L(:,1) / sqrt(2); % RMS voltage values
			semilogy (f, y, 'r', 'linewidth', lw );
			xlim ( [ fLow fHigh ] )
			y1 = 10^floor(log10(min(y)));
			y2 = 10^ceil(log10(1.5*V_out_RMS(i)));
			ylim ( [y1 y2] );
			xlabel ('Frequency (Hz)');
			ylabel(sprintf('Amplitude (%s-RMS)',unit));
			grid on;
			if strcmp(P_or_V,'P')
				title ( sprintf("%s\n%g W-RMS, %g Hz",DUT_label,V_out_RMS(i)^2/R_load,f0(j)));
			else
				title ( sprintf("%s\n%g V-RMS, %g Hz",DUT_label,V_out_RMS(i),f0(j)));
			end
			drawnow
			if do_save_plots
				print ("-S650,400",sprintf("%s_%gVRMS_%gHz_SINE_SPECTRUM.pdf",DUT_label,V_out_RMS(i),f0(j)))
			end
		catch
			disp('mataa_electronic_HD_analysis: measurement failed.')
		end
	end	
end

% plot THD vs F0 and VOLT:

if length(f0) == 1
	if exist('fig_THD_vs_freq','var')
		close(fig_THD_vs_freq)
		clear fig_THD_vs_freq
	end
else
	if ~exist('fig_THD_vs_freq','var')
		fig_THD_vs_freq = figure();
	end

	figure(fig_THD_vs_freq)
	y = THD*100;
	l = loglog(f0, y, 'linewidth', lw );
	xlabel ('Frequency (Hz)'); ylabel ("THD (%)");
	xlim( [min(f0) max(f0)] );
	y1 = 10^floor(log10(min(min(y))));
	y2 = 10^ceil(log10(1.5*max(max(y))));
	ylim ( [y1 y2] );
	grid on
	if length(V_out_RMS) == 1
		if strcmp(P_or_V,'P')
			title ( sprintf("%s\nTHD vs. Frequency at %g W-RMS",DUT_label,V_out_RMS^2/R_load) );
		else
			title ( sprintf("%s\nTHD vs. Frequency at %g V-RMS",DUT_label,V_out_RMS) );
		end
		set (l,'linewidth',lw,'color','r');
	else
		leg = {};
		for k = 1:length(V_out_RMS)
			if strcmp(P_or_V,'P')
				leg{k} = [ num2str(V_out_RMS(k)^2/R_load) ' W-RMS' ];
			else
				leg{k} = [ num2str(V_out_RMS(k)) ' V-RMS' ];
			end
		end
		legend(leg);
	end
	if do_save_plots
		print ("-S650,400",sprintf("%s_THD_vs_freq.pdf",DUT_label))
	end
end


if length(V_out_RMS) == 1
	if exist('fig_THD_vs_volt','var')
		close(fig_THD_vs_volt)
		clear fig_THD_vs_volt
	end
else
	if ~exist('fig_THD_vs_volt','var')
		fig_THD_vs_volt = figure();
	end

	figure(fig_THD_vs_volt)
	y = THD'*100;
	if strcmp(P_or_V,'P')
		l = loglog(V_out_RMS.^2/R_load, y, 'linewidth', lw );
		xlabel ('Output power (W-RMS)');
		xlim( [min(V_out_RMS) max(V_out_RMS)].^2/R_load );
	else
		l = loglog(V_out_RMS, y, 'linewidth', lw );
		xlabel ('Output voltage (V-RMS)');
		xlim( [min(V_out_RMS) max(V_out_RMS)] );
	end
	ylabel ("THD (%)");
	y1 = 10^floor(log10(min(min(y))));
	y2 = 10^ceil(log10(1.5*max(max(y))));
	ylim ( [y1 y2] );
	grid on
	if length(f0) == 1
		title ( sprintf("%s\nTHD vs. output %s at %g Hz",DUT_label,tgt,f0));
		set (l,'linewidth',lw,'color','r');
	else
		title ( sprintf("%s\nTHD vs. output %s",DUT_label,tgt));
		leg = {};
		for k = 1:length(f0)
			leg{k} = [ num2str(f0(k)) ' Hz' ];
		end
		legend(leg);
	end
	if do_save_plots
		print ("-S650,400",sprintf("%s_THD_vs_outputlevel.pdf",DUT_label))
	end

end
