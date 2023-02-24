if [ $# -eq 0 ]; then
	echo "No build arguments provided!"
	echo "    Use '--all --release' for prod releases."
	echo "    Valid arguments:"
	echo "        --all                = Build all IVI nuget packages and application installers. Unit tests will be run automatically."
	echo "        --ivi                = Build all IVI nuget packages. Unit tests will be run automatically."
	echo "        --ivi-interface      = Build all IVI interface nuget packages. Unit tests will be run automatically."
	echo "        --test-ivi           = Run IVI unit tests without building. Nuget_Release build only. Must have already been built."
	echo "        --test-ivi-interface = Run IVI Interfaces unit tests without building. Nuget_Release build only. Must have already been built."
	echo "        --no-clean           = Skip the clean step before building. Unchanged projects will not be rebuilt."
	echo "        --no-test            = Disable running any unit tests."
	echo "        --release            = Update all application versions before building. Use for final and RC releases."
	echo "        --release-alpha      = Update all application versions to alpha before building."
	echo "        --release-beta       = Update all application versions to alpha before building."
	echo "        --unrelease          = Restore projects and other versioned files to original state. Performs git checkout --"
	echo "        --no-ansi            = Do not output ANSI color sequences. Useful for clean log output or non-ANSI terminals."
	echo "        --log-file           = Override default build output log file. Usage: --log-file [path/filename]"
	echo ""
	exit 1
else
	echo -e "Testing"
