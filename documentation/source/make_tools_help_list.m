% this is an Octave m-file to make a texi (TeXinfo) file containing the help messages of the m-files in the MATAA tools folder.

outfile = 'MATAA_manual_tools.texi';
out_fid = fopen(outfile,'wt');
fprintf(out_fid,'@node MATAA tools reference\n');
fprintf(out_fid,'@chapter MATAA tools reference\n\n');
fprintf(out_fid,'@paragraphindent 0\n\n');
fprintf(out_fid,'This section contains a list of the MATAA tools and their usage information as of %s.\n\n',date);
path = mataa_path('tools');
t = mataa_tempfile;

system(sprintf('ls %s*.m | sort -f > %s',path,t)); % this sorts without caring for capitalization
% system(sprintf('ls %s*.m > %s',path,t)); % this sorts by capitalization first, then alphabetically
fid_list = fopen(t,'rt');
frewind(fid_list);
doReadList = 1;
while doReadList
    tool = fgetl(fid_list);
    if tool == -1
        doReadList = 0;
    else
        if strcmp (tool(end-1:end),".m")
            i = findstr(filesep,tool);
            %disp('') % insert empty line
            %disp('******************')
            %disp('') % insert empty line
            funName = tool(i(end)+1:end-2);
            filePath = tool(i(end-1)+1:end);
            fprintf(out_fid,'@findex %s\n',funName);
            fprintf(out_fid,'@node %s\n',funName);
            fprintf(out_fid,'@section %s\n\n',funName);
            fprintf(out_fid,'file: ...%s@*\n\n',filePath);
            %disp(''); % insert empty line
            fid_tool = fopen(tool,'rt');
            frewind(fid_tool);		
            doReadTool = 1;
            header = 1; % there are a few header lines that don not start with a '%' sign
            while doReadTool
                lTool = fgetl(fid_tool);
                if lTool == -1
                    doReadTool = 0;
                else
                    if length(lTool) > 0 % otherwise the next line might fail
                    if strcmp(lTool(1),'%') ~= 0
                        header = 0; % we are not in the header anymore

                        if findstr('DISCLAIMER',lTool)
                            for i=1:20 % skip disclaimer, license and copyright info
                                fgetl(fid_tool);
                            end
                        else
                        	line = lTool(3:end);
                        	if length(line) > 0
                        		line = sprintf('%s@*',line); % add line break
                        	end
                            % fprintf(out_fid,'%s@*\n',line) % include the texi command @* for the line break
                            fprintf(out_fid,'%s\n',line) % include the texi command @* for the line break
                            % if ~strcmp(lTool(end),sprintf('\n'))
                            % 	fprintf(out_fid,'\n');
                            % end
                        end
                    else
                        if header == 0
                            doReadTool = 0;
                        end
                    end
                    end
                end
            end
            fclose(fid_tool);
            fprintf(out_fid,'\n')
        end
    end
end    

fclose(fid_list);
delete(t);

fprintf(out_fid,'\n\n@paragraphindent 3'); % reset indent to default value
fclose(out_fid);