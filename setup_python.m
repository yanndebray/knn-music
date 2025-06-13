pe = pyenv(Version="/usr/bin/python3",...
    ExecutionMode="OutOfProcess")
piploc = fullfile(tempdir,"get-pip.py");
websave(piploc,"https://bootstrap.pypa.io/get-pip.py");
system("python "+piploc);
system("python -m pip install spotipy pandas");