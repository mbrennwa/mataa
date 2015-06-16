function cal = mataa_load_calibration (calfile)

% function cal = mataa_load_calibration (calfile)
%
% DESCRIPTION:
% Load calibration data for test devices from calibration file.
% 
% INPUT:
% calfile: name of calibration file (e.g., "Behringer_ECM8000.txt")
% 
% OUTPUT:
% cal: struct with calibration data.
% 
% EXAMPLE:
% To load the (generic) calibration data for the Behringer ECM8000 microphone:
% c = mataa_load_calibration ('Behringer_ECM8000.txt');
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
% Copyright (C) 2015 Matthias S. Brennwald.
% Contact: info@audioroot.net
% Further information: http://www.audioroot.net/MATAA


calpath = mataa_path ("calibration");
calfile = sprintf ("%s%s",calpath,calfile);

[fid,msg] = fopen (calfile,"rt");
if fid < 0
    error (sprintf("mataa_load_calibration: could no open calilbration file (%s).",msg));
end

f = gain = [];

% read file and parse data:
while (! feof (fid) )
    
    l = fgetl(fid);
    		
    % check comments:
    k = findstr ("%",l);
    if any(k)
    	if k(1) == 1
    		l = "";
    	else
    		l = l(1:k(1)-1);
    	end
    end
    
    % remove trailing / leading white space:
    l = deblank (l);
    l = fliplr (deblank(fliplr(l)));
    
    % parse l
    if ~isempty(l)

    	if findstr ("=",l) % parse keyword / value
    		u = strsplit (l,"=");
    		key = deblank(fliplr(deblank(fliplr(u{1}))));
    		val = deblank(fliplr(deblank(fliplr(u{2}))));
    		
    		switch toupper(key)
    		
				case "NAME"
					cal.name = val;

    			case "TYPE"
    				switch toupper(val)
    					case "SENSOR"
    						cal.type = "SENSOR";
    					case "MICROPHONE"
    						cal.type = "MICROPHONE";
    					case "DAC"
    						cal.type = "DAC";
    					case "ADC"
    						cal.type = "ADC";
    					case {"CHAIN","FULLCHAIN"}
    						cal.type = "CHAIN";
    					otherwise
    						warning (sprintf("mataa_load_calibration: unknown device type '%s.'",val))
    						cal.type = "UNKNOWN";
    				end % switch val
					
    			case "SENSITIVITY"
    				X = strsplit (val," ");
    				if length (X) < 2
    					error ("mataa_load_calibration: cannot determine value / unit of sensitivity");
    				end
    				cal.sensititivy.val  = str2num (X{1});
    				cal.sensititivy.unit = deblank(fliplr(deblank(fliplr(X{2}))));
    				if strcmp (cal.sensititivy.unit,'mV/Pa') % convert to Pa/V
    					cal.sensititivy.val = cal.sensititivy.val / 1000;
    					cal.sensititivy.unit = 'V/Pa';
    				end
    			
    			case "FILE" % load data from another file
    				u = mataa_load_calibration (val);
    				switch toupper(u.type)
    					case "DAC"
    						cal.DAC = u.DAC;
    					case "ADC"
    						cal.ADC = u.ADC;
    					case {"SENSOR","MICROPHONE"}
    						cal.SENSOR = u.SENSOR;
    					otherwise
    						warning (sprintf("mataa_load_calibration: unknown device type '%s.'",val))
    				end
    				cal.type = "CHAIN";
    				clear u
    			
    			otherwise
    				warning (sprintf("mataa_load_calibration: ignoring unknown keyword '%s.'",key))
    		
    		end % switch key
    		
		else % transfer function / gain in dB relative to absolute sensititivy value 
	    	u = strsplit (l," ");
	    	f    = [ f    ; str2num(u{1}) ];
	    	gain = [ gain ; str2num(u{2}) ];
    	end
    end % isempty(l)
     
end % while feof(fid)

if ~isempty (f)
	cal.transfer.f    = f;
	cal.transfer.gain = gain;
	[cal.transfer.f,k] = sort (cal.transfer.f);
	cal.transfer.gain = cal.transfer.gain(k);
end

fclose (fid);

switch toupper(cal.type)
	case "ADC" % move to adc sub-struct:
		dummy.ADC = rmfield(cal,'type');
		cal = dummy;
		cal.type = "ADC";
	case "DAC" % move to dac sub-struct:
		dummy.DAC = rmfield(cal,'type');
		cal = dummy;
		cal.type = "DAC";
	case {"SENSOR","MICROPHONE"} % move to sensor sub-struct:
		dummy.SENSOR = rmfield(cal,'type');
		cal = dummy;
		cal.type = "SENSOR";
	case {"CHAIN"} % check struct format:
		if isfield (cal,'transfer')
			warning ("mataa_load_calibration: inclusing an overall transfer function with a 'full chain' calibration file is not recommended and may produce unpredictable results.")
		end
	otherwise
		error (sprintf("mataa_load_calibration: unknown device type '%s.'",cal.type))
end

