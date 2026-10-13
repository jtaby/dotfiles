#!/bin/zsh
# Build and run Darkroom from the current git worktree without opening Xcode.
# fish and zsh wrap this script as dr.
#
#   darkroom.zsh   Pick where to run the app: this Mac, a connected iPhone or
#                  iPad, or an iOS simulator. Then build the app, run it there,
#                  and show its console.
#
# Builds go to <worktree>/darkroom-app/DerivedData-CommandLine, so they don't
# collide with Xcode. The first build in a new worktree clones the Swift
# packages from the main checkout instead of fetching them again.
#
# In a terminal, the build shows as a live view of at most DR_VIEW_LINES lines.
# Press v to read all of the build output so far in less. Ctrl-C stops the build.
#
# The app gets the launch arguments and environment variables that the HSL
# scheme enables in Xcode. The console shows all of its output, newest at the
# bottom, and keeps it in DerivedData-CommandLine/last-console.log. Type to
# filter it. Press ? in the console for all of its keys, which _dr_help lists.

# Most terminal lines that the live build view uses, including its status line.
DR_VIEW_LINES=20
# Seconds that the live view waits for a key press before it reads new output.
DR_VIEW_REFRESH=0.2
# Most error lines that a failed build prints under its summary.
DR_FAILURE_LINES=15
# Exit status of a build that Ctrl-C stopped: 128 + SIGINT, like a shell.
DR_STOPPED_STATUS=130
# Seconds that a stopped build or app gets to end before it is killed.
DR_STOP_GRACE=10
# Seconds between checks while the script waits for a process to end.
DR_POLL_INTERVAL=0.2
# Prompt for less. In a less prompt, a backslash keeps : and . literal.
DR_PAGER_PROMPT='Build output so far\. q\: back to the build, G\: newest lines, F\: follow \(Ctrl-X stops\)'

# Most lines that the console keeps for filtering. The log file keeps all lines.
DR_CONSOLE_LINES=200000
# Folder for the console lines that Ctrl-S saves. The environment can set it.
DR_SAVE_DIR=${DR_SAVE_DIR:-$HOME/Desktop}
# Height of the destination list, as fzf --height takes it. ~ shrinks the
# list when there are fewer destinations.
DR_PICKER_HEIGHT='~70%'
# Remembers the last destination, so the list starts on it next time.
DR_LAST_DESTINATION=${XDG_CACHE_HOME:-$HOME/.cache}/darkroom/last-destination

# Full path of this script, for the console key bindings that call it again.
DR_SCRIPT=${0:A}

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

# _dr_setup
# Sets DR_ROOT, DR_APP_DIR, and DR_DERIVED for the current worktree, and
# exports DEVELOPER_DIR for xcodebuild, devicectl, and simctl.
_dr_setup() {
  DR_ROOT=$(git rev-parse --show-toplevel 2>/dev/null) || {
    print -u2 "Not in a git worktree"
    return 1
  }
  DR_APP_DIR=$DR_ROOT/darkroom-app
  if [[ ! -d $DR_APP_DIR/HSL.xcworkspace ]]; then
    print -u2 "No darkroom-app/HSL.xcworkspace in $DR_ROOT"
    return 1
  fi
  DR_DERIVED=$DR_APP_DIR/DerivedData-CommandLine
  DEVELOPER_DIR=$(_dr_developer_dir) || return 1
  export DEVELOPER_DIR
}

