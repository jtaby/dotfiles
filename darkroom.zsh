#!/bin/zsh
# Build and launch Darkroom from the current git worktree without opening Xcode.
# fish and zsh wrap this script as drmac and drphone.
#
#   darkroom.zsh mac [--logs]              Build for Mac Catalyst, then open the app.
#   darkroom.zsh phone [--logs] [device]   Build for iOS, install on a device, then launch.
#                               device: part of the name or a UDID. Default: the
#                               first connected iPhone/iPad (USB first).
#
# --logs keeps the app attached to the terminal and prints its stdout/stderr.
# Builds go to <worktree>/darkroom-app/DerivedData-CommandLine, so they don't
# collide with Xcode. The first build in a new worktree clones the Swift
# packages from the main checkout instead of fetching them again.

_dr_developer_dir() {
  if [[ -n $DEVELOPER_DIR ]]; then
    print -r -- $DEVELOPER_DIR
    return
  fi
  local selected=$(xcode-select -p 2>/dev/null)
  if [[ $selected == *.app/Contents/Developer ]]; then
    print -r -- $selected
    return
  fi
  # xcode-select points at the Command Line Tools: use the newest Xcode app.
  local app
  for app in /Applications/Xcode*.app(N/On); do
    if [[ -x $app/Contents/Developer/usr/bin/xcodebuild ]]; then
      print -r -- $app/Contents/Developer
      return
    fi
  done
  print -u2 "No Xcode app found in /Applications"
  return 1
}

