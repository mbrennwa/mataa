% this is an Octave m-file to make a text file containing the help messages of the m-files in the MATAA tools folder. You'll want to run this m-file using the make_list_of_tools_help.sh shell script.

%disp('******************')
%disp('') % insert empty line
%disp(sprintf('This is a list of the MATAA tools and their usage information as of %s.',date))
path = mataa_path('tools');
t = mataa_tempfile;
system(sprintf('ls %s*.m > %s',path,t));
fid_list = fopen(t,'rt');
frewind(fid_list);
doReadList = 1;
while doReadList
    tool = fgetl(fid_list);
    if tool == -1
        doReadList = 0;
    else
        if strcmp(tool(end-1:end),'.m')
            i = findstr(filesep,tool);
            disp('') % insert empty line
            disp('******************')
            disp('') % insert empty line
            disp(sprintf('FILE: ...%s',tool(i(end-1):end)))
            disp(''); % insert empty line
            fid_tool = fopen(tool,'rt');
            frewind(fid_tool);		
            doReadTool = 1;
            header = 1; % there are a few header lines that don not start with a '%' sign
            while doReadTool
                lTool = fgetl(fid_tool);
                if lTool == -1
                    doReadTool = 0;
                else
                    if length(lTool) == 0
                        lTool = ' '; % otherwise the next line might fail
                    end
                    if strcmp(lTool(1),'%') ~= 0
                        header = 0; % we are not in the header anymore

                        if findstr('DISCLAIMER',lTool)
                            for i=1:20 % skip disclaimer, license and copyright info
                                fgetl(fid_tool);
                            end
                        else
                            disp(lTool(3:end))
                        end
                    else
                        if header == 0
                            doReadTool = 0;
                        end
                    end
                end
            end
            fclose(fid_tool);
        end
    end
end    

fclose(fid_list);
delete(t);
%fclose('~/Desktop/mataa_tools_help.txt');