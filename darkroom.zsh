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
#
# In a terminal, the build shows as a live view of at most DR_VIEW_LINES lines.
# Press v to read all of the build output so far in less. Ctrl-C stops the build.

# Most terminal lines that the live build view uses, including its status line.
DR_VIEW_LINES=20
# Seconds that the live view waits for a key press before it reads new output.
DR_VIEW_REFRESH=0.2
# Most error lines that a failed build prints under its summary.
DR_FAILURE_LINES=15
# Exit status of a build that Ctrl-C stopped: 128 + SIGINT, like a shell.
DR_STOPPED_STATUS=130
# Seconds that a stopped build gets to cancel before it is killed.
DR_STOP_GRACE=10
# Prompt for less. In a less prompt, a backslash keeps : and . literal.
DR_PAGER_PROMPT='Build output so far\. q\: back to the build, G\: newest lines, F\: follow \(Ctrl-X stops\)'

# Patterns for the lines that _dr_progress prints.
DR_STEP_PATTERN='\[*'
DR_WARNING_PATTERN='/*: warning: *'
DR_ERROR_PATTERN='(/*: error: *|/*: fatal error: *|error: *|xcodebuild: error: *)'

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
  awk '
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

    /^\/.+:[0-9]+:[0-9]+: (fatal )?error: / || /^(xcodebuild: )?error: / || /^\/.+:[0-9]+:[0-9]+: warning: / {
      if (!seen[$0]++) show($0)
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
      show((target == "" ? "" : "[" target "] ") verb[$1] (name == "" ? "" : " " name))
    }
  '
}

