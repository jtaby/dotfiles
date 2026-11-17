if status is-interactive
# Commands to run in interactive sessions can go here
    # Tab completion of run and xcode-run
    command -q xcode-run; and xcode-run completion fish | source
end

function l
    ls -lah $argv
end

function gst
    git status $argv
end

function ga
    git add $argv
end

function gcmsg
    git commit -m $argv
end

function gd
    git diff $argv
end

function gb
    git branch $argv
end

function gco
    git checkout $argv
end

function gfa
    git fetch --all $argv
end

function gri
    git rebase -i origin/develop $argv
end

function ggu
    git pull --rebase $argv
end

function glol
    git log --graph --pretty='%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%ar) %C(bold blue)<%an>%Creset' $argv
end

function ggp
    # Get current branch name
    set branch (git symbolic-ref --quiet --short HEAD)

    # If not on a branch (detached HEAD), bail out
    if test -z "$branch"
        echo "Not on a branch (detached HEAD)."
        return 1
    end

    # Push to origin with upstream tracking
    git push -u origin $branch
end

function gcm
    if test (count $argv) -eq 0
        echo "Usage: gcm <commit message>"
        return 1
    end

    git commit -m "$argv"
end

function ggpf
    # Get current branch name
    set branch (git symbolic-ref --quiet --short HEAD)

    # Bail if detached HEAD
    if test -z "$branch"
        echo "Not on a branch (detached HEAD)."
        return 1
    end

    # Check if upstream exists
    git rev-parse --abbrev-ref --symbolic-full-name @{u} >/dev/null 2>&1

    if test $status -ne 0
        # No upstream yet
        git push -u origin $branch --force-with-lease
    else
        git push --force-with-lease
    end
end

function app
    open darkroom-app/HSL.xcworkspace
end

function track
    if test (count $argv) -lt 1
        echo "Usage: track <branch-name> [remote]"
        return 1
    end

    set branch $argv[1]
    set remote origin

    if test (count $argv) -ge 2
        set remote $argv[2]
    end

    # Verify remote branch exists
    if not git show-ref --verify --quiet refs/remotes/$remote/$branch
        echo "Remote branch '$remote/$branch' does not exist."
        return 1
    end

    # Switch to branch, creating it if needed
    if git show-ref --verify --quiet refs/heads/$branch
        # Try to checkout; only set upstream and pull if checkout succeeds
        git checkout $branch; and git branch --set-upstream-to=$remote/$branch; and ggu
    else
        # Create local branch tracking remote branch
        git checkout -b $branch --track $remote/$branch
    end
end
