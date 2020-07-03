function [FileList_raw, BasePath_raw] = ReadRawImgInfo(FilePath_Raw, DefaultFileSpec_Raw)
    DefaultPath                 = '.';
    [FileList_raw, BasePath_raw] = LFFindFilesRecursive( FilePath_Raw, DefaultFileSpec_Raw , DefaultPath );
    fprintf('Found :\n'); disp(FileList_raw);
end