# _dr_paint <line> [width]
# Sets REPLY to the line in terminal colors: errors red, warnings yellow, and
# step targets dim. Paths under the current directory become relative, and a
# width cuts the line to that many characters.
_dr_paint() {
  local line=${1//$PWD\/}
  (( $# > 1 )) && line=${line[1,$2]}
  if [[ $1 == ${~DR_ERROR_PATTERN} ]]; then
    REPLY=$'\e[31m'$line$'\e[0m'
  elif [[ $1 == ${~DR_WARNING_PATTERN} ]]; then
    REPLY=$'\e[33m'$line$'\e[0m'
  elif [[ $line == \[*\]* ]]; then
    REPLY=$'\e[2m'${line%%\]*}$']\e[0m'${line#*\]}
  else
    REPLY=$line
  fi
}

# _dr_duration <seconds>
# Sets REPLY to text such as "42s" or "3m 5s".
_dr_duration() {
  if (( $1 < 60 )); then
    REPLY="$1s"
  else
    REPLY="$(( $1 / 60 ))m $(( $1 % 60 ))s"
  fi
}

# _dr_tally <steps> <warnings> <errors>
# Sets REPLY to text such as "412 steps · 3 warnings". Leaves out zero counts
# of warnings and errors. ${${n:#1}:+s} adds a plural "s" unless n is 1.
_dr_tally() {
  local steps=$1 warnings=$2 errors=$3
  REPLY="$steps step${${steps:#1}:+s}"
  (( warnings )) && REPLY+=" · $warnings warning${${warnings:#1}:+s}"
  (( errors )) && REPLY+=" · $errors error${${errors:#1}:+s}"
  return 0
}

# _dr_watch <build-pid> <progress-file> <status-file> <title>
# Shows the build as a live view of at most DR_VIEW_LINES terminal lines: a
# status line, then the newest lines of the progress file. The view draws over
# itself in place. v opens all of the output so far in less, and Ctrl-C stops
# the build. Removes the view when the build ends and returns the exit status
# that the build wrote to the status file.
#
# The build must run in a process group of its own, with the build PID as the
# group ID. Then Ctrl-C in the terminal goes only to this shell and to less.
_dr_watch() {
  setopt local_options local_traps
  local build_pid=$1 progress=$2 status_file=$3 title=$4
  local hint='v: all output' gap='   '
  local -i tty feed
  exec {tty}<>/dev/tty {feed}<$progress
  local saved_tty=$(stty -g <&$tty)

  local -a recent size
  local line pending key elapsed body shown up
  local -i steps warnings errors drawn running stopped height width start=$SECONDS
  # Closing the terminal also stops the build. It does not keep running alone.
  trap 'stopped=1' INT HUP TERM
  {
    stty -icanon -echo <&$tty
    print -nu $tty $'\e[?25l'
    while true; do
      running=0
      kill -0 $build_pid 2>/dev/null && running=1

      # Read the lines that the build added since the last pass.
      while read -r -u $feed line; do
        line=$pending$line
        pending=
        [[ $line == ${~DR_STEP_PATTERN} ]] && (( steps++ ))
        [[ $line == ${~DR_WARNING_PATTERN} ]] && (( warnings++ ))
        [[ $line == ${~DR_ERROR_PATTERN} ]] && (( errors++ ))
        recent+=("$line")
      done
      # A partial line at the end of the file waits for the rest of it.
      pending+=$line
      (( running && ! stopped )) || break

      # Stay one line under the terminal height, so the view never scrolls
      # the terminal, and one column short of the width, so no line wraps.
      size=($(stty size <&$tty))
      height=$(( size[1] - 1 < DR_VIEW_LINES ? size[1] - 1 : DR_VIEW_LINES ))
      (( height < 2 )) && height=2
      width=$(( size[2] - 1 ))
      (( $#recent > height - 1 )) && recent=("${(@)recent[-(height - 1),-1]}")

      _dr_duration $(( SECONDS - start ))
      elapsed=$REPLY
      _dr_tally $steps $warnings $errors
      body="$title · $elapsed · $REPLY"
      if (( ${#body} + ${#gap} + ${#hint} <= width )); then
        body=$'\e[1m'$body$'\e[0m'$gap$'\e[2m'$hint$'\e[0m'
      else
        body=$'\e[1m'${body[1,width]}$'\e[0m'
      fi
      for line in "${recent[@]}"; do
        _dr_paint "$line" $width
        body+=$'\n'$REPLY
      done

      if [[ $body != "$shown" ]]; then
        # Go back to the first line of the old view, draw over it, and clear
        # what is left of it. The terminal shows the whole frame at once.
        up=
        (( drawn )) && up=$'\e['$drawn'A'
        print -rnu $tty -- $'\e[?2026h\r'$up${body//$'\n'/$'\e[K\n'}$'\e[K\n\e[J\e[?2026l'
        drawn=$(( ${#recent} + 1 ))
        shown=$body
      fi

      key=
      read -t $DR_VIEW_REFRESH -k 1 -u $tty key
      if [[ $key == [vV] ]]; then
        # less uses the alternate screen, so the view is still there after q.
        # Ctrl-C in less stops F mode only. It does not stop the build.
        print -nu $tty $'\e[?25h'
        trap '' INT
        less +G -Ps"$DR_PAGER_PROMPT" $progress <&$tty >&$tty
        trap 'stopped=1' INT
        print -nu $tty $'\e[?25l'
        shown=
      fi
    done
  } always {
    (( drawn )) && print -rnu $tty -- $'\r\e['$drawn$'A\e[J'
    print -nu $tty $'\e[?25h'
    stty $saved_tty <&$tty
    exec {tty}>&- {feed}<&-
  }

  if (( stopped )); then
    # xcodebuild cancels the build on SIGINT. Kill the group if it is slow.
    print -nu2 'Stopping the build…'
    kill -INT -- -$build_pid 2>/dev/null
    local -i deadline=$(( SECONDS + DR_STOP_GRACE ))
    while kill -0 -- -$build_pid 2>/dev/null && (( SECONDS < deadline )); do
      sleep $DR_VIEW_REFRESH
    done
    kill -KILL -- -$build_pid 2>/dev/null
    print -nu2 $'\r\e[K'
    return $DR_STOPPED_STATUS
  fi
  [[ -s $status_file ]] || return 1
  return $(<$status_file)
}

# _dr_xcodebuild <app-dir> <developer-dir> <destination>
# CommonDependencies has a local .package(path:), so the originHash in
# Package.resolved includes the checkout path. In a worktree the hash does not
# match, and without -onlyUsePackageVersionsFromResolvedFile xcodebuild
# resolves all packages again to their newest versions and writes them to
# Package.resolved. Those versions can fail to resolve together.
_dr_xcodebuild() (
  cd $1 &&
  DEVELOPER_DIR=$2 NSUnbufferedIO=YES xcodebuild build \
    -workspace HSL.xcworkspace -scheme HSL -configuration Debug \
    -destination $3 \
    -derivedDataPath ./DerivedData-CommandLine \
    -xcconfig ./CommandLine-Debug.xcconfig \
    -onlyUsePackageVersionsFromResolvedFile \
    -skipMacroValidation -skipPackagePluginValidation
)

# _dr_build <sdk-dir-suffix> <destination> <platform-name>
# Sets REPLY to the path of the built Darkroom.app on success. It runs in the
# current shell, not in $(...), so its Ctrl-C handling can stop the build and
# clean up before the script exits.
_dr_build() {
  local products_dir=$1 destination=$2 platform=$3
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

  # last-build.log keeps all of the xcodebuild output. last-build-progress.log
  # keeps the short lines from _dr_progress.
  local log=$derived/last-build.log progress=$derived/last-build-progress.log
  local title="Building ${root:t} for $platform"
  mkdir -p $derived
  : > $progress

  local start=$SECONDS build_status
  if [[ -t 2 ]]; then
    # The build runs in the background, so the live view can read key presses.
    # monitor gives the build a process group of its own, so Ctrl-C in the
    # terminal does not reach it. &! keeps zsh from printing a job number.
    local status_file=$(mktemp -t darkroom-build)
    () {
      setopt local_options monitor
      (
        _dr_xcodebuild $app_dir $developer_dir $destination 2>&1 | tee $log | _dr_progress >> $progress
        print $pipestatus[1] > $status_file
      ) </dev/null &!
    }
    _dr_watch $! $progress $status_file $title
    build_status=$?
    rm -f $status_file
  else
    print -u2 -r -- $title
    _dr_xcodebuild $app_dir $developer_dir $destination 2>&1 | tee $log | _dr_progress | tee -a $progress >&2
    build_status=$pipestatus[1]
  fi

  _dr_duration $(( SECONDS - start ))
  local elapsed=$REPLY
  local -a output=("${(@f)$(<$progress)}")
  local -a errors=("${(@M)output:#${~DR_ERROR_PATTERN}}")
  _dr_tally ${#${(M)output:#${~DR_STEP_PATTERN}}} ${#${(M)output:#${~DR_WARNING_PATTERN}}} $#errors
  local tally=$REPLY

  if (( build_status == DR_STOPPED_STATUS )); then
    print -u2 "Build stopped after $elapsed"
    return $build_status
  fi
  if (( build_status != 0 )); then
    print -u2 "Build failed after $elapsed · $tally"
    local error
    if (( $#errors )); then
      for error in "${(@)errors[1,DR_FAILURE_LINES]}"; do
        if [[ -t 2 ]]; then
          _dr_paint "$error"
          error=$REPLY
        fi
        print -u2 -r -- $error
      done
      (( $#errors > DR_FAILURE_LINES )) && print -u2 "…and $(( $#errors - DR_FAILURE_LINES )) more"
    else
      tail -n $DR_FAILURE_LINES $log >&2
    fi
    print -u2 "All output: less ${progress#$PWD/}"
    print -u2 "xcodebuild log: ${log#$PWD/}"
    return $build_status
  fi
  print -u2 "Built ${root:t} for $platform in $elapsed · $tally"
  print -u2 "All output: less ${progress#$PWD/}"
  REPLY=$derived/Build/Products/$products_dir/Darkroom.app
}

drmac() {
  local logs=0
  [[ $1 == --logs ]] && logs=1

  _dr_build Debug-maccatalyst 'platform=macOS,variant=Mac Catalyst' 'Mac Catalyst' || return 1
  local app=$REPLY

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

  _dr_build Debug-iphoneos 'generic/platform=iOS' iOS || return 1
  local app=$REPLY
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
