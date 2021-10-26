function curlDownloadDirectory(remoteDir, localDir, varargin)
% Use curl to download a directory
%   
%   curlDownloadDirectory(remoteDir, localDir, netrcFile, cookieFile)
%   curlDownloadDirectory(remoteDir, localDir)
%   
%   Downloads the directory contents of a remote directory into a specified
%   local directory.
%   Will use a faster download option on Windows if called with appropriate
%   .netrc and cookie file. See:
%   https://cddis.nasa.gov/Data_and_Derived_Products/CDDIS_Archive_Access.html
%   https://cddis.nasa.gov/Data_and_Derived_Products/CreateNetrcFile.html


% pull the filename
remoteDir = fileparts(remoteDir);

if startsWith(localDir, '~')
    warning('Local directory file path cannot start with "~" but must be fully specified!')
end

if ispc && numel(varargin) == 2 && all(cellfun(@ischar, varargin)) ...
        && all(cellfun(@isfile, varargin))
    % Functionality to download all at once using curl- much faster than
    % downloading individual files. But requires netrc and cookie file.
    % This currently only works on windows.
    
    % check if the local folder exists
    if ~exist(localDir, 'dir')
        mkdir(localDir);
    end
    % define name under which the data is to be saved
    localFile = fullfile(localDir, 'allDirFiles.tar');

    % download entire directory contents to local archive
    [curlCode, ~] = system(['curl --silent -c "' varargin{2} ...
                            '" -n --netrc-file "' varargin{1} ...
                            '" -L -o "' localFile '" "' remoteDir '/*" ']);

    % gracefully warn user of failure
    if curlCode > 0
        warning(['Failed to download files from %s\n', ...
                 'cURL exited with code %i.'], remoteDir, curlCode);
    end
    
    % unzip the downloaded archive
    navsu.readfiles.unzipFile(localFile, localDir, true);
    % delete the downloaded archive
    delete(localFile);
    
else
    % loop over all files, pull them one by one
    
    % get list of all files
    fileNames = navsu.ftp.curlGetDirectoryContents(remoteDir);
    filePaths = fullfile(remoteDir, fileNames);

    % download each file one by one
    for fI = 1:length(filePaths)
        navsu.ftp.curlDownloadSingleFile(filePaths{fI}, localDir);
    end
end

end