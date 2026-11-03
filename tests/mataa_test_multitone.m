function mataa_test_multitone

% function mataa_test_multitone
%
% DESCRIPTION:
% Checks the multitone generator. Does not open a sound device and does not change MATAA settings.
%
% EXAMPLE:
% > addpath /path/to/mataa/tests
% > mataa_test_multitone
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
% Copyright (C) 2026 Matthias S. Brennwald.
% Contact: info@audioroot.net
% Further information: http://www.audioroot.net/MATAA

script_dir = fileparts(mfilename('fullpath'));
if isempty(script_dir)
	script_dir = pwd;
end
addpath(fullfile(fileparts(script_dir), 'mataa_tools'));

if exist('OCTAVE_VERSION', 'builtin')
	more('off');
end

fs = 48000;
p = struct('f1', 20, 'f2', 20000, 'spacing', 'octave', 'tones_per_octave', 6, 'shaping', 'equal', 'phases', 'iec');
[s, ~, info] = mataa_signal_generator('multitone', fs, 1, p);

__check(abs(sqrt(mean(s .^ 2)) - 1) < 1e-9, 'octave waveform RMS is not 1');
__check(abs(info.rms - 1) < 1e-12, 'stored RMS is not 1');
__check(abs(info.peak - max(abs(s))) < 1e-12, 'stored peak does not match the waveform');
__check(abs(info.crest_dB - 20*log10(info.peak)) < 1e-9, 'stored crest factor does not match the waveform');
__check(all(info.bin == round(info.bin)), 'tone bins are not integers');
__check(all(diff(info.bin) >= 1), 'tone bins are not unique and rising');
__check(max(abs(info.f - info.bin * fs / length(s))) < 1e-6, 'tone frequencies are off the grid');
__check(info.f(1) >= 20 && info.f(end) <= 20000, 'octave tones leave the requested band');
__check(abs(info.phase(1) - 1) < 1e-12, 'first IEC phase is not 1 radian');

a = 48271;
m = 2^31 - 1;
phi = 1;
for i = 1:min(8, length(info.phase)-1)
	n = phi * m / (2 * pi);
	n = mod(a * n, m);
	phi = 2 * pi * n / m;
	__check(abs(info.phase(i+1) - phi) < 1e-8, sprintf('IEC phase %i does not follow the recurrence', i+1));
end

oct = floor(log2(info.f / info.f(1)));
for k = 0:max(oct)-1
	c = sum(oct == k);
	__check(c >= 5 && c <= 7, sprintf('octave %i has %i tones, expected about 6', k, c));
end

published = [100, 122, 261.8, 348.2, 685.4, 987, 1794.4, 2870.4, 4697.9, 6765, 12299, 16358];
pe = struct('f1', 20, 'f2', 20000, 'spacing', 'phi12r', 'shaping', 'equal', 'phases', 'iec');
[~, ~, ip] = mataa_signal_generator('multitone', fs, 1, pe);
__check(length(ip.bin) == 12, 'Phi12r did not keep 12 tones');
__check(all(diff(ip.bin) >= 1), 'Phi12r bins collide');
__check(all(ip.bin == round(published(:))), 'Phi12r did not snap to the nearest 1 Hz bin');

ee = p;
ee.shaping = 'eia426b';
[~, ~, ie] = mataa_signal_generator('multitone', fs, 1, ee);
__check(max(ie.amplitude) / min(ie.amplitude) > 1.5, 'EIA-426B shaping left the tone amplitudes equal');

rejected = false;
try
	bad = p;
	bad.spacing = 'nid';
	mataa_signal_generator('multitone', fs, 1, bad);
catch
	rejected = true;
end
__check(rejected, 'NID spacing was accepted');

disp('mataa_test_multitone: ok');

end

function __check(cond, msg)
	if ~cond
		error(sprintf('mataa_test_multitone: %s.', msg));
	end
end
