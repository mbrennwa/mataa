% Use this script for impedance measurements.
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



% sample rate:
if ~exist('fs','var')
	fs = input ('Enter sampling rate (Hz, default = 44100): ');
end
if isempty(fs)
	fs = 44100;
end
disp (sprintf('Sampling rate fs = %g Hz',fs))

% sine sweep:
if ~exist('fL','var')
	fL = input ('Sine sweep start frequency (Hz): ')
end
disp (sprintf('Sine sweep start frequency fL = %g Hz',fL))

if ~exist('fH','var')
	fH = input ('Sine sweep end frequency (Hz): ')
end
fH = min([fs/2,fH]);
disp (sprintf('Sine sweep end frequency fH = %g Hz',fH))

if ~exist('U0rms','var')
	U0rms = input ('Sine sweep amplitude (V-RMS): ')
end
disp (sprintf('Sine sweep amplitude U0rms = %g V-RMS',U0rms))

% reference resistor:
if ~exist('R0','var')
	R0 = input ('Enter reference resistor value (Ohm): ')
end
disp (sprintf('Reference resistor R0 = %g Ohm',R0))

% SPL smoothing / resolution:
if ~exist('res','var')
	res = input ('Impedance curve smoothing (octave-fraction, leave empty for no smoothing): ');
end
if res <= 0
	res = [];
end
if isempty(res)
	disp ('No smoothing')
else
	disp (sprintf('Impedance curve smoothing 1/res = 1/%i octave',res))
	res = 1/res;
end

% Plot color:
if ~exist('col','var')
	col = input ('Plot color (char: k, r, g, b, c, m, y): ','s');
end
if isempty ('col')
	col = 'r';
end
disp (sprintf('Plot color col = %s',col))
style = sprintf('%s-',col);

% calibration file:
calfile = 'MB_ELECTRONIC_CHAIN.txt';
disp (sprintf('Calibration file = %s',calfile))

% Ready? Input ok?
input ('Ready to start? Press ENTER...')

% impedance measurement:
[Zmag,Zphase,f] = mataa_measure_impedance (fL,fH,R0,fs,res,calfile,U0rms*sqrt(2),'V');

% plot result:
semilogx (f,Zmag,style)


% always save to "LastMeasurement.mat":
save ('-V7','LastMeasurementIMPEDANCE.mat','f','Zmag','Zphase','fL','fH','R0','fs','res','calfile','U0rms');

% Ask to save file:
x = input ('Do you want to save raw data (impedance magnitude and phase) to a file (y/N)?','s');
if isempty(x)
	x = 'N';
end
if upper(x) == 'Y'
	fn = uiputfile('*.mat','Choose file to save raw data...');
	if ischar(fn)
		info = input ('Enter data description: ','s')
		save ('-V7',fn,'f','Zmag','Zphase','fL','fH','R0','fs','res','calfile','U0rms','info');
		disp (sprintf('Saved impedance data to file %s.',fn));
	else
		disp ('File not saved.')
	end
end
