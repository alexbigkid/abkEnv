Write-Host "----- python installation ------"
Get-Command python
# Write-Host "----- python2 installation ------"
# Get-Command python2
Write-Host "----- python3 installation ------"
Get-Command python3

Write-Host "------ python version and libs ------"
python --version
python -c 'import sys; print(sys.path)'
# Write-Host "------ python2 version and libs ------"
# python2 --version
# python2 -c 'import sys; print(sys.path)'
Write-Host "------ python3 version and libs ------"
python3 --version
python3 -c 'import sys; print(sys.path)'


Write-Host "------ pip installations ------"
Get-Command pip
# Write-Host "------ pip2 installations ------"
# Get-Command pip2
Write-Host "------ pip3 installations ------"
Get-Command pip3

Write-Host "------ pip version and installation location ------"
pip -V
# Write-Host "------ pip2 version and installation location ------"
# pip2 -V
Write-Host "------ pip3 version and installation location ------"
pip3 -V

