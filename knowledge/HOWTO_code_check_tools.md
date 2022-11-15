CODE CHECKING TOOLS
	SHELL
		/p/home/cwood/bin/shellcheck
		#syntax checking for shell script
		set -n  OR sh -n /<target script>
	PERL
		/p/home/cwood/bin/perltidy
	PYTHON
		/p/home/cwood/bin/autopep8
		/p/home/cwood/bin/pycodestyle
		ONLINE
			https://www.cleancss.com/python-beautify/
			https://pythoniter.appspot.com/
			https://github.com/google/yapf
			https://pypi.python.org/pypi/autopep8
		AUTOPEP8
		    Reference: https://github.com/hhatto/autopep8
			autopep8 Python formater Installation Instructions
				wget https://bootstrap.pypa.io/get-pip.py && python get-pip.py --user
				ln -s ~/.local/bin/pip ~/bin/pip
				ln -s ~/.local/bin/wheel ~/bin/wheel
				pip install --upgrade setuptools --user
				pip install --upgrade pcodesytle --user
				pip install --upgrade autopep8 --user
                #Fortran compilation system
                pip install FoBiS.py --user
				ln -s ~/.local/bin/autopep8 ~/bin/autopep8
				ln -s ~/.local/bin/pycodestyle ~/bin/pycodestyle
				~/bin/autopep8 --in-place --aggressive --aggressive <filename>
		PYCODESTYLE
			Reference: https://github.com/PyCQA/pycodestyle
			pycodestyle --show-source --show-pep8 ./cardCounting.py 
			pycodestyle --statistics -qq ./cardCounting.py
	    PROFILING
		    pip install pip install pycallgraph
			perf | gprof | valgrind

PERL
   Install packages locally:
    mkdir ~/.local/lib/perl
	perl Makefile.PL PREFIX=~/.local/lib/perl
	make
	make install
	history

PYTHON
  Install Packages locally: --user

    Path Configuration file
	SITEDIR=$(python -m site --user-site)
	PYTHON_DIR=python2.6
	PYTHON_PATH=$PYTHON_PATH:/usr/lib/python2.6/site-packages/:~/.local/lib/python2.6/site-packages/
	http://persagen.com/files/misc/Turning_vim_into_a_modern_Python_IDE.html

MANDATORY NEW SYSTEM INSTALLS
STIG
ln -s ./STIGViewer-2.8.jar ./default.jar

JAVA
ln -s ${HOME}/Documents/apps/jdk8/bin/java ${HOME}/bin/java
ln -s ${HOME}/Documents/apps/jdk8/bin/jar ${HOME}/bin/jar
ln -s ${HOME}/Documents/apps/jdk8/bin/javac ${HOME}/bin/javac

PERL
ln -s /home/cwood/Documents/apps/perltidy/perltidy_complete.pl $HOME/bin/perltidy.pl
ln -s $HOME/Documents/apps/nytprof/bin/flamegraph.pl $HOME/bin/flamegraph.pl
ln -s $HOME/Documents/apps/nytprof/bin/nytprofcalls $HOME/bin/ntyprofcalls
ln -s $HOME/Documents/apps/nytprof/bin/nytprofcg $HOME/bin/nytprofcg
ln -s $HOME/Documents/apps/nytprof/bin/nytprofcsv $HOME/bin/nytprofcsv
ln -s $HOME/Documents/apps/nytprof/bin/nytprofhtml $HOME/bin/nytprofhtml
ln -s $HOME/Documents/apps/nytprof/bin/nytprofmerge $HOME/bin/nytprofmerge
ln -s $HOME/Documents/apps/nytprof/bin/nytprofpf $HOME/bin/nytprofpf

FORTRAN
ln -s /home/cwood/Documents/apps/fmake/fmake $HOME/bin/fmake
ln -s /home/cwood/Documents/apps/ftnchek $HOME/bin/ftnchek

BASH
ln -s ${HOME}/Documents/apps/shellcheck-v0.5.0/shellcheck ${HOME}/bin/shellcheck

DEPENDENCY CHAIN
ln -s /home/cwood/Documents/apps/spack/bin/spack /home/cwood/bin/spack

PYTHON
ln -s /home/cwood/.local/bin/pip         /home/cwood/bin/pip
pip install autopep8 --user
ln -s /home/cwood/.local/bin/autopep8    /home/cwood/bin/autopep8
pip install ansible --user
ln -s /home/cwood/.local/bin/ansible     /home/cwood/bin/ansible
pip install pycallgraph --user
ln -s /home/cwood/.local/bin/pycallgraph /home/cwood/bin/pycallgraph
#gprof2dot, downloaded and put in apps
ln -s /home/cwood/Documents/apps/gprof2dot/gprof2dot.py /home/cwood/bin/gprof2dot.py
#FORTRAN documentation tool
pip install ford --user
#FORTRAN formatter (make pretty)
pip install fprettify --user
