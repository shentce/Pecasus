#!/bin/bash
set -e

EchoInColor()
{
	str="$1"
	color="$2"
	if [[ "$color" == "" ]]; then
		color="0;32"
	fi
	color="\033[${color}m"

	if [[ "$ENABLE_ANSI" == "true" ]]; then
		echo -e "${color}${str}\033[0m"
	else
		echo -e "${str}"
	fi
}

ProgressStart()
{
	EchoInColor "$(date '+%Y-%m-%d %H:%M:%S') - Starting: $1..." "0;32"
}

ProgressEnd()
{
	EchoInColor "$(date '+%Y-%m-%d %H:%M:%S') - Finished: $1" "0;32"
	echo -e ""
}

GetFirstFile()
{
	while [[ $# -gt 0 ]]
	do
		local filePath="$1"
		if [[ -f "$filePath" ]]; then
			echo "$filePath"
			return
		fi
		shift
	done

	echo ""
	return
}

Initialize()
{
	local progressName="Initialize"
	ProgressStart "$progressName"

	if [[ "$IS_BUILD" == "true" ]]; then
		# List of MSBuild paths. Preferred paths listed first.
		MSBuildPath=$(GetFirstFile \
					"C:\Program Files (x86)\Microsoft Visual Studio\2019\Professional\MSBuild\Current\Bin\MSBuild.exe" \
					"C:\Program Files (x86)\Microsoft Visual Studio\2019\BuildTools\MSBuild\Current\Bin\MSBuild.exe" \
					"C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\MSBuild\Current\Bin\MSBuild.exe" \
					)

		if [[ "${MSBuildPath}" == "" ]]; then
			echo "Could not find MSBuild.exe in any expected paths."
			echo "Ensure MS Build Tools or Visual Studio 2019 Professional is installed. (MSBuild 16+ required)"
			exit 1
		fi

		echo "Using MSBuild: ${MSBuildPath}"
	fi

	if [[ "$IS_BUILD_VS2017" == "true" ]]; then
		# List of MSBuild paths. Preferred paths listed first.
		MSBuildPath_VS2017=$(GetFirstFile \
					"C:\Program Files (x86)\Microsoft Visual Studio\2017\Professional\MSBuild\15.0\Bin\MSBuild.exe" \
					"C:\Program Files (x86)\Microsoft Visual Studio\2017\BuildTools\MSBuild\15.0\Bin\MSBuild.exe" \
					"C:\Program Files (x86)\Microsoft Visual Studio\2017\Community\MSBuild\15.0\Bin\MSBuild.exe" \
					)

		if [[ "${MSBuildPath_VS2017}" == "" ]]; then
			echo "Could not find MSBuild.exe in any expected paths."
			echo "Ensure MS Build Tools or Visual Studio 2017 Professional is installed."
			exit 1
		fi

		echo "Using MSBuild (VS2017): ${MSBuildPath_VS2017}"
	fi

	if [[ "$ENABLE_UNIT_TESTS" == "true" ]]; then
		# List of \vstest.console.exe paths. Preferred paths listed first.
		VsTestPath=$(GetFirstFile \
					"C:\Program Files (x86)\Microsoft Visual Studio\2019\Professional\Common7\IDE\Extensions\TestPlatform\vstest.console.exe" \
					"C:\Program Files (x86)\Microsoft Visual Studio\2019\BuildTools\Common7\IDE\Extensions\TestPlatform\vstest.console.exe" \
					"C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\Common7\IDE\Extensions\TestPlatform\vstest.console.exe" \
					)

		if [[ "${VsTestPath}" == "" ]]; then
			echo "Could not find vstest.console.exe in any expected paths."
			echo "Ensure MS Build Tools 2019 or Visual Studio 2019 Professional is installed."
			exit 1
		fi

		echo "Using VsTest: ${VsTestPath}"
	fi

	ProgressEnd "$progressName"
}

PrepareProjectsForRelease()
{
	local releaseType="$1"
	if [[ "$releaseType" == "" ]]; then
		releaseType="production"
	fi
	local progressName="Prepare Projects for '${releaseType}' Release (versioning)"
	ProgressStart "$progressName"

	if [[ "$releaseType" == "production" ]]; then
		dotnet BuildTools/PrepareProjects/exe/PrepareProjects.dll -b ./
	else
		dotnet BuildTools/PrepareProjects/exe/PrepareProjects.dll -b ./ -s ${releaseType} -d $DYNAMIC_VERSION
	fi

	ProgressEnd "$progressName"
}

UnPrepareProjectsForRelease()
{
	local progressName="UN-Prepare Projects for Release (versioning)"
	ProgressStart "$progressName"

	echo "Restoring *.csproj and AssemblyInfo.cs files from git..."
	git checkout -- '*/PteCcsCommonLibraryNuget.targets'
	git checkout -- '*/AssemblyInfo.cs'
	git checkout -- '*/*.csproj'
	cd ..

	ProgressEnd "$progressName"
}

BuildSolution()
{
	local slnFile="$1"
	local buildVersion="$2"
	local msBuildPath="${MSBuildPath}"
	if [[ "$buildVersion" == "2017" ]]; then
		local msBuildPath="${MSBuildPath_VS2017}"
	fi
	local progressName="Build solution file '${slnFile}'"
	ProgressStart "$progressName"

	# -m for parallel build

	echo "Restoring '${slnFile}' nuget dependencies..."
	"${msBuildPath}" "${slnFile}" -m -target:Restore -property:Configuration=Nuget_Release

	if [[ "$ENABLE_CLEAN" == "true" ]]; then
		echo "Cleaning '${slnFile}' projects..."
		"${msBuildPath}" "${slnFile}" -m -target:Clean -property:Configuration=Nuget_Release
	fi

	echo "Building '${slnFile}' projects..."
	"${msBuildPath}" "${slnFile}" -m -target:Build -property:Configuration=Nuget_Release

	ProgressEnd "$progressName"
}

TestIvi()
{
	local slnFile="CommonCoreIvi.IVI.Interop.sln"
	local progressName="Run unit tests for solution file '${slnFile}'"

	ProgressStart "$progressName"

	echo "No unit tests defined for '${slnFile}'"
	#echo "Running unit tests for '.NETFramework,Version=v4.6.2'..."
	#"${VsTestPath}" IVI/*/*/*Tests/bin/Nuget_Release/net462/*Tests.dll --Parallel --Framework:".NETFramework,Version=v4.6.2"

	ProgressEnd "$progressName"
}

TestIviInterface()
{
	local slnFile="CommonCoreIvi.IVI.Interface.sln"
	local progressName="Run unit tests for solution file '${slnFile}'"

	ProgressStart "$progressName"

	echo "No unit tests defined for '${slnFile}'"
	#echo "Running unit tests for '.NETFramework,Version=v4.6.2'..."
	#"${VsTestPath}" IVI/*/*/*Tests/bin/Nuget_Release/net462/*Tests.dll --Parallel --Framework:".NETFramework,Version=v4.6.2"

	ProgressEnd "$progressName"
}

BuildIvi()
{
	local slnFile="ConsumeProcessor/ConsumeProcessor.sln"
	BuildSolution "${slnFile}"
}

BuildIviInterface()
{
	local slnFile="CommonCoreIvi.IVI.Interface.sln"
	BuildSolution "${slnFile}"
}

# main
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
	POSITIONAL=()
	dateStr=$(date '+%Y-%m-%d_%H%M%S')
	BUILD_LOG_FILE="build-output_${dateStr}.log"
	ENABLE_UNIT_TESTS=true
	ENABLE_ANSI=true
	ENABLE_CLEAN=true
	ORIGINAL_ARGUMENTS="$@"
	DYNAMIC_VERSION=$(dotnet BuildTools/GenerateVersion/exe/GenerateVersion.dll -d)
	echo "Dynamic Version: $DYNAMIC_VERSION"

	while [[ $# -gt 0 ]]
	do
		key="$1"

		case $key in
			--ivi)
				RUN_INITIALIZE=true
				LIST_OUTPUT=true
				IS_BUILD=true
				BUILD_IVI=true
				RUN_IVI_UNIT_TESTS=true
				
				shift
				;;
			--ivi-interface)
				RUN_INITIALIZE=true
				LIST_OUTPUT=true
				IS_BUILD=true
				BUILD_IVI_INTERFACE=true
				shift
				;;
			--no-test)
				ENABLE_UNIT_TESTS=false
				shift
				;;
			--test-ivi)
				RUN_INITIALIZE=true
				ENABLE_UNIT_TESTS=true
				RUN_IVI_UNIT_TESTS=true
				shift
				;;
			--test-ivi-interface)
				RUN_INITIALIZE=true
				ENABLE_UNIT_TESTS=true
				RUN_IVI_INTERFACE_UNIT_TESTS=true
				shift
				;;
			--all)
				RUN_INITIALIZE=true
				LIST_OUTPUT=true
				IS_BUILD=true
				BUILD_IVI=true
				BUILD_IVI_INTERFACE=true
				shift
				;;
			--log-file)
				BUILD_LOG_FILE="$2"
				shift 2
				;;
			--release)
				IS_RELEASE=true
				shift
				;;
			--release-alpha)
				IS_RELEASE=true
				RELEASE_TYPE=alpha
				shift
				;;
			--release-beta)
				IS_RELEASE=true
				RELEASE_TYPE=beta
				shift
				;;
			--unrelease)
				IS_UNRELEASE=true
				shift
				;;
			--no-clean)
				ENABLE_CLEAN=false
				shift
				;;
			--no-ansi)
				ENABLE_ANSI=false
				shift
				;;
			*)    # unknown option
				POSITIONAL+=("$1") # save it in an array for later
				shift
				;;
		esac
	done
	set -- "${POSITIONAL[@]}" # restore positional parameters

	echo -e "Logging build output to: ${BUILD_LOG_FILE}"
	echo ""
	{
		echo "Build arguments: ${ORIGINAL_ARGUMENTS}"
		echo ""

		if [[ "$RUN_INITIALIZE" == "true" ]]; then
			Initialize
		fi

		if [[ "$IS_RELEASE" == "true" ]]; then
			PrepareProjectsForRelease "${RELEASE_TYPE}"
		fi

		if [[ "$BUILD_IVI_INTERFACE" == "true" ]]; then
			BuildIviInterface
		fi

		if [[ "$ENABLE_UNIT_TESTS" == "true" ]]; then
			if [[ "$BUILD_IVI_INTERFACE" == "true" ]] || [[ "$RUN_IVI_INTERFACE_UNIT_TESTS" == "true" ]]; then
				TestIviInterface
			fi
		fi

		if [[ "$BUILD_IVI" == "true" ]]; then
			BuildIvi
		fi

		if [[ "$ENABLE_UNIT_TESTS" == "true" ]]; then
			if [[ "$BUILD_IVI" == "true" ]] || [[ "$RUN_IVI_UNIT_TESTS" == "true" ]]; then
				TestIvi
			fi
		fi

		if [[ "$IS_UNRELEASE" == "true" ]]; then
			UnPrepareProjectsForRelease
		fi

		echo ""
		EchoInColor "Build complete!" "1;32"
		if [[ "$LIST_OUTPUT" == "true" ]]; then
			EchoInColor "Build output can be found in the 'NugetPackages' and/or 'ApplicationPackages' directories:" "1;32"
			if [ -d "NugetPackages" ]; then
				echo ""
				EchoInColor "NugetPackages:"
				ls -goh "NugetPackages"
			fi
			if [ -d "ApplicationPackages" ]; then
				echo ""
				EchoInColor "ApplicationPackages:"
				ls -goh "ApplicationPackages"
			fi
		fi
	} 2>&1 
	
	#| tee "${BUILD_LOG_FILE}"

	echo ""
	EchoInColor "Build output logged to: ${BUILD_LOG_FILE}"
fi

exit 0
