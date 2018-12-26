% Use this script to process impedance measurements from mataa_impedance_measure.m
% (Reduce number of points, plot curves, and save data to FRD file).
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
[fname,fpath] = uigetfile ('*.mat', 'Select MAT file with raw impedancee data');
X = load ([fpath fname]);
if ~isfield(X,'info');
	X.info = ''; % add if missing (e.g., with "last measurement files")
end

% cut-off frequencies (upper / lower):
f1 = input ('Lower cut-off frequency for impedance curve (Hz): ');
if isempty (f1)
	f1 = min(X.f);;
end
disp (sprintf('Lower cut-off frequency f1 = %g Hz',f1))

f2 = input ('Upper cut-off frequency for impedance curve (Hz): ');
if isempty (f2)
	f2 = max(X.f);
end
disp (sprintf('Lower cut-off frequency f2 = %g Hz',f2))

% crop frequency band:
k     = find (X.f >= f1 & X.f <= f2);
f     = X.f(k);
mag   = X.Zmag(k);
phase = X.Zphase(k);

% curve smoothing / resolution:
res = input ('Curve smoothing (octave-fraction, leave empty for no smoothing): ');
if res <= 0
	res = [];
end
if isempty(res)
	disp ('Curve smoothing turned off, res = [].')
else
	disp (sprintf('Curve smoothing 1/res = 1/%i octave',res))
	[mag,phase,f] = mataa_FR_smooth (mag,phase,f,1/res);
end

% number of data points:
n = input ('Number of data points for impedance curve (interpolation points): ');
if isempty(n)
	disp ('Curve interpolation turned off')
else
	disp (sprintf('Number of data points for curve interpolation = %i',n))
	ff    = logspace(log10(f1),log10(f2),n);
	mag   = interp1 (f,mag,ff);
	phase = interp1 (f,phase,ff);
	f     = ff; clear('ff');
end

% Plot color:
col = input ('Plot color (char: k, r, g, b, c, m, y): ','s');
if isempty(cell2mat(strfind(col,{'k', 'r', 'g', 'b', 'c', 'm', 'y'})))
	col = 'r';
end
disp (sprintf('Plot color col = %s',col))
style = sprintf('%s-',col);

% Ready? Input ok?
input ('Ready? Press ENTER...');

subplot (2,1,1)
semilogx (f,mag,style);
title ('Impedance magnitude')
xlabel ('Frequency (Hz)')
ylabel ('Impedance (Ohm)')
% axis (1000*[0,T]);
xlim([min(f) max(f)]);
grid on
hold on

subplot (2,1,2)
semilogx (f,phase,style);
title ('Impedance phase')
xlabel ('Frequency (Hz)')
ylabel ('Phase (degrees)')
% axis (1000*[0,T]);
xlim([min(f) max(f)]);
grid on
hold on

% Ask to save FRD file (impedance curve):
x = input ('Do you want to export impedance curve to FRD file (y/N)?','s');
if isempty(x)
	x = 'N';
end
if upper(x) == 'Y'
	fn = uiputfile('*.FRD','Choose file to save impedance curve data...');
	if ischar(fn)
		info = input ('Enter impedance data description: ','s');
		mataa_export_FRD (f,mag,phase,info,fn);
		disp (sprintf('Exported impedance data to file %s.',fn));
	else
		disp ('File not saved.')
	end
end

% code template to save figure file;
% set(gcf,'PaperUnits','inches'); set(gcf,'PaperOrientation','portrait'); set(gcf,'PaperSize',[8,10]); set(gcf,'PaperPosition',[0,0,8,10]); print ('impedance.png')
