function c = RTX6001_NEUROCHROME286_AUTOSCALINGFUNCTION_DAC_BALANCED(channel);

% function c = RTX6001_NEUROCHROME286_AUTOSCALINGFUNCTION_DAC_BALANCED(channel);
%
% DESCRIPTION:
% Determine sensitivity settings for RTX6001+NEUROCHROME-286 (BALANCED XLR connections) and return as cal struct.
%
% INPUT:
% channel: channel string ('left' or 'right')
%
% OUTPUT:
% c: cal struct corresponding to the left or right channel
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

% Determine RTX6001 DAC cal/settings:
c = RTX6001_AUTOSCALINGFUNCTION_DAC_BALANCED(channel);

% Add voltage gain of NEUROCHMOME MODULUS 286:
c.DAC.sensitivity = c.DAC.sensitivity * 19.9; % add measured gain of Neurochrome M286 amplifier

% Add to DAC name:
c.DAC.name = sprintf('%s + NEUROCHROME MODULUS 286', c.DAC.name);
