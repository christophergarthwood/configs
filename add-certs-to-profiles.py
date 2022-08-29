#!/usr/bin/python

import os
import time
import sys
import stat
import commands
import threading
try:
	from PyQt4 import QtGui, QtCore
except ImportError:
	sys.exit(0)

# The graphical progress window
class MainWindow(QtGui.QMainWindow):
        def __init__(self, *args):
                apply(QtGui.QMainWindow.__init__, (self,) + args)
                self.setWindowTitle("Updating your certificate database...")
                self.mainWidget=QtGui.QWidget(self)
                self.setCentralWidget(self.mainWidget)
                self.mainLayout=QtGui.QVBoxLayout(self.mainWidget)

        def addWidget(self, widget):
                self.mainLayout.addWidget(widget)

        def getMain(self):
                return self.mainWidget

# A thread for the progress window
class ProgressThread(threading.Thread):
        def run(self):
                self.a = QtGui.QApplication(sys.argv)
                self.w = MainWindow()
                self.w.setGeometry(100,100,80,80)

                message = QtGui.QLabel("The system needs to update your certificate database. This may take a while. Please do not open firefox, mozilla, or thunderbird until this process is complete, or you risk corrupting your profile.", self.w.getMain())
                self.progressbar = QtGui.QProgressBar(self.w.getMain())
                self.progressbar.setMaximum(self.steps)
                self.w.addWidget(message)
                self.w.addWidget(self.progressbar)
		self.w.show()

		# QT is event based, so we are assigning a timeout based event
		# so that we can update the window every so often
                self.timer = QtCore.QTimer()
                self.a.connect( self.timer, QtCore.SIGNAL("timeout()"), self.slotTimeout )
                self.timer.start( 500 )

		# Tell the application to quit when the last window is closed, and
		# start the application
                self.a.connect(self.a, QtCore.SIGNAL("lastWindowClosed()"),
                        self.a, QtCore.SLOT("quit()"))
                self.a.exec_()

        def setval(self,val):
                self.val = val

	def setSteps(self,val):
		self.steps = val

        def slotTimeout(self):
                self.progressbar.setValue(self.val)

        def exit_loop(self):
                self.a.exit()

# Reads profiles.ini to find a list of profile directories.
# Will omit any currently-locked (in use) profiles.
# Will omit any profiles not containing an NSS database.
def findprofiles(prof, ini):
	plist = []
	try:
		f = open(prof + ini)
	except:
		return plist
	isrel = 0
	line = f.readline()
	while line:
		indx = line.find('IsRelative=')
		if indx >= 0:
			isrel = line[indx+11]

		indx = line.find('Path=')
		if indx >= 0:
			path = line[indx+5:-1]
			if isrel == '1':
				path = prof + path
			if os.path.isfile(path + '/secmod.db') and not os.path.islink(path + '/lock'):
				plist.append(path)

		line = f.readline()
	f.close()
	return plist

def main(args):
	home = os.getenv('HOME')
	configfile = home + "/.dod-pki-profile-conf"
	userversionfile = home + "/.dod-pki-version"
	versionfile = "/usr/local/dod-pki/version"

	filehandle = open(versionfile)
	newversion = filehandle.read()
	filehandle.close()

	# Get the last version of the package that has been run from the userversionfile
	# if the file doesn't exist, this is the first time the script has been run,
	# create the file, and write the version to it
	if os.path.isfile(userversionfile):	
		filehandle = open(userversionfile)
		userversion = filehandle.read()
		filehandle.close()
	else:
		filehandle = open(userversionfile, "w")
		filehandle.write(newversion)
		filehandle.close()
		userversion = newversion

	# check for the existance of the configfile, create one if it doesn't exist
	if not os.path.isfile(configfile):
		filehandle = open(configfile, "w")
		filehandle.write('')
		filehandle.close()

	# Check if the package's version is higher than the user's version, if so, empty
	# the config file, and update the user's version
	if int(newversion) > int(userversion):
		filehandle = open(configfile, "w")
		filehandle.write('')
		filehandle.close()
		filehandle = open(userversionfile, "w")
		filehandle.write(newversion)
		filehandle.close()

	# Read the profile directories from the config file
	filehandle = open(configfile)
	updatedprofiles = filehandle.read().split('\n')

	filehandle = open(configfile, 'a')

	# Find the lists of currently-unlocked profiles.
	mozillaprofiles = findprofiles(home + '/.mozilla/firefox/', 'profiles.ini')
	thunderbirdprofiles = findprofiles(home + '/.thunderbird/', 'profiles.ini')

	# Skip profiles that have already been updated this round
	for a in updatedprofiles:
		if a in mozillaprofiles:
			mozillaprofiles.remove(a)
		if a in thunderbirdprofiles:
			thunderbirdprofiles.remove(a)

	# Create the graphical progress window in a seperate thread
	appstarted = 0
	if len(mozillaprofiles) > 0 or len(thunderbirdprofiles) > 0:
		app = ProgressThread()
		app.setSteps(len(mozillaprofiles) + len(thunderbirdprofiles))
	        app.setval(0)
	        app.start()
		appstarted = 1

	# Step through the profiles, modifying them, and adding certificates to them;
	# update the graphical progress window after each profile is finished
	i = 1
	for a in mozillaprofiles:
		os.system('/bin/bash /usr/local/dod-pki/modify-certs.sh "' + a + '" "nss" "' + newversion + '" "user"')
		os.system('/bin/bash /usr/local/dod-pki/add-certs.sh "' + a + '" "nss" "all"')
		filehandle.write(a + "\n")
		app.setval(i)
		i = i + 1

	for a in thunderbirdprofiles:
		os.system('/bin/bash /usr/local/dod-pki/modify-certs.sh "' + a + '" "nss" "' + newversion + '" "user"')
		os.system('/bin/bash /usr/local/dod-pki/add-certs.sh "' + a + '" "nss" "all"')
		filehandle.write(a + "\n")
		app.setval(i)
		i = i + 1

	# Tell the application to exit if it is running
	if appstarted == 1:
		app.exit_loop()

if __name__=="__main__":
	main(sys.argv)
