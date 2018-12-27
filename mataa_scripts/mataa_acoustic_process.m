% Use this script to process impulse response measurements from mataa_acoustic_measure.m
% (Calculate step response and SPL response, and save data to TMD and FRD files).
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
% Copyright (C) 2018 Matthias S. Brennwald.
% Contact: info@audioroot.net
% Further information: http://www.audioroot.net/MATAA.html

% load data:
[fname,fpath] = uigetfile ('*.mat', 'Select MAT file with raw impulse response data');
X = load ([fpath fname]);
if isfield(X,'U0');
	X.U0rms = X.U0; % convert field name from older version
end
if ~isfield(X,'sig');
	X.sig = 'sweep'; % add / convert from older version
end
if ~isfield(X,'Nrepeat');
	X.Nrepeat = 1; % add / convert from older version
end
if ~isfield(X,'info');
	X.info = ''; % add if missing (e.g., with "last measurement files")
end

% cut-off / time gate:
fc = input ('Lower cut-off frequency for SPL display (--> gate time) (Hz): ');
if isempty (fc)
	disp ('Time gating turned off, fc = [].')
else
	disp (sprintf('Time-domain gating / cut-off frequency fc = %g Hz',fc))
end

% Normalisation to signal level:
u0 = input ('Normalise impulse response to drive level (RMS voltage, leave empty to skip normalisation): ');
if isempty (u0)
	disp ('Level normalisation turned off.')
else
	disp (sprintf('Normalising impulse response to %g V-RMS drive level.',u0))
	X.h = X.h / X.U0rms * u0;
end

% SPL smoothing / resolution:
res = input ('SPL response smoothing (octave-fraction, leave empty for no smoothing): ');
if res <= 0
	res = [];
end
if isempty(res)
	disp ('SPL response smoothing turned off, res = [].')
else
	disp (sprintf('SPL response smoothing 1/res = 1/%i octave',res))
end

% Plot color:
col = input ('Plot color (char: k, R, g, b, c, m, y): ','s');
col = tolower(col);
if isempty(cell2mat(strfind(col,{'k', 'r', 'g', 'b', 'c', 'm', 'y'})))
	col = 'r';
end
disp (sprintf('Plot color col = %s',col))
style = sprintf('%s-',col);


% Ready? Input ok?
input ('Ready? Press ENTER...');

% time gating, detrend:
if isempty(fc)
	[t_start,t_rise] = mataa_guess_IR_start (X.h,X.fs);
	[h,t] = mataa_signal_crop (X.h,X.fs,t_start-t_rise,t(end));
	t = t + t_start;
	T = t(end)-t(1);
else
	[t_start,t_rise] = mataa_guess_IR_start (X.h,X.fs);
	[h,t] = mataa_signal_crop (X.h,X.fs,t_start-t_rise,t_start + 1/fc);
	t = t + t_start;
	T = 1/fc;
end
h = detrend (h);

% step response:
[s,ts] = mataa_IR_to_SR (h,t);

% SPL response:
if isempty(res)
	[mag,phase,f,unit_mag] = mataa_IR_to_FR (h,X.fs,[],X.unit);
else
	[mag,phase,f,unit_mag] = mataa_IR_to_FR (h,X.fs,1/res,X.unit);
end


subplot (3,1,1)
plot ((t-t(1))*1000,h,style);
title ('Impulse response')
xlabel ('Time (ms)')
ylabel ('Amplitude (Pa)')
axis (1000*[0,T]);
hold on

subplot (3,1,2)
plot ((ts-ts(1))*1000,s,style);
title ('Step response')
xlabel ('Time (ms)')
ylabel ('Amplitude (Pa)')
axis (1000*[0,T]);
hold on

subplot (3,1,3)
semilogx(f,mag,style);
title ('SPL response')
xlabel ('Frequency (Hz)')
ylabel ('SPL (dB-SPL)')
axis ([1/T,f(end)]);
grid on
hold on

title ('SPL response')
hold on

% Ask to save TMD file (impulse response):
x = input ('Do you want to export impulse response to TMD file (y/N)?','s');
if isempty(x)
	x = 'N';
end
if upper(x) == 'Y'
	fn = uiputfile('*.TMD','Choose file to save impulse response data...');
	if ischar(fn)
		info = input ('Enter impulse response data description: ','s')
		mataa_export_TMD (t,h,info,fn);
		disp (sprintf('Exported impulse response data to file %s.',fn));
	else
		disp ('File not saved.')
	end
end


% Ask to save TMD file (step response):
x = input ('Do you want to export step response to TMD file (y/N)?','s');
if isempty(x)
	x = 'N';
end
if upper(x) == 'Y'
	fn = uiputfile('*.TMD','Choose file to save step response data...');
	if ischar(fn)
		info = input ('Enter step response data description: ','s')
		mataa_export_TMD (t,h,info,fn);
		disp (sprintf('Exported step response data to file %s.',fn));
	else
		disp ('File not saved.')
	end
end


% Ask to save FRD file (SPL response):
x = input ('Do you want to export SPL response to FRD file (y/N)?','s');
if isempty(x)
	x = 'N';
end
if upper(x) == 'Y'
	fn = uiputfile('*.FRD','Choose file to save SPL response data...');
	if ischar(fn)
		info = input ('Enter SPL response data description: ','s');
		mataa_export_FRD (f,mag,phase,info,fn);
		disp (sprintf('Exported SPL response data to file %s.',fn));
	else
		disp ('File not saved.')
	end
end

% code template to save figure file;
% set(gcf,'PaperUnits','inches'); set(gcf,'PaperOrientation','portrait'); set(gcf,'PaperSize',[8,15]); set(gcf,'PaperPosition',[0,0,8,15]); print ('acoustic.png')
