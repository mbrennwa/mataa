function mataa_stimulus_wav_write (s, fs, file, T_lead, T_trail);

% function mataa_stimulus_wav_write (s, fs, file, T_lead, T_trail);
%
% DESCRIPTION:
% Write one mono WAV for an external player: T_lead seconds of exact zeros,
% then the bare digital stimulus s, then T_trail seconds of exact zeros.
% This function does not open a sound device and does not apply DAC scaling.
% Keep a copy of the file for MATAA. The copy loaded into the player must be
% the same samples. T_lead is dead time for starting playback. It is not the
% latency argument of mataa_measure_signal_response. T_trail only keeps a
% player from trimming or clicking at the end of the stimulus.
%
% INPUT:
% s: bare stimulus, samples in -1...+1 (vector).
% fs: sample rate (Hz).
% file: path of the WAV file to write.
% T_lead, T_trail: leading and trailing silence added to bare stiumus (seconds).
%
% OUTPUT:
% (none)
%
% EXAMPLE:
% > [s,t] = mataa_signal_generator('sweep',48000,1,[50 20000]);
% > mataa_stimulus_wav_write(s,48000,'stimulus.wav',2,0.5);
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

if nargin < 5
	error('mataa_stimulus_wav_write: need s, fs, file, T_lead, and T_trail.');
end
if ~ischar(file) || isempty(file)
	error('mataa_stimulus_wav_write: file name must be a non-empty string.');
end
if ~isscalar(fs) || ~(fs > 0)
	error('mataa_stimulus_wav_write: fs must be a positive sample rate.');
end
if ~isscalar(T_lead) || ~isscalar(T_trail) || T_lead < 0 || T_trail < 0
	error('mataa_stimulus_wav_write: T_lead and T_trail must be >= 0.');
end
if ~isvector(s) || isempty(s)
	error('mataa_stimulus_wav_write: s must be a non-empty vector (mono).');
end

s = s(:);
% Allow a few ULPs so a full-scale generator sample of exactly 1 still passes.
limit = 1 + 1e-8;
if max(s) > limit || min(s) < -limit
	error('mataa_stimulus_wav_write: s must stay within -1...+1. No DAC scaling is applied.');
end

n_lead = round(T_lead * fs);
n_trail = round(T_trail * fs);
y = [ zeros(n_lead,1) ; s ; zeros(n_trail,1) ];

% 32-bit float keeps exact padding zeros and does not quantise a fade into them.
audiowrite(file, y, fs, 'BitsPerSample', 32);

end
