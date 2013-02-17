%PRNEWS Opens browser with PRTools news

url = 'http://prtools.org/prtools/prtools_news/';
[s,status] = urlread(url);

if ~status
  url = 'http://prtools.eu/prtools/prtools_news/';
  [s,status] = urlread(url);
end

if ~status
  error('Website could not be reached. Please retry later')
else
  web(url,'-browser')
end