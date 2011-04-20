function val = mataa_settings (field,value)

% function val = mataa_settings (field,value)
%
% DESCRIPTION:
% Retrieve and set MATAA settings.
%
% mataa_settings with no arguments returns all the settings
% mataa_settings(field) returns the value of the setting of 'field'
% mataa_settings(field,val) sets the value of the setting 'field' to 'val'.
% mataa_settings('reset') resets the settings to default values
%
% EXAMPLES:
% ** get the current settings (this also shows you the available fields):
% > mataa_settings
%
% ** get the current plot color:
% > mataa_settings('plotColor')
%
% ** set the plot color to red:
% > mataa_settings('plotColor','r')
%
% ** In principle, you can store anything in the MATAA settings file. For instance, you can store the birhtday of your grandmother, so you'll never forget that:
% > mataa_settings('BirthdayOfMyGrandmother','1st of April 1925');
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
% Further information: http://www.audioroot.net/MATAA.html

path = mataa_path ('settings');
path = sprintf('%s.mataa_settings.mat',path);

reset_to_def = ~exist(path);

if (~reset_to_def && exist('field')) reset_to_def = strcmp(field,'reset'); end

if reset_to_def
	% create / reset to default settings:
	mataa_settings.plotColor = 'b';
	mataa_settings.microphone = 'unknown_microphone';
	mataa_settings.plotWindow_IR = 1;
	mataa_settings.plotWindow_SR = 2;
	mataa_settings.plotWindow_FR = 3;
	mataa_settings.plotWindow_CSD = 4;
	mataa_settings.plotWindow_ETC = 5;
	mataa_settings.plotWindow_HD = 6;
	mataa_settings.plotWindow_impedance = 7;
	mataa_settings.openPlotAfterSafe = 1;
	
	mataa_settings.channel_DUT = 1;
	mataa_settings.channel_REF = 2;
	
    mataa_settings.interchannel_delay = 0;
	
	cc = [ 'save -mat ' path ' mataa_settings ; ' ];
	disp(sprintf('Creating / resetting to MATAA default settings (command: %s)...',cc));
	eval( cc );
	val = mataa_settings;
	disp(mataa_settings);
	disp('...done.');
end

% load settings from disk:
load(path);

if nargin==0 % return all settings
	val = mataa_settings;	
	return
else
	if nargin == 1 % read and return the value of the specified field
		if isfield(mataa_settings,field)
			eval( ['val = mataa_settings.' field ';' ] );	
		else
			warning(sprintf('mataa_settings: Unknown field value in mataa_settings: %s.',field));
			val = [];
		end		
	elseif nargin == 2 % set the field to the specified value and save the settings file	
		eval( [ 'mataa_settings.' field ' = value ; ' ] );
		eval( [ 'save -mat ' path ' mataa_settings ; ' ] );
		val = value;
	
	else
		warning('Too many input arguments for mataa_settings.');
	end

end

	
	
