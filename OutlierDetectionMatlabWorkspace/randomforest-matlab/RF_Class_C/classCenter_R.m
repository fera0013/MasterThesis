function cc=classCenter_R(x, label, prox,nNbr)
    %in order to run this program make sure to 
    % install R and randomForest package in R. find the path of R and put
    % it below. Also make a folder in  C drive named tmp (i.e. c:\tmp) 


    %change path to the R executable below or set the R executable in the path
    %and modify R CMD BATCH command way below
    R_executable_path = '"C:\\\\Program Files\\\\R\\\\R-3.0.1\\\\bin\\\\x64\\\\R.exe"';
    if ~exist('nNbr','var')
        nNbr = min(table_label(label))-1;
    end


    if exist('rand_seed','var')
        val = num2str(ceil(rand_seed*1000000000));
    else
        val = num2str(ceil(rand*1000000000));
    end
    if ispc %all the \\\\ are required
        file_xy=['c:\\\\tmp\\\\' val '_xy.txt'];
        file_prox=['c:\\\\tmp\\\\' val '_prox.txt'];
        file_out=['c:\\\\tmp\\\\' val '_out.txt'];
    else
        file_xy=['/tmp/' val '_xy.txt'];
        file_prox=['/tmp/' val '_prox.txt'];
        file_out=['/tmp/' val '_out.txt'];
    end
    %lots of file conversion needed
    save_X_Y_to(file_xy, x, label);
    save_to(file_prox, prox);
    
    R_script_fileName= [val 'R_script.R'];
    %generate the R script file
    fid=fopen(R_script_fileName,'w');
    fprintf(fid,'setwd("%s");\n',windows_path(fileparts(mfilename('fullpath'))));
    fprintf(fid,'getwd()\n');
    fprintf(fid,'library(randomForest);\n');
    fprintf(fid,'xy<-read.table("%s");\n', file_xy);
    fprintf(fid,'prox<-read.table("%s");\n', file_prox);
    
    fprintf(fid,'cc<-classCenter(xy[,1:%d],xy$label,prox,%d);\n', size(x,2),int32(nNbr));
    fprintf(fid,'write.table(cc,quote=FALSE,row.names=FALSE,col.names=FALSE,file="%s");',file_out);
    fclose(fid);
    t1=clock;
    %%if R is in the path, you can execute it in any terminal as R CMD BATCH
    %cmd=sprintf('R CMD BATCH %s',R_script_fileName);
    %%if R is not in the path
    cmd=sprintf(' CMD BATCH %s',R_script_fileName);
    cmd=[R_executable_path cmd];
    
   system(cmd);
   ifprintf_(false,'command executed successfully\n');
    t2=clock;
    ifprintf_(false,'total time %f',etime(t2,t1));
    
    cc = load(file_out);

    deleteFile(file_xy);
    deleteFile(file_prox);
    deleteFile(file_out);
    deleteFile(R_script_fileName);
    deleteFile([R_script_fileName 'out']);
end

function deleteFile(filename)
    if ispc
        delete(filename);
    else
        system(['rm ' filename]);
    end
end

function save_to(fp_name, X_trn)    
    fp = fopen(fp_name,'w');
    
    fprintf(fp,'\t\t');
    for i=1:size(X_trn,2)
        fprintf(fp, ['feat-' num2str(i) '\t']);
    end
    fprintf(fp, '\n');
    
    for i=1:size(X_trn,1)
        fprintf(fp,'%d\t', i);
        for j=1:size(X_trn,2)-1
            fprintf(fp,'%f\t', X_trn(i,j));
        end
        fprintf(fp,'%f\n', X_trn(i,end));
    end
    
    fclose(fp);
end        


function save_X_Y_to(fp_name, X_trn, Y_trn)    
    fp = fopen(fp_name,'w');
    
    fprintf(fp,'\t\t');
    for i=1:size(X_trn,2)
        fprintf(fp, ['feat-' num2str(i) '\t']);
    end
    fprintf(fp, 'label');
    fprintf(fp, '\n');
    
    for i=1:size(X_trn,1)
        fprintf(fp,'%d\t', i);
        for j=1:size(X_trn,2)
            fprintf(fp,'%f\t', X_trn(i,j));
        end
        fprintf(fp,'%f\n', Y_trn(i,1));
    end
    
    fclose(fp);
end        


function ifprintf_(DEBUG,varargin)
    if DEBUG
        fprintf(varargin{:});
    end
end

function fn=windows_path(file_name)
    %I handle conversion to a format that windows like
    if ispc
        fn=regexprep(file_name,'\','\\\\');
    else
        fn = file_name;
        %why mess with perfection. I mean linux
    end
end


function val = table_label(label)
    %emulate table(label)
    %find the counts of the number of times a label is unique
    unique_label = unique(label);
    val = [];
    for i=1:length(unique_label)
        val(i) = length(find(unique_label(i)==label));
    end
end