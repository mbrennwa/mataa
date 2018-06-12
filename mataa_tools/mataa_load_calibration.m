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
% To load the (generic) calibration data for a Behringer ECM8000 microphone:
% c = mataa_load_calibration ('BEHRINGER_ECM8000_D1303397118_MICROPHONE.txt');
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
    error (sprintf("mataa_load_calibration: could no open calilbration file '%s' (%s).",calfile,msg));
end

f = gain = phase = [];
lineNo = 0;

% read file and parse data:
while (! feof (fid) )
    
    l = fgetl(fid);
    lineNo = lineNo + 1;
    
	%%% disp (sprintf("Line %i: %s",lineNo,l));

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
    				cal.sensitivity = str2num (X{1});
    				cal.sensitivity_unit = deblank(fliplr(deblank(fliplr(X{2}))));
    				% check unit / value consistency later
    			
    			case "SENSITIVITY_AUTOSCALEFUNCTION"
				cal.sensitivity_autoscalefunction =  strtrim (val);

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
    				error (sprintf("mataa_load_calibration: cannot parse unknown keyword '%s.'",key))
    		
    		end % switch key
    		
		else % transfer function / gain in dB relative to absolute sensitivity value 
	    	u = strsplit (untabify(l)," ");
	    	f     = [ f    ; str2num(u{1}) ];
	    	gain  = [ gain ; str2num(u{2}) ];
	    	if length(u) > 2
		    	phase = [ phase ; str2num(u{3}) ];
		    end
    	end
    end % isempty(l)
     
end % while feof(fid)

if ~isempty (f)
	cal.transfer.f    = f;
	cal.transfer.gain = gain;
	if ~isempty (phase)
		cal.transfer.phase = phase;
	end
	[cal.transfer.f,k] = sort (cal.transfer.f);
	cal.transfer.gain = cal.transfer.gain(k);
	if isfield (cal.transfer,'phase')
		cal.transfer.phase = cal.transfer.phase(k);
	end	
end

fclose (fid);

% check sensitivity value / unit:
if isfield (cal,'sensitivity')
	switch toupper(cal.type)
		case {"SENSOR","MICROPHONE"}
    		if strcmp(cal.sensitivity_unit,"mV/Pa")
    			cal.sensitivity_unit = "V/Pa";
    			cal.sensitivity = cal.sensitivity / 1000;
    		end
%    		if ~strcmp(cal.sensitivity_unit,"V/Pa")
%    			error ("mataa_load_calibraton: sensitivity unit '%s' for SENSOR or MICROPHONE not supported (unit must be V/Pa).",cal.sensitivity_unit,cal.sensitivity_unit);
%    		end
    	
    	case "DAC"
    		if ~strcmp(cal.sensitivity_unit,"V")
	    		error ("mataa_load_calibraton: DAC sensitivity unit '%s' not supported (unit must ve V).",cal.sensitivity_unit);
	    	end
    		
    	case "ADC"
    		if ~strcmp(cal.sensitivity_unit,"1/V")
	    		error ("mataa_load_calibraton: ADC sensitivity unit '%s' not supported (unit must ve V).",cal.sensitivity_unit);
	    	end
		
	otherwise
		warning (sprintf("mataa_load_calibration: unknown device type '%s.'",cal.type))
		
	end % switch
end % if isfield (cal,'sensitivity')


% clean up struct format and remove 'type' field:
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
		cal = rmfield(cal,'type');
		if isfield (cal,'transfer')
			warning ("mataa_load_calibration: inclusing an overall transfer function with a 'full chain' calibration file is not recommended and may produce unpredictable results.")
		end
	otherwise
		error (sprintf("mataa_load_calibration: unknown device type '%s.'",cal.type))
end

