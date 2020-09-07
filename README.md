# Powsershell_Scrapper 
1. ps-scrapx01.ps1:  To replicate folders & files in controlled way
2. ps-wgetx01.ps1: Download/Extract mutiple files of different extension from HTTP web server or Repository at single place

## Usage Example (If you want to run ps-scrapx01.ps1 use ps-scrapx01.ps1 instead ps-wgetx01.ps1 in below command)
```.\ps-wgetx01.ps1 -origin https://nginx.org -MainSite https://nginx.org/packages/rhel/7/ -LocalOutputPath C:\Users\Public -FileExtensions xml,rpm,tar.gz,exe,pdf,xml,mp4```
```
-origin            Main Target webserver or website Origin URL {For example: https://google.com, https://nginx.org etc.}
-MainSite          Target URL from where to start replication and download files  {For Example: You want to replicate all files from https://nginx.org/packages/rhel/7/ }
-LocalOutputPath   Local Directory path where to save downloaded folders/files
-FileExtensions    Extenstion file you want to download {Can dowloaded mutiple files of different extentions}
```

### Bonus: CTF Hunters or OSCP Aspirants can use this script to copy all their hosted exploit on target host in single run ;)