# Reads xcodebuild output and prints one short line per build step, such as
# "[Maier] Compiling Kernel.swift". Errors and warnings print in full, once each.
_dr_progress() {
  local color=0
  [[ -t 1 ]] && color=1
  awk -v color=$color '
    BEGIN {
      quote = sprintf("%c", 39)
      # Before any step runs, xcodebuild can spend 20s or more on these phases.
      phase["Resolve Package Graph"] = "Resolving Swift packages"
      phase["Prepare packages"] = "Preparing Swift packages"
      phase["ComputeTargetDependencyGraph"] = "Planning the build"
      phase["CreateBuildDescription"] = "Creating the build description"
      verb["SwiftCompile"] = "Compiling"
      verb["CompileC"] = "Compiling"
      verb["CompileMetalFile"] = "Compiling"
      verb["CompileXCStrings"] = "Compiling"
      verb["CompileStoryboard"] = "Compiling"
      verb["CompileXIB"] = "Compiling"
      verb["CompileAssetCatalog"] = "Compiling"
      verb["CompileAssetCatalogVariant"] = "Compiling"
      verb["SwiftEmitModule"] = "Emitting module"
      verb["PhaseScriptExecution"] = "Running"
      verb["Ld"] = "Linking"
      verb["CodeSign"] = "Signing"
    }
    function show(text) { print text; fflush() }
    function paint(code, text) { return color ? "\033[" code "m" text "\033[0m" : text }

    /^\/.+:[0-9]+:[0-9]+: (fatal )?error: / || /^(xcodebuild: )?error: / {
      if (!seen[$0]++) show(paint("31", $0))
      next
    }
    /^\/.+:[0-9]+:[0-9]+: warning: / {
      if (!seen[$0]++) show(paint("33", $0))
      next
    }
    $0 in phase {
      show(phase[$0])
      next
    }
    /^\*\* BUILD / || /^(Fetching from |Creating working copy |Checking out )/ {
      show($0)
      next
    }
    !($1 in verb) { next }
    {
      # "Step [options] [paths] (in target 'Name' from project 'Project')"
      line = $0
      target = ""
      at = index(line, " (in target ")
      if (at) {
        split(substr(line, at), part, quote)
        target = part[2]
        line = substr(line, 1, at - 1)
      }
      # Keep escaped spaces in paths inside one field.
      gsub(/\\ /, "\001", line)
      count = split(line, field, " ")
      name = ""
      if ($1 == "PhaseScriptExecution") {
        name = field[2]
      } else {
        for (i = count; i > 1; i--) {
          if (field[i] ~ /\//) {
            name = field[i]
            sub(/\/Versions\/A$/, "", name)
            sub(/.*\//, "", name)
            break
          }
        }
      }
      gsub(/\001/, " ", name)
      show((target == "" ? "" : paint("2", "[" target "]") " ") verb[$1] (name == "" ? "" : " " name))
    }
  '
}

# _dr_build <sdk-dir-suffix> <destination>
# Prints the path to the built Darkroom.app on success.
_dr_build() {
  local products_dir=$1 destination=$2
  local root
  root=$(git rev-parse --show-toplevel 2>/dev/null) || {
    print -u2 "Not in a git worktree"
    return 1
  }
  local app_dir=$root/darkroom-app
  if [[ ! -d $app_dir/HSL.xcworkspace ]]; then
    print -u2 "No darkroom-app/HSL.xcworkspace in $root"
    return 1
  fi

  local developer_dir
  developer_dir=$(_dr_developer_dir) || return 1

  local derived=$app_dir/DerivedData-CommandLine
  local main_root=$(git -C $root rev-parse --path-format=absolute --git-common-dir)
  local seed=${main_root:h}/darkroom-app/DerivedData-CommandLine/SourcePackages
  if [[ ! -d $derived/SourcePackages && -d $seed && ${seed:A} != ${derived:A}/SourcePackages ]]; then
    print -u2 "Cloning Swift packages from ${seed:h:h:h}"
    mkdir -p $derived && cp -cR $seed $derived/SourcePackages
  fi

  local log=$derived/last-build.log
  mkdir -p $derived
  print -u2 "Building HSL ($destination) in $root"
  print -u2 "Full log: $log"

  local start=$SECONDS
  # Show build progress as it happens; the full output stays in the log.
  (
    cd $app_dir &&
    DEVELOPER_DIR=$developer_dir NSUnbufferedIO=YES xcodebuild build \
      -workspace HSL.xcworkspace -scheme HSL -configuration Debug \
      -destination $destination \
      -derivedDataPath ./DerivedData-CommandLine \
      -xcconfig ./CommandLine-Debug.xcconfig \
      -skipMacroValidation -skipPackagePluginValidation
  ) 2>&1 | tee $log | _dr_progress >&2
  local build_status=$pipestatus[1]

  if (( build_status != 0 )); then
    print -u2 "\nBuild failed after $(( SECONDS - start ))s. Last lines of $log:"
    tail -n 40 $log >&2
    return $build_status
  fi
  print -u2 "Built in $(( SECONDS - start ))s"
  print -r -- $derived/Build/Products/$products_dir/Darkroom.app
}

drmac() {
  local logs=0
  [[ $1 == --logs ]] && logs=1

  local app
  app=$(_dr_build Debug-maccatalyst 'platform=macOS,variant=Mac Catalyst') || return 1

  # Quit a running copy first, like Xcode does, so the new build is the one that opens.
  local executable=$(/usr/libexec/PlistBuddy -c 'Print :CFBundleExecutable' $app/Contents/Info.plist)
  if pkill -x $executable 2>/dev/null; then
    while pgrep -x $executable >/dev/null; do sleep 0.2; done
  fi

  if (( logs )); then
    print -u2 "Running $app (Ctrl-C to quit)"
    $app/Contents/MacOS/$executable
  else
    open $app
  fi
}

drphone() {
  local logs=0
  [[ $1 == --logs ]] && { logs=1; shift }
  local query=$1

  local developer_dir
  developer_dir=$(_dr_developer_dir) || return 1

  # Pick the device before building, so a missing phone fails fast.
  local json=$(mktemp -t drphone)
  DEVELOPER_DIR=$developer_dir xcrun devicectl list devices --json-output $json >/dev/null 2>&1
  local device
  device=$(jq -r --arg q "$query" '
    [.result.devices[]
      | select(.hardwareProperties.reality == "physical")
      | select(.hardwareProperties.platform == "iOS")
      | select($q == ""
          or (.deviceProperties.name | ascii_downcase | contains($q | ascii_downcase))
          or .hardwareProperties.udid == $q
          or .identifier == $q)
      | select(.connectionProperties.transportType != null)]
    | sort_by(.connectionProperties.tunnelState != "connected",
              .connectionProperties.transportType != "wired")
    | first // empty
    | "\(.identifier)\t\(.deviceProperties.name)"' $json)
  rm -f $json
  if [[ -z $device ]]; then
    print -u2 "No reachable iOS device${query:+ matching \"$query\"}. Connect it, unlock it, and try again."
    return 1
  fi
  local device_id=${device%%$'\t'*} device_name=${device#*$'\t'}
  print -u2 "Device: $device_name"

  local app
  app=$(_dr_build Debug-iphoneos 'generic/platform=iOS') || return 1
  local bundle_id=$(/usr/libexec/PlistBuddy -c 'Print :CFBundleIdentifier' $app/Info.plist)

  print -u2 "Installing on $device_name"
  DEVELOPER_DIR=$developer_dir xcrun devicectl device install app --device $device_id $app >/dev/null || return 1

  print -u2 "Launching $bundle_id"
  local launch_args=(--device $device_id --terminate-existing)
  (( logs )) && launch_args+=(--console)
  DEVELOPER_DIR=$developer_dir xcrun devicectl device process launch $launch_args $bundle_id
}

case $1 in
  mac) shift; drmac "$@" ;;
  phone) shift; drphone "$@" ;;
  *) print -u2 "Usage: ${0:t} mac [--logs] | phone [--logs] [device]"; exit 2 ;;
esac