# _dr_build <sdk-dir-suffix> <destination> <platform-name>
# Sets REPLY to the path of the built Darkroom.app on success. It runs in the
# current shell, not in $(...), so its Ctrl-C handling can stop the build and
# clean up before the script exits.
_dr_build() {
  local products_dir=$1 destination=$2 platform=$3
  local root=$DR_ROOT app_dir=$DR_APP_DIR developer_dir=$DEVELOPER_DIR
  local derived=$DR_DERIVED
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

# _dr_destinations
# Prints one tab-separated line per place that can run the app: kind (mac,
# device, or simulator), ID, name, type, and details. This Mac comes first, then
# reachable iPhones, then reachable iPads (USB before network), then iOS
# simulators: booted ones first, then the newest iOS versions.
_dr_destinations() {
  print -r -- "mac"$'\t'"mac"$'\t'"My Mac"$'\t'"Mac"$'\t'"Mac Catalyst · macOS $(sw_vers -productVersion)"

  local json=$(mktemp -t darkroom-devices)
  xcrun devicectl list devices --json-output $json >/dev/null 2>&1
  jq -r '
    [.result.devices[]?
      | select(.hardwareProperties.reality == "physical")
      | select(.hardwareProperties.platform == "iOS")
      | select(.connectionProperties.transportType != null)]
    | sort_by(.hardwareProperties.deviceType != "iPhone",
              .connectionProperties.transportType != "wired",
              .deviceProperties.name)
    | .[]
    | (if .hardwareProperties.deviceType == "iPad" then "iPadOS" else "iOS" end) as $os
    | (if .connectionProperties.transportType == "wired" then "USB" else "Network" end) as $link
    | ["device", .identifier, .deviceProperties.name, .hardwareProperties.deviceType,
       "\(.hardwareProperties.marketingName) · \($os) \(.deviceProperties.osVersionNumber) · \($link)"]
    | join("\t")' $json 2>/dev/null
  rm -f $json

  xcrun simctl list devices available --json 2>/dev/null | jq -r '
    [.devices | to_entries[]
      | select(.key | test("SimRuntime\\.iOS-"))
      | (.key | capture("iOS-(?<v>[0-9-]+)$").v | split("-") | map(tonumber)) as $version
      | .value[]
      | {udid, name, $version, booted: (.state == "Booted"),
         ipad: (.deviceTypeIdentifier | test("iPad"))}]
    | sort_by((.booted | not), (.version | map(-.)), .ipad, .name)
    | .[]
    | ["simulator", .udid, .name, "Simulator",
       "iOS \(.version | map(tostring) | join("."))\(if .booted then " · Booted" else "" end)"]
    | join("\t")'
}

# _dr_pick
# Lists the destinations in fzf and sets DR_KIND, DR_ID, and DR_NAME to the
# one that the user picks. The list starts on the last destination.
_dr_pick() {
  local -a rows=("${(@f)$(_dr_destinations)}") fields lines
  local row last choice
  local -i type_width name_width selected=1 i
  for row in $rows; do
    fields=("${(@ps:\t:)row}")
    (( ${#fields[4]} > type_width )) && type_width=${#fields[4]}
    (( ${#fields[3]} > name_width )) && name_width=${#fields[3]}
  done
  [[ -r $DR_LAST_DESTINATION ]] && last=$(<$DR_LAST_DESTINATION)
  for (( i = 1; i <= $#rows; i++ )); do
    fields=("${(@ps:\t:)rows[i]}")
    [[ $fields[2] == "$last" ]] && selected=i
    # fzf shows only the 4th field: the type, name, and details in columns.
    lines+=("${(pj:\t:)fields[1,3]}"$'\t\e[2m'"${(r:type_width:)fields[4]}"$'\e[0m  '"${(r:name_width:)fields[3]}"$'  \e[2m'"$fields[5]"$'\e[0m')
  done

  choice=$(print -rl -- $lines | fzf --ansi --no-sort --exact --layout=reverse \
    --height=$DR_PICKER_HEIGHT --delimiter='\t' --with-nth=4 \
    --prompt='Run Darkroom on: ' --header='enter: build and run · esc: cancel' \
    --bind="load:pos($selected)") || return 1
  fields=("${(@ps:\t:)choice}")
  DR_KIND=$fields[1] DR_ID=$fields[2] DR_NAME=$fields[3]
  mkdir -p ${DR_LAST_DESTINATION:h} && print -r -- $DR_ID > $DR_LAST_DESTINATION
}

# _dr_scheme_launch
# Sets DR_APP_ARGS and DR_APP_ENV (NAME=value items) to the launch arguments
# and environment variables that the HSL scheme enables, so the app runs like
# it does from Xcode.
_dr_scheme_launch() {
  local scheme=$DR_APP_DIR/HSL.xcworkspace/xcshareddata/xcschemes/HSL.xcscheme
  local arguments='//LaunchAction/CommandLineArguments/CommandLineArgument[@isEnabled="YES"]'
  local variables='//LaunchAction/EnvironmentVariables/EnvironmentVariable[@isEnabled="YES"]'
  local -i i count
  DR_APP_ARGS=() DR_APP_ENV=()
  [[ -r $scheme ]] || return 0
  count=$(xmllint --xpath "count($arguments)" $scheme 2>/dev/null)
  for (( i = 1; i <= count; i++ )); do
    # Xcode splits each argument into words like a shell does.
    DR_APP_ARGS+=(${(Q)${(z)"$(xmllint --xpath "string(($arguments)[$i]/@argument)" $scheme)"}})
  done
  count=$(xmllint --xpath "count($variables)" $scheme 2>/dev/null)
  for (( i = 1; i <= count; i++ )); do
    DR_APP_ENV+=("$(xmllint --xpath "string(($variables)[$i]/@key)" $scheme)=$(xmllint --xpath "string(($variables)[$i]/@value)" $scheme)")
  done
}

# Opens the app that shows simulators: Simulator in older Xcode versions,
# DeviceHub from Xcode 27.
_dr_show_simulators() {
  local viewer
  for viewer in $DEVELOPER_DIR/Applications/Simulator.app $DEVELOPER_DIR:h/Applications/DeviceHub.app; do
    if [[ -d $viewer ]]; then
      open -a $viewer
      return
    fi
  done
}

# _dr_launch <app> <log>
# Installs the app on the destination if necessary. Then starts it in the
# background, in a process group of its own, and writes all of its output to
# the log. Sets REPLY to the process group ID. The group ends when the app ends.
_dr_launch() {
  local app=$1 log=$2 bundle_id executable
  local -a command
  _dr_scheme_launch

  # NSUnbufferedIO=YES makes Foundation write print() output immediately, as
  # it does in Xcode. Without it, output to a file comes in large blocks.
  case $DR_KIND in
    mac)
      executable=$(/usr/libexec/PlistBuddy -c 'Print :CFBundleExecutable' $app/Contents/Info.plist)
      # Quit a running copy first, like Xcode does, so the new build is the one that runs.
      if pkill -x $executable 2>/dev/null; then
        while pgrep -x $executable >/dev/null; do sleep $DR_POLL_INTERVAL; done
      fi
      command=(env NSUnbufferedIO=YES $DR_APP_ENV $app/Contents/MacOS/$executable $DR_APP_ARGS)
      ;;
    device)
      bundle_id=$(/usr/libexec/PlistBuddy -c 'Print :CFBundleIdentifier' $app/Info.plist)
      print -u2 "Installing on $DR_NAME"
      xcrun devicectl device install app --device $DR_ID $app >/dev/null || return 1
      # devicectl removes the DEVICECTL_CHILD_ prefix and gives the variables
      # to the app. It sends the signals that it gets to the app.
      command=(env NSUnbufferedIO=YES DEVICECTL_CHILD_NSUnbufferedIO=YES ${DR_APP_ENV/#/DEVICECTL_CHILD_}
        xcrun devicectl device process launch --console --terminate-existing
        --device $DR_ID $bundle_id -- $DR_APP_ARGS)
      ;;
    simulator)
      bundle_id=$(/usr/libexec/PlistBuddy -c 'Print :CFBundleIdentifier' $app/Info.plist)
      print -u2 "Starting $DR_NAME"
      xcrun simctl bootstatus $DR_ID -b >/dev/null || return 1
      _dr_show_simulators
      print -u2 "Installing on $DR_NAME"
      xcrun simctl install $DR_ID $app || return 1
      # simctl removes the SIMCTL_CHILD_ prefix and gives the variables to the
      # app. It sends the signals that it gets to the app.
      command=(env NSUnbufferedIO=YES SIMCTL_CHILD_NSUnbufferedIO=YES ${DR_APP_ENV/#/SIMCTL_CHILD_}
        xcrun simctl launch --console --terminate-running-process $DR_ID $bundle_id $DR_APP_ARGS)
      ;;
  esac

  print -u2 "Launching Darkroom on $DR_NAME"
  : > $log
  # simctl --console stops following the app at the end of its input, so the
  # input must stay open. The terminal is not a possible input, because the
  # console reads the keys from it. The launch command opens this pipe for both
  # reading and writing, so the pipe has a writer and never ends.
  local input=$DR_DERIVED/console-input
  rm -f $input && mkfifo $input || return 1
  # monitor gives the app a process group of its own, so _dr_stop can signal
  # all of it. &! keeps zsh from printing a job number.
  () {
    setopt local_options monitor
    (
      $command <> $input >> $log 2>&1
      print -r -- "── Darkroom ended with exit status $? ──" >> $log
    ) </dev/null &!
  }
  REPLY=$!
}

# _dr_stop <group-id>
# Sends SIGTERM to the process group of the app. Kills the group if it is
# still running after DR_STOP_GRACE seconds.
_dr_stop() {
  local group=$1
  kill -TERM -- -$group 2>/dev/null || return 0
  local -i deadline=$(( SECONDS + DR_STOP_GRACE ))
  while kill -0 -- -$group 2>/dev/null && (( SECONDS < deadline )); do
    sleep $DR_POLL_INTERVAL
  done
  kill -KILL -- -$group 2>/dev/null
  return 0
}

# _dr_console <log> <title>
# Shows the log in fzf until the user presses Ctrl-C. The notes at the top of
# this script list the keys.
_dr_console() {
  local log=$1 title=$2
  local again="zsh -f ${(q)DR_SCRIPT}"
  # Scrolling back turns on tracking, so the line in focus stays in place when
  # new lines come in. Going back to the newest line turns tracking off, so the
  # view follows new lines again. The prompt shows the state, and the bindings
  # read it from FZF_PROMPT.
  local pause='transform:[[ $FZF_PROMPT == *paused* ]] || print "toggle-track+change-prompt:Filter (paused): "'
  local resume='transform:(( FZF_POS == 1 )) && [[ $FZF_PROMPT == *paused* ]] && print "toggle-track+change-prompt:Filter: "'
  # ? shows the help when the filter is empty. In a filter, it is a character.
  local help="transform:[[ -n \$FZF_QUERY ]] && print 'put(?)' || print 'execute($again _help)'"
  local keys='?: help · ctrl-y: copy · ctrl-s: save to a file · end: newest line · ctrl-c: stop app'
  DR_LOG=$log DR_TITLE=$title FZF_DEFAULT_COMMAND="tail -n +1 -F ${(q)log}" fzf \
    --with-shell='zsh -fc' \
    --tac --no-sort --exact --tail=$DR_CONSOLE_LINES --wrap --no-multi \
    --prompt='Filter: ' --info=inline-right --ghost='words, !hidden, a | b' \
    --header=$keys --footer=$title \
    --bind='enter:ignore,esc:clear-query' \
    --bind="up:up+$pause" \
    --bind="page-up:page-up+$pause" \
    --bind="scroll-up:up+$pause" \
    --bind="down:down+$resume" \
    --bind="page-down:page-down+$resume" \
    --bind="scroll-down:down+$resume" \
    --bind="end:first+$resume" \
    --bind="?:$help" \
    --bind="ctrl-y:transform-footer:$again _export copy {*f}" \
    --bind="ctrl-s:transform-footer:$again _export save {*f}"
  return 0
}

# _dr_export <copy|save> <matches-file>
# Runs from the console's Ctrl-Y and Ctrl-S. Copies to the clipboard, or saves
# to a file, the lines that match the filter. With no filter, it uses the full
# log. Prints the console title with a short report, for the fzf footer.
_dr_export() {
  local action=$1 matches=$2 source=$DR_LOG what file report
  local -i count
  if [[ -n $FZF_QUERY ]]; then
    # --tac lists the newest line first. Put the lines back in log order.
    source=$(mktemp -t darkroom-console)
    tail -r $matches > $source
    count=$(wc -l < $source)
    what="$count matching line${${count:#1}:+s}"
  else
    count=$(wc -l < $source)
    what="the full log ($count line${${count:#1}:+s})"
  fi

  if (( count == 0 )); then
    report="No lines to $action"
  elif [[ $action == copy ]]; then
    pbcopy < $source
    report="Copied $what"
  else
    file=$DR_SAVE_DIR/darkroom-console-$(date +%Y%m%d-%H%M%S).log
    mkdir -p $DR_SAVE_DIR && cp $source $file
    report="Saved $what to ${file/#$HOME/~}"
  fi
  [[ $source != $DR_LOG ]] && rm -f $source
  print -r -- "$DR_TITLE · $report"
}

# _dr_help
# Runs from the console's ? key. Shows the console keys on the full terminal
# until the user presses a key.
_dr_help() {
  local bold=$'\e[1m' dim=$'\e[2m' plain=$'\e[0m'
  print -n $'\e[H\e[2J'
  print -r -- "${bold}Console keys${plain} ${dim}· $DR_TITLE${plain}

  ${bold}Type${plain}          Filter the lines. A line must contain all of the words.
                Lowercase words match any case.
                  !word   hide the lines that contain word
                  a | b   show the lines that contain a or b
                  ^word   show the lines that start with word
  ${bold}Esc${plain}           Clear the filter.
  ${bold}Up, PgUp${plain}      Scroll back. The prompt shows \"paused\", and new lines
                do not move the view.
  ${bold}Down, PgDn${plain}    Scroll forward. On the newest line, the view follows
                new lines again.
  ${bold}End${plain}           Go to the newest line and follow new lines.
  ${bold}Ctrl-Y${plain}        Copy the lines that match the filter to the clipboard.
                With no filter, copy the full log.
  ${bold}Ctrl-S${plain}        Save the same lines to a file in ${DR_SAVE_DIR/#$HOME/~}.
  ${bold}Ctrl-C${plain}        Stop the app and end the session.
  ${bold}?${plain}             Show this help. In a filter, ? is a usual character.

  Full log: ${DR_LOG/#$HOME/~}

${dim}Press any key to go back to the console.${plain}"
  read -sk 1 </dev/tty
}

dr() {
  if [[ ! -t 0 || ! -t 1 ]]; then
    print -u2 "dr needs a terminal"
    return 1
  fi
  _dr_setup || return 1
  # Esc in the list cancels without an error.
  _dr_pick || return 0

  case $DR_KIND in
    mac) _dr_build Debug-maccatalyst 'platform=macOS,variant=Mac Catalyst' 'Mac Catalyst' ;;
    device) _dr_build Debug-iphoneos 'generic/platform=iOS' iOS ;;
    simulator)
      # Boot the simulator while the app builds.
      xcrun simctl boot $DR_ID >/dev/null 2>&1 &!
      _dr_build Debug-iphonesimulator 'generic/platform=iOS Simulator' 'iOS Simulator'
      ;;
  esac || return 1
  local app=$REPLY log=$DR_DERIVED/last-console.log

  _dr_launch $app $log || return 1
  local group=$REPLY
  # Closing the terminal also stops the app.
  trap "_dr_stop $group; exit 1" HUP TERM
  _dr_console $log "${DR_ROOT:t} on $DR_NAME"

  if kill -0 -- -$group 2>/dev/null; then
    _dr_stop $group
    print -u2 "Stopped Darkroom on $DR_NAME"
  else
    print -u2 "Darkroom ended on $DR_NAME"
  fi
  print -u2 "Console log: ${log#$PWD/}"
}

# Run only when executed, not when sourced, so tests can call the functions.
if [[ $ZSH_EVAL_CONTEXT == toplevel ]]; then
  case $1 in
    '') dr ;;
    _export) shift; _dr_export "$@" ;;
    _help) _dr_help ;;
    *) print -u2 "Usage: ${0:t}  (no arguments: pick a destination, then build, run, and show the console)"; exit 2 ;;
  esac
fi
