#!/bin/zsh
# Build and run an iOS app from the current git worktree without opening Xcode.
# fish and zsh wrap this script as run.
#
#   run.zsh        Pick where to run the app: this Mac (with Mac Catalyst), a
#                  connected iPhone or iPad, or an iOS simulator. Then build the
#                  app, run it there, and show its console.
#   run.zsh setup  Answer the setup questions for the repository again.
#
# The settings of a repository are in RUN_CONFIG_NAME in its git folder, so all
# worktrees of the repository use them and git does not track them. If there
# are no settings, the script asks the setup questions first. The settings
# file lists the settings, and _run_configure writes it.
#
# Builds go to a folder in the worktree, DerivedData-CommandLine next to the
# Xcode workspace or project by default, so they don't collide with Xcode. The
# first build in a new worktree clones the Swift packages from the main
# checkout instead of fetching them again.
#
# In a terminal, the build shows as a live view of at most RUN_VIEW_LINES lines.
# Press v to read all of the build output so far in less. Ctrl-C stops the build.
#
# The app gets the launch arguments and environment variables that its scheme
# enables in Xcode. The console shows all of its output, newest at the bottom,
# and keeps it in last-console.log in the build folder. Type to filter it.
# Press ? in the console for all of its keys, which _run_help lists.
#
# An app cannot launch on a locked iPhone or iPad. If the device is locked when
# the app is ready, the script waits until you unlock it. It shows a desktop
# notification and rings the terminal bell, so you know that it waits.

# Most terminal lines that the live build view uses, including its status line.
RUN_VIEW_LINES=20
# Seconds that the live view waits for a key press before it reads new output.
RUN_VIEW_REFRESH=0.2
# Most error lines that a failed build prints under its summary.
RUN_FAILURE_LINES=15
# Exit status of a build that Ctrl-C stopped: 128 + SIGINT, like a shell.
RUN_STOPPED_STATUS=130
# Seconds that a stopped build or app gets to end before it is killed.
RUN_STOP_GRACE=10
# Seconds between checks while the script waits for a process to end.
RUN_POLL_INTERVAL=0.2
# Seconds between checks while the script waits for a locked device. Each
# check also takes about 0.5s.
RUN_UNLOCK_POLL=1
# Seconds that one check of the device lock state can take before it fails.
RUN_LOCK_CHECK_TIMEOUT=10
# Prompt for less. In a less prompt, a backslash keeps : and . literal.
RUN_PAGER_PROMPT='Build output so far\. q\: back to the build, G\: newest lines, F\: follow \(Ctrl-X stops\)'

# Most lines that the console keeps for filtering. The log file keeps all lines.
RUN_CONSOLE_LINES=200000
# Folder for the console lines that Ctrl-S saves. The environment can set it.
RUN_SAVE_DIR=${RUN_SAVE_DIR:-$HOME/Desktop}
# Height of the destination list and of the setup questions, as fzf --height
# takes it. ~ shrinks the list when there are fewer lines.
RUN_PICKER_HEIGHT='~70%'
# Remembers the last destination, so the list starts on it next time.
RUN_LAST_DESTINATION=${XDG_CACHE_HOME:-$HOME/.cache}/run/last-destination
# Name of the settings file in the git folder of a repository.
RUN_CONFIG_NAME=run.conf
# Default name of the build folder, next to the Xcode workspace or project.
RUN_DERIVED_NAME=DerivedData-CommandLine
# Folder levels under the worktree root that setup searches for Xcode
# workspaces and projects.
RUN_PROJECT_SEARCH_DEPTH=3

# Full path of this script, for the console key bindings that call it again.
RUN_SCRIPT=${0:A}

# Patterns for the lines that _run_progress prints.
RUN_STEP_PATTERN='\[*'
RUN_WARNING_PATTERN='/*: warning: *'
RUN_ERROR_PATTERN='(/*: error: *|/*: fatal error: *|error: *|xcodebuild: error: *)'

