#!/bin/sh
echo ----- python installations ------ 
which -a python python2 python3

echo ------ python version and libs ------ 
python --version
python -c 'import sys; print(sys.path)'

echo ------ python2 version and libs ------ 
python2 --version
python2 -c 'import sys; print(sys.path)'

echo ------ python3 version and libs ------ 
python3 --version
python3 -c 'import sys; print(sys.path)'


echo ------ pip installations ------ 
which pip pip2 pip3

echo ------ pip version and installation location ------ 
pip -V

echo ------ pip2 version and installation location ------ 
pip2 -V

echo ------ pip3 version and installation location ------ 
pip3 -V