_run_developer_dir() {
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
# "[MyApp] Compiling ContentView.swift". Errors and warnings print in full,
# once each.
_run_progress() {
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

# _run_paint <line> [width]
# Sets REPLY to the line in terminal colors: errors red, warnings yellow, and
# step targets dim. Paths under the current directory become relative, and a
# width cuts the line to that many characters.
_run_paint() {
  local line=${1//$PWD\/}
  (( $# > 1 )) && line=${line[1,$2]}
  if [[ $1 == ${~RUN_ERROR_PATTERN} ]]; then
    REPLY=$'\e[31m'$line$'\e[0m'
  elif [[ $1 == ${~RUN_WARNING_PATTERN} ]]; then
    REPLY=$'\e[33m'$line$'\e[0m'
  elif [[ $line == \[*\]* ]]; then
    REPLY=$'\e[2m'${line%%\]*}$']\e[0m'${line#*\]}
  else
    REPLY=$line
  fi
}

# _run_duration <seconds>
# Sets REPLY to text such as "42s" or "3m 5s".
_run_duration() {
  if (( $1 < 60 )); then
    REPLY="$1s"
  else
    REPLY="$(( $1 / 60 ))m $(( $1 % 60 ))s"
  fi
}

# _run_tally <steps> <warnings> <errors>
# Sets REPLY to text such as "412 steps · 3 warnings". Leaves out zero counts
# of warnings and errors. ${${n:#1}:+s} adds a plural "s" unless n is 1.
_run_tally() {
  local steps=$1 warnings=$2 errors=$3
  REPLY="$steps step${${steps:#1}:+s}"
  (( warnings )) && REPLY+=" · $warnings warning${${warnings:#1}:+s}"
  (( errors )) && REPLY+=" · $errors error${${errors:#1}:+s}"
  return 0
}

# _run_watch <build-pid> <progress-file> <status-file> <title>
# Shows the build as a live view of at most RUN_VIEW_LINES terminal lines: a
# status line, then the newest lines of the progress file. The view draws over
# itself in place. v opens all of the output so far in less, and Ctrl-C stops
# the build. Removes the view when the build ends and returns the exit status
# that the build wrote to the status file.
#
# The build must run in a process group of its own, with the build PID as the
# group ID. Then Ctrl-C in the terminal goes only to this shell and to less.
_run_watch() {
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
        [[ $line == ${~RUN_STEP_PATTERN} ]] && (( steps++ ))
        [[ $line == ${~RUN_WARNING_PATTERN} ]] && (( warnings++ ))
        [[ $line == ${~RUN_ERROR_PATTERN} ]] && (( errors++ ))
        recent+=("$line")
      done
      # A partial line at the end of the file waits for the rest of it.
      pending+=$line
      (( running && ! stopped )) || break

      # Stay one line under the terminal height, so the view never scrolls
      # the terminal, and one column short of the width, so no line wraps.
      size=($(stty size <&$tty))
      height=$(( size[1] - 1 < RUN_VIEW_LINES ? size[1] - 1 : RUN_VIEW_LINES ))
      (( height < 2 )) && height=2
      width=$(( size[2] - 1 ))
      (( $#recent > height - 1 )) && recent=("${(@)recent[-(height - 1),-1]}")

      _run_duration $(( SECONDS - start ))
      elapsed=$REPLY
      _run_tally $steps $warnings $errors
      body="$title · $elapsed · $REPLY"
      if (( ${#body} + ${#gap} + ${#hint} <= width )); then
        body=$'\e[1m'$body$'\e[0m'$gap$'\e[2m'$hint$'\e[0m'
      else
        body=$'\e[1m'${body[1,width]}$'\e[0m'
      fi
      for line in "${recent[@]}"; do
        _run_paint "$line" $width
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
      read -t $RUN_VIEW_REFRESH -k 1 -u $tty key
      if [[ $key == [vV] ]]; then
        # less uses the alternate screen, so the view is still there after q.
        # Ctrl-C in less stops F mode only. It does not stop the build.
        print -nu $tty $'\e[?25h'
        trap '' INT
        less +G -Ps"$RUN_PAGER_PROMPT" $progress <&$tty >&$tty
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
    local -i deadline=$(( SECONDS + RUN_STOP_GRACE ))
    while kill -0 -- -$build_pid 2>/dev/null && (( SECONDS < deadline )); do
      sleep $RUN_VIEW_REFRESH
    done
    kill -KILL -- -$build_pid 2>/dev/null
    print -nu2 $'\r\e[K'
    return $RUN_STOPPED_STATUS
  fi
  [[ -s $status_file ]] || return 1
  return $(<$status_file)
}

# _run_xcodebuild <destination>
# Builds the scheme for the destination with the settings of the repository.
# A local .package(path:) puts the checkout path into the originHash in
# Package.resolved. In a worktree the hash does not match, and without
# -onlyUsePackageVersionsFromResolvedFile xcodebuild resolves all packages
# again to their newest versions and writes them to Package.resolved. Those
# versions can fail to resolve together.
_run_xcodebuild() (
  local -a project=(-workspace $RUN_PROJECT) xcconfig
  [[ $RUN_PROJECT == *.xcodeproj ]] && project=(-project $RUN_PROJECT)
  [[ -n $RUN_XCCONFIG ]] && xcconfig=(-xcconfig $RUN_XCCONFIG)
  cd ${RUN_PROJECT:h} &&
  NSUnbufferedIO=YES xcodebuild build $project -scheme $RUN_SCHEME \
    -configuration $RUN_CONFIGURATION -destination $1 \
    -derivedDataPath $RUN_DERIVED $xcconfig \
    -onlyUsePackageVersionsFromResolvedFile \
    -skipMacroValidation -skipPackagePluginValidation
)

# _run_find_repository
# Sets RUN_ROOT to the root of the current worktree, and RUN_CONFIG_FILE to the
# settings file in the git folder that all worktrees of the repository share.
_run_find_repository() {
  RUN_ROOT=$(git rev-parse --show-toplevel 2>/dev/null) || {
    print -u2 "Not in a git worktree"
    return 1
  }
  RUN_CONFIG_FILE=$(git -C $RUN_ROOT rev-parse --path-format=absolute --git-common-dir)/$RUN_CONFIG_NAME
}

# _run_read_settings
# Reads the name=value lines of RUN_CONFIG_FILE into RUN_SETTINGS. Skips empty
# lines and lines that start with #. A missing file gives no settings.
_run_read_settings() {
  typeset -gA RUN_SETTINGS=()
  [[ -r $RUN_CONFIG_FILE ]] || return 0
  local line
  for line in "${(@f)$(<$RUN_CONFIG_FILE)}"; do
    [[ $line == (|\#*) || $line != *=* ]] && continue
    RUN_SETTINGS[${line%%=*}]=${line#*=}
  done
}

# _run_default_derived <project>
# Sets REPLY to the default build folder, relative to RUN_ROOT, for a project
# path that is relative to RUN_ROOT: RUN_DERIVED_NAME next to the project.
_run_default_derived() {
  REPLY=$RUN_DERIVED_NAME
  [[ $1 == */* ]] && REPLY=${1:h}/$REPLY
}

# _run_setup
# Gets the settings of the repository and sets RUN_ROOT, RUN_PROJECT, RUN_SCHEME,
# RUN_APP_NAME, RUN_CONFIGURATION, RUN_XCCONFIG, RUN_MAC_CATALYST, and RUN_DERIVED.
# Asks the setup questions first if the repository has no settings. Exports
# DEVELOPER_DIR for xcodebuild, devicectl, and simctl.
_run_setup() {
  _run_find_repository || return 1
  if [[ ! -e $RUN_CONFIG_FILE ]]; then
    print -u2 "run has no settings for ${RUN_ROOT:t} yet."
    _run_configure || {
      print -u2 "Settings not saved"
      return 1
    }
  fi
  _run_read_settings
  local key
  for key in project scheme app; do
    if [[ -z $RUN_SETTINGS[$key] ]]; then
      print -u2 "No $key setting in ${RUN_CONFIG_FILE/#$HOME/~}. Fix it with: run setup"
      return 1
    fi
  done
  RUN_PROJECT=$RUN_ROOT/$RUN_SETTINGS[project]
  if [[ ! -e $RUN_PROJECT ]]; then
    print -u2 "No $RUN_SETTINGS[project] in $RUN_ROOT. Change the project with: run setup"
    return 1
  fi
  RUN_SCHEME=$RUN_SETTINGS[scheme]
  RUN_APP_NAME=$RUN_SETTINGS[app]
  RUN_CONFIGURATION=${RUN_SETTINGS[configuration]:-Debug}
  RUN_XCCONFIG=${RUN_SETTINGS[xcconfig]:+$RUN_ROOT/$RUN_SETTINGS[xcconfig]}
  RUN_MAC_CATALYST=${RUN_SETTINGS[mac_catalyst]:-no}
  _run_default_derived $RUN_SETTINGS[project]
  RUN_DERIVED=$RUN_ROOT/${RUN_SETTINGS[derived_data]:-$REPLY}
  DEVELOPER_DIR=$(_run_developer_dir) || return 1
  export DEVELOPER_DIR
}

# _run_find_projects
# Prints the paths, relative to RUN_ROOT, of the Xcode workspaces and projects
# in the top RUN_PROJECT_SEARCH_DEPTH folder levels of the worktree. The ones
# with a shared scheme that builds an app come first. In each group,
# workspaces come before projects.
_run_find_projects() {
  local -a found apps others schemes
  local project
  found=(${(f)"$(find $RUN_ROOT -mindepth 1 -maxdepth $RUN_PROJECT_SEARCH_DEPTH \
    \( -name '.*' -o -name 'DerivedData*' -o -name node_modules -o -name Pods \) -prune -o \
    \( -name '*.xcworkspace' -o -name '*.xcodeproj' \) -print -prune 2>/dev/null)"})
  found=(${found#$RUN_ROOT/})
  found=(${(oi)${(M)found:#*.xcworkspace}} ${(oi)found:#*.xcworkspace})
  for project in $found; do
    schemes=($RUN_ROOT/$project/xcshareddata/xcschemes/*.xcscheme(N))
    if (( $#schemes )) && grep -q 'BuildableName = "[^"]*\.app"' $schemes; then
      apps+=($project)
    else
      others+=($project)
    fi
  done
  (( $#found )) && print -rl -- $apps $others
  return 0
}

# _run_scheme_files <project>
# Prints the shared scheme files of a project path that is relative to
# RUN_ROOT. Then prints those of the Xcode projects in the folder of the
# project and in the folders directly under it, which a workspace often holds.
_run_scheme_files() {
  local container=$RUN_ROOT/$1
  local folder=${container:h}
  local -a files=(
    $container/xcshareddata/xcschemes/*.xcscheme(N)
    $folder/*.xcodeproj/xcshareddata/xcschemes/*.xcscheme(N)
    $folder/*/*.xcodeproj/xcshareddata/xcschemes/*.xcscheme(N)
  )
  (( $#files )) && print -rl -- ${(u)files}
  return 0
}

# _run_scheme_file <project> <scheme>
# Sets REPLY to the file of the shared scheme with that name, or fails if the
# project has no such shared scheme.
_run_scheme_file() {
  local file
  for file in ${(f)"$(_run_scheme_files $1)"}; do
    if [[ ${file:t:r} == $2 ]]; then
      REPLY=$file
      return 0
    fi
  done
  return 1
}

# _run_choose <prompt> <header> <default> [<item>...]
# Lists the items in fzf, starting on the default, and sets REPLY to the item
# that the user picks. If no item matches the typed text, Enter uses the text.
# Fails if the user presses Esc.
_run_choose() {
  local prompt=$1 header=$2 default=$3
  shift 3
  local -i start=${argv[(ie)$default]} code
  (( start > $# )) && start=1
  local -a output
  while true; do
    # --print-query prints the typed text, then the item that the user picks.
    output=("${(@f)$( { (( $# )) && print -rl -- "$@" } | fzf --print-query \
      --no-sort --exact --layout=reverse --height=$RUN_PICKER_HEIGHT \
      --prompt="$prompt: " --header=$header --bind="load:pos($start)")}")
    code=$?
    if (( code == 0 )); then
      REPLY=$output[2]
    elif (( code == 1 )); then
      # No item matches the text. With no text, ask again.
      REPLY=$output[1]
      [[ -z $REPLY ]] && continue
    else
      return 1
    fi
    print -u2 -r -- "$prompt: $REPLY"
    return 0
  done
}

# _run_configure
# Asks the setup questions in fzf and writes the answers to RUN_CONFIG_FILE.
# The defaults are the current settings, or values from the scheme. The app
# name and the build configuration come from the scheme without a question.
_run_configure() {
  _run_read_settings
  local project scheme app configuration xcconfig catalyst derived
  local scheme_file container default
  local -a items
  print -u2 "Set up run for ${RUN_ROOT:t}. Type to filter a list, Enter picks, Esc cancels."

  items=(${(f)"$(_run_find_projects)"})
  _run_choose 'Project' 'The Xcode workspace or project that has the app scheme' \
    "$RUN_SETTINGS[project]" $items || return 1
  project=$REPLY
  if [[ ! -e $RUN_ROOT/$project ]]; then
    print -u2 "No $project in $RUN_ROOT"
    return 1
  fi

  items=(${(u)${${(f)"$(_run_scheme_files $project)"}:t}:r})
  default=$RUN_SETTINGS[scheme]
  (( ${items[(Ie)$default]} )) || default=${project:t:r}
  _run_choose 'Scheme' 'The scheme that builds and launches the app' $default $items || return 1
  scheme=$REPLY

  # Container paths in a scheme are relative to the folder of the workspace or
  # project that has the scheme.
  if _run_scheme_file $project $scheme; then
    scheme_file=$REPLY
    local runnable='//LaunchAction/BuildableProductRunnable/BuildableReference'
    app=$(xmllint --xpath "string($runnable/@BuildableName)" $scheme_file 2>/dev/null)
    app=${app%.app}
    configuration=$(xmllint --xpath 'string(//LaunchAction/@buildConfiguration)' $scheme_file 2>/dev/null)
    container=$(xmllint --xpath "string($runnable/@ReferencedContainer)" $scheme_file 2>/dev/null)
    container=${scheme_file:h:h:h:h}/${container#container:}
    grep -q 'SUPPORTS_MACCATALYST = YES' $container/project.pbxproj 2>/dev/null && catalyst=yes
  fi
  if [[ -z $app ]]; then
    items=(${RUN_SETTINGS[app]})
    _run_choose 'App name' 'The name of the app that the scheme builds, without .app. Type it.' \
      "$RUN_SETTINGS[app]" $items || return 1
    app=$REPLY
  fi
  configuration=${configuration:-${RUN_SETTINGS[configuration]:-Debug}}

  # An .xcconfig file that xcodebuild -xcconfig adds to the build. Its settings
  # take priority over the project settings.
  items=(None ${${:-$RUN_ROOT/$project}:h}/*.xcconfig(N))
  items=(${items#$RUN_ROOT/})
  [[ -n $RUN_SETTINGS[xcconfig] ]] && items+=(${RUN_SETTINGS[xcconfig]})
  items=(${(u)items})
  if (( $#items > 1 )); then
    _run_choose 'Extra xcconfig' 'An .xcconfig file that overrides build settings in run builds only' \
      "${RUN_SETTINGS[xcconfig]:-None}" $items || return 1
    xcconfig=${REPLY:#None}
  fi

  default=${RUN_SETTINGS[mac_catalyst]:-${catalyst:-no}}
  _run_choose 'Mac Catalyst' 'Can the app run on this Mac with Mac Catalyst? Then My Mac is a destination.' \
    ${(C)default} Yes No || return 1
  catalyst=${(L)REPLY}
  [[ $catalyst == (yes|no) ]] || catalyst=no

  _run_default_derived $project
  derived=${RUN_SETTINGS[derived_data]:-$REPLY}

  local temporary=$RUN_CONFIG_FILE.new
  print -rl -- \
    "# Settings of the run command for this repository and all of its worktrees." \
    "# Paths are relative to the worktree root. run setup asks the questions again." \
    "" \
    "# The Xcode workspace or project, the scheme, and the build configuration." \
    "project=$project" \
    "scheme=$scheme" \
    "configuration=$configuration" \
    "# The name of the app that the scheme builds, without .app." \
    "app=$app" \
    "# An optional .xcconfig file that overrides build settings in run builds." \
    "xcconfig=$xcconfig" \
    "# yes adds My Mac (Mac Catalyst) to the destinations." \
    "mac_catalyst=$catalyst" \
    "# The build folder. Make sure that git ignores it." \
    "derived_data=$derived" > $temporary && mv $temporary $RUN_CONFIG_FILE || return 1
  print -u2 "Saved the settings to ${RUN_CONFIG_FILE/#$HOME/~}"
}

# _run_build <sdk-suffix> <destination> <platform-name>
# Sets REPLY to the path of the built app on success. The SDK suffix is the
# end of the products folder name, such as iphoneos. It runs in the current
# shell, not in $(...), so its Ctrl-C handling can stop the build and clean up
# before the script exits.
_run_build() {
  local products_dir=$RUN_CONFIGURATION-$1 destination=$2 platform=$3
  local root=$RUN_ROOT derived=$RUN_DERIVED
  local main_root=$(git -C $root rev-parse --path-format=absolute --git-common-dir)
  main_root=${main_root:h}
  local seed=$main_root/${derived#$root/}/SourcePackages
  if [[ ! -d $derived/SourcePackages && -d $seed && ${seed:A} != ${derived:A}/SourcePackages ]]; then
    print -u2 "Cloning Swift packages from $main_root"
    mkdir -p $derived && cp -cR $seed $derived/SourcePackages
  fi

  # last-build.log keeps all of the xcodebuild output. last-build-progress.log
  # keeps the short lines from _run_progress.
  local log=$derived/last-build.log progress=$derived/last-build-progress.log
  local title="Building ${root:t} for $platform"
  mkdir -p $derived
  : > $progress

  local start=$SECONDS build_status
  if [[ -t 2 ]]; then
    # The build runs in the background, so the live view can read key presses.
    # monitor gives the build a process group of its own, so Ctrl-C in the
    # terminal does not reach it. &! keeps zsh from printing a job number.
    local status_file=$(mktemp -t run-build)
    () {
      setopt local_options monitor
      (
        _run_xcodebuild $destination 2>&1 | tee $log | _run_progress >> $progress
        print $pipestatus[1] > $status_file
      ) </dev/null &!
    }
    _run_watch $! $progress $status_file $title
    build_status=$?
    rm -f $status_file
  else
    print -u2 -r -- $title
    _run_xcodebuild $destination 2>&1 | tee $log | _run_progress | tee -a $progress >&2
    build_status=$pipestatus[1]
  fi

  _run_duration $(( SECONDS - start ))
  local elapsed=$REPLY
  local -a output=("${(@f)$(<$progress)}")
  local -a errors=("${(@M)output:#${~RUN_ERROR_PATTERN}}")
  _run_tally ${#${(M)output:#${~RUN_STEP_PATTERN}}} ${#${(M)output:#${~RUN_WARNING_PATTERN}}} $#errors
  local tally=$REPLY

  if (( build_status == RUN_STOPPED_STATUS )); then
    print -u2 "Build stopped after $elapsed"
    return $build_status
  fi
  if (( build_status != 0 )); then
    print -u2 "Build failed after $elapsed · $tally"
    local error
    if (( $#errors )); then
      for error in "${(@)errors[1,RUN_FAILURE_LINES]}"; do
        if [[ -t 2 ]]; then
          _run_paint "$error"
          error=$REPLY
        fi
        print -u2 -r -- $error
      done
      (( $#errors > RUN_FAILURE_LINES )) && print -u2 "…and $(( $#errors - RUN_FAILURE_LINES )) more"
    else
      tail -n $RUN_FAILURE_LINES $log >&2
    fi
    print -u2 "All output: less ${progress#$PWD/}"
    print -u2 "xcodebuild log: ${log#$PWD/}"
    return $build_status
  fi
  print -u2 "Built ${root:t} for $platform in $elapsed · $tally"
  print -u2 "All output: less ${progress#$PWD/}"
  REPLY=$derived/Build/Products/$products_dir/$RUN_APP_NAME.app
}

# _run_destinations
# Prints one tab-separated line per place that can run the app: kind (mac,
# device, or simulator), ID, name, type, and details. This Mac comes first if
# the app runs on it with Mac Catalyst. Then come reachable iPhones, then
# reachable iPads (USB before network), then iOS simulators: booted ones
# first, then the newest iOS versions.
_run_destinations() {
  if [[ $RUN_MAC_CATALYST == yes ]]; then
    print -r -- "mac"$'\t'"mac"$'\t'"My Mac"$'\t'"Mac"$'\t'"Mac Catalyst · macOS $(sw_vers -productVersion)"
  fi

  local json=$(mktemp -t run-devices)
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

# _run_pick
# Lists the destinations in fzf and sets RUN_KIND, RUN_ID, and RUN_NAME to the
# one that the user picks. The list starts on the last destination.
_run_pick() {
  local -a rows=("${(@f)$(_run_destinations)}") fields lines
  local row last choice
  local -i type_width name_width selected=1 i
  for row in $rows; do
    fields=("${(@ps:\t:)row}")
    (( ${#fields[4]} > type_width )) && type_width=${#fields[4]}
    (( ${#fields[3]} > name_width )) && name_width=${#fields[3]}
  done
  [[ -r $RUN_LAST_DESTINATION ]] && last=$(<$RUN_LAST_DESTINATION)
  for (( i = 1; i <= $#rows; i++ )); do
    fields=("${(@ps:\t:)rows[i]}")
    [[ $fields[2] == "$last" ]] && selected=i
    # fzf shows only the 4th field: the type, name, and details in columns.
    lines+=("${(pj:\t:)fields[1,3]}"$'\t\e[2m'"${(r:type_width:)fields[4]}"$'\e[0m  '"${(r:name_width:)fields[3]}"$'  \e[2m'"$fields[5]"$'\e[0m')
  done

  choice=$(print -rl -- $lines | fzf --ansi --no-sort --exact --layout=reverse \
    --height=$RUN_PICKER_HEIGHT --delimiter='\t' --with-nth=4 \
    --prompt="Run $RUN_APP_NAME on: " --header='enter: build and run · esc: cancel' \
    --bind="load:pos($selected)") || return 1
  fields=("${(@ps:\t:)choice}")
  RUN_KIND=$fields[1] RUN_ID=$fields[2] RUN_NAME=$fields[3]
  mkdir -p ${RUN_LAST_DESTINATION:h} && print -r -- $RUN_ID > $RUN_LAST_DESTINATION
}

# _run_scheme_launch
# Sets RUN_APP_ARGS and RUN_APP_ENV (NAME=value items) to the launch arguments
# and environment variables that the scheme enables, so the app runs like it
# does from Xcode. A scheme that is not shared gives none.
_run_scheme_launch() {
  local scheme
  _run_scheme_file ${RUN_PROJECT#$RUN_ROOT/} $RUN_SCHEME && scheme=$REPLY
  local arguments='//LaunchAction/CommandLineArguments/CommandLineArgument[@isEnabled="YES"]'
  local variables='//LaunchAction/EnvironmentVariables/EnvironmentVariable[@isEnabled="YES"]'
  local -i i count
  RUN_APP_ARGS=() RUN_APP_ENV=()
  [[ -r $scheme ]] || return 0
  count=$(xmllint --xpath "count($arguments)" $scheme 2>/dev/null)
  for (( i = 1; i <= count; i++ )); do
    # Xcode splits each argument into words like a shell does.
    RUN_APP_ARGS+=(${(Q)${(z)"$(xmllint --xpath "string(($arguments)[$i]/@argument)" $scheme)"}})
  done
  count=$(xmllint --xpath "count($variables)" $scheme 2>/dev/null)
  for (( i = 1; i <= count; i++ )); do
    RUN_APP_ENV+=("$(xmllint --xpath "string(($variables)[$i]/@key)" $scheme)=$(xmllint --xpath "string(($variables)[$i]/@value)" $scheme)")
  done
}

# Opens the app that shows simulators: Simulator in older Xcode versions,
# DeviceHub from Xcode 27.
_run_show_simulators() {
  local viewer
  for viewer in $DEVELOPER_DIR/Applications/Simulator.app $DEVELOPER_DIR:h/Applications/DeviceHub.app; do
    if [[ -d $viewer ]]; then
      open -a $viewer
      return
    fi
  done
}

# _run_alert <title> <body>
# Shows a desktop notification with OSC 777, which Ghostty supports. Also rings
# the bell: if Ghostty does not have focus, it bounces its Dock icon, and it
# puts a bell in the tab title. In tmux, the notification gets through only if
# allow-passthrough is on.
_run_alert() {
  local notify=$'\e]777;notify;'$1';'$2$'\e\\'
  [[ -n $TMUX ]] && notify=$'\ePtmux;'${notify//$'\e'/$'\e\e'}$'\e\\'
  { print -rn -- $notify$'\a' > /dev/tty } 2>/dev/null
  return 0
}

# _run_device_locked
# Succeeds if the device RUN_ID is locked. Fails if it is unlocked or if
# devicectl cannot get its state, so a failed check does not stop the launch.
_run_device_locked() {
  xcrun devicectl device info lockState --device $RUN_ID --quiet \
    --timeout $RUN_LOCK_CHECK_TIMEOUT --json-output - 2>/dev/null |
    jq -e '.result.passcodeRequired == true' >/dev/null
}

# _run_wait_for_unlock
# If the device RUN_ID is locked, shows an alert and waits until the user
# unlocks it. Ctrl-C stops the wait and the script.
_run_wait_for_unlock() {
  _run_device_locked || return 0
  local start=$SECONDS
  print -u2 "$RUN_NAME is locked. Unlock it to launch $RUN_APP_NAME, or press Ctrl-C to stop."
  _run_alert $RUN_APP_NAME "Unlock $RUN_NAME to launch $RUN_APP_NAME"
  while _run_device_locked; do
    sleep $RUN_UNLOCK_POLL
  done
  _run_duration $(( SECONDS - start ))
  print -u2 "$RUN_NAME unlocked after $REPLY"
}

# _run_launch <app> <log>
# Installs the app on the destination if necessary. Then starts it in the
# background, in a process group of its own, and writes all of its output to
# the log. Sets REPLY to the process group ID. The group ends when the app ends.
_run_launch() {
  local app=$1 log=$2 bundle_id executable
  local -a command
  _run_scheme_launch

  # NSUnbufferedIO=YES makes Foundation write print() output immediately, as
  # it does in Xcode. Without it, output to a file comes in large blocks.
  case $RUN_KIND in
    mac)
      executable=$(/usr/libexec/PlistBuddy -c 'Print :CFBundleExecutable' $app/Contents/Info.plist)
      # Quit a running copy first, like Xcode does, so the new build is the one that runs.
      if pkill -x $executable 2>/dev/null; then
        while pgrep -x $executable >/dev/null; do sleep $RUN_POLL_INTERVAL; done
      fi
      command=(env NSUnbufferedIO=YES $RUN_APP_ENV $app/Contents/MacOS/$executable $RUN_APP_ARGS)
      ;;
    device)
      bundle_id=$(/usr/libexec/PlistBuddy -c 'Print :CFBundleIdentifier' $app/Info.plist)
      print -u2 "Installing on $RUN_NAME"
      xcrun devicectl device install app --device $RUN_ID $app >/dev/null || return 1
      _run_wait_for_unlock
      # devicectl removes the DEVICECTL_CHILD_ prefix and gives the variables
      # to the app. It sends the signals that it gets to the app.
      command=(env NSUnbufferedIO=YES DEVICECTL_CHILD_NSUnbufferedIO=YES ${RUN_APP_ENV/#/DEVICECTL_CHILD_}
        xcrun devicectl device process launch --console --terminate-existing
        --device $RUN_ID $bundle_id -- $RUN_APP_ARGS)
      ;;
    simulator)
      bundle_id=$(/usr/libexec/PlistBuddy -c 'Print :CFBundleIdentifier' $app/Info.plist)
      print -u2 "Starting $RUN_NAME"
      xcrun simctl bootstatus $RUN_ID -b >/dev/null || return 1
      _run_show_simulators
      print -u2 "Installing on $RUN_NAME"
      xcrun simctl install $RUN_ID $app || return 1
      # simctl removes the SIMCTL_CHILD_ prefix and gives the variables to the
      # app. It sends the signals that it gets to the app.
      command=(env NSUnbufferedIO=YES SIMCTL_CHILD_NSUnbufferedIO=YES ${RUN_APP_ENV/#/SIMCTL_CHILD_}
        xcrun simctl launch --console --terminate-running-process $RUN_ID $bundle_id $RUN_APP_ARGS)
      ;;
  esac

  print -u2 "Launching $RUN_APP_NAME on $RUN_NAME"
  : > $log
  # simctl --console stops following the app at the end of its input, so the
  # input must stay open. The terminal is not a possible input, because the
  # console reads the keys from it. The launch command opens this pipe for both
  # reading and writing, so the pipe has a writer and never ends.
  local input=$RUN_DERIVED/console-input
  rm -f $input && mkfifo $input || return 1
  # monitor gives the app a process group of its own, so _run_stop can signal
  # all of it. &! keeps zsh from printing a job number.
  () {
    setopt local_options monitor
    (
      $command <> $input >> $log 2>&1
      print -r -- "── $RUN_APP_NAME ended with exit status $? ──" >> $log
    ) </dev/null &!
  }
  REPLY=$!
}

# _run_stop <group-id>
# Sends SIGTERM to the process group of the app. Kills the group if it is
# still running after RUN_STOP_GRACE seconds.
_run_stop() {
  local group=$1
  kill -TERM -- -$group 2>/dev/null || return 0
  local -i deadline=$(( SECONDS + RUN_STOP_GRACE ))
  while kill -0 -- -$group 2>/dev/null && (( SECONDS < deadline )); do
    sleep $RUN_POLL_INTERVAL
  done
  kill -KILL -- -$group 2>/dev/null
  return 0
}

# _run_console <log> <title>
# Shows the log in fzf until the user presses Ctrl-C. The notes at the top of
# this script list the keys.
_run_console() {
  local log=$1 title=$2
  local again="zsh -f ${(q)RUN_SCRIPT}"
  # Scrolling back turns on tracking, so the line in focus stays in place when
  # new lines come in. Going back to the newest line turns tracking off, so the
  # view follows new lines again. The prompt shows the state, and the bindings
  # read it from FZF_PROMPT.
  local pause='transform:[[ $FZF_PROMPT == *paused* ]] || print "toggle-track+change-prompt:Filter (paused): "'
  local resume='transform:(( FZF_POS == 1 )) && [[ $FZF_PROMPT == *paused* ]] && print "toggle-track+change-prompt:Filter: "'
  # ? shows the help when the filter is empty. In a filter, it is a character.
  local help="transform:[[ -n \$FZF_QUERY ]] && print 'put(?)' || print 'execute($again _help)'"
  local keys='?: help · ctrl-y: copy · ctrl-s: save to a file · end: newest line · ctrl-c: stop app'
  RUN_LOG=$log RUN_TITLE=$title RUN_APP_NAME=$RUN_APP_NAME FZF_DEFAULT_COMMAND="tail -n +1 -F ${(q)log}" fzf \
    --with-shell='zsh -fc' \
    --tac --no-sort --exact --tail=$RUN_CONSOLE_LINES --wrap --no-multi \
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

# _run_export <copy|save> <matches-file>
# Runs from the console's Ctrl-Y and Ctrl-S. Copies to the clipboard, or saves
# to a file, the lines that match the filter. With no filter, it uses the full
# log. Prints the console title with a short report, for the fzf footer.
_run_export() {
  local action=$1 matches=$2 source=$RUN_LOG what file report
  local -i count
  if [[ -n $FZF_QUERY ]]; then
    # --tac lists the newest line first. Put the lines back in log order.
    source=$(mktemp -t run-console)
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
    file=$RUN_SAVE_DIR/${(L)RUN_APP_NAME// /-}-console-$(date +%Y%m%d-%H%M%S).log
    mkdir -p $RUN_SAVE_DIR && cp $source $file
    report="Saved $what to ${file/#$HOME/~}"
  fi
  [[ $source != $RUN_LOG ]] && rm -f $source
  print -r -- "$RUN_TITLE · $report"
}

# _run_help
# Runs from the console's ? key. Shows the console keys on the full terminal
# until the user presses a key.
_run_help() {
  local bold=$'\e[1m' dim=$'\e[2m' plain=$'\e[0m'
  print -n $'\e[H\e[2J'
  print -r -- "${bold}Console keys${plain} ${dim}· $RUN_TITLE${plain}

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
  ${bold}Ctrl-S${plain}        Save the same lines to a file in ${RUN_SAVE_DIR/#$HOME/~}.
  ${bold}Ctrl-C${plain}        Stop the app and end the session.
  ${bold}?${plain}             Show this help. In a filter, ? is a usual character.

  Full log: ${RUN_LOG/#$HOME/~}

${dim}Press any key to go back to the console.${plain}"
  read -sk 1 </dev/tty
}

# run_setup
# Asks the setup questions for the current repository again.
run_setup() {
  if [[ ! -t 0 || ! -t 1 ]]; then
    print -u2 "run setup needs a terminal"
    return 1
  fi
  _run_find_repository || return 1
  _run_configure || {
    print -u2 "Settings not saved"
    return 1
  }
}

run() {
  if [[ ! -t 0 || ! -t 1 ]]; then
    print -u2 "run needs a terminal"
    return 1
  fi
  _run_setup || return 1
  # Esc in the list cancels without an error.
  _run_pick || return 0

  case $RUN_KIND in
    mac) _run_build maccatalyst 'platform=macOS,variant=Mac Catalyst' 'Mac Catalyst' ;;
    device) _run_build iphoneos 'generic/platform=iOS' iOS ;;
    simulator)
      # Boot the simulator while the app builds.
      xcrun simctl boot $RUN_ID >/dev/null 2>&1 &!
      _run_build iphonesimulator 'generic/platform=iOS Simulator' 'iOS Simulator'
      ;;
  esac || return 1
  local app=$REPLY log=$RUN_DERIVED/last-console.log

  _run_launch $app $log || return 1
  local group=$REPLY
  # Closing the terminal also stops the app.
  trap "_run_stop $group; exit 1" HUP TERM
  _run_console $log "${RUN_ROOT:t} on $RUN_NAME"

  if kill -0 -- -$group 2>/dev/null; then
    _run_stop $group
    print -u2 "Stopped $RUN_APP_NAME on $RUN_NAME"
  else
    print -u2 "$RUN_APP_NAME ended on $RUN_NAME"
  fi
  print -u2 "Console log: ${log#$PWD/}"
}

# Run only when executed, not when sourced, so tests can call the functions.
if [[ $ZSH_EVAL_CONTEXT == toplevel ]]; then
  case $1 in
    '') run ;;
    setup) run_setup ;;
    _export) shift; _run_export "$@" ;;
    _help) _run_help ;;
    *)
      print -u2 "Usage: ${0:t}         Pick a destination, then build, run, and show the console."
      print -u2 "       ${0:t} setup   Answer the setup questions for this repository again."
      exit 2
      ;;
  esac
fi
