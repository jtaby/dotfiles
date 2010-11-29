#!/usr/bin/env ruby

TRANSACTIONS_FILE_PATH = "/tmp/git_updater_transactions"

begin
  require 'yaml'
  require 'popen4'
  require 'term/ansicolor'

rescue LoadError
  puts <<-eos

  ./git_updater.rb requires the popen4 and term-ansicolor gems.

  To install them, run this command:

  gem install popen4 term-ansicolor --no-rdoc --no-ri 
eos

  exit
end

include Term::ANSIColor

HELP_FLAGS = ["--help","--h","-help","-h"]

if HELP_FLAGS.include? ARGV[0]
  help = <<-eos
  Usage: ./git_updater.rb [[--help] --push] YAML_FILE


  Overview
  -----------------------

  git_updater.rb is a convenience script built to help maintain
  the freshness of all your branches. It supports an arbitrary
  number of repositories and an arbitrary number of branches.

  git_updater is a non-destructive, transaction-based script. This means
  that if git_updater encounters a problem while trying to rebase, it 
  won't try to fix it itself (and hence not riskt destroying anything),
  and it won't consider a rebase successfull until all the commands 
  run to completion successfully.


  Conflict resolution
  -----------------------

  In the case where a rebase fails due to a conflict, then it uses a very
  rudimentary heuristic and prompt you to confirm whether an error occured
  or not. In the case that you confirm, then git_updater will write out the
  current state of the script into a temp file (/tmp/git_updater_transactions),
  and when ran again, will continue from where it left off and not try to rebase
  again.


  Usage
  -----------------------

  To start using the git_updater.rb script, you need to define a 
  YAML configuration file which defines the root of the repositories,
  the names of the repositories, and the branches within those
  repositories.

  For example, say you have a work directory in your home folder. Within
  that work directory, you have three repositories, and each has a master
  branch and a taby/master branch. In that case, your YAML file will look
  like this:


      workspace: /Users/majd/work

      repositories:
        sproutcore:
          - master
          - taby/master

        coreweb:
          - master
          - taby/master

        me:
          - master
          - taby/master


  Note that you must use the full path to your workspace, otherwise
  the script won't work.

  This configuration assumes a few things:

  1) There exist /Users/majd/work/sproutcore/, /Users/majd/work/coreweb/,
     and /Users/majd/work/me/

  2) All the aforementioned directories are git repositories with an origin.

  If any of these conditions are not met, the script will fail to work.
eos

  print help
  exit
  
else
  input_file_name = ARGV[0]
end

PUSH_FLAGS = ["--push","--p","-push","-p"]

if PUSH_FLAGS.include? ARGV[1]
  PUSH_AFTER_REBASE = true
else
  PUSH_AFTER_REBASE = false
end

# Open input file and parse it

begin
  input_file = File.open(input_file_name)
rescue
  puts "Usage: ./git_updater.rb [[--help] --push] YAML_FILE"
  exit
end

yaml = YAML::load(input_file)

workspace = yaml['workspace']
repositories = yaml['repositories']

if File.exists? TRANSACTIONS_FILE_PATH
  previous_transaction_file = File.open TRANSACTIONS_FILE_PATH
  previous_transaction_state = YAML::load previous_transaction_file
else
  previous_transaction_state = {}
end

# transaction_state will contain the current atomic
# state of the updates. When we need to stop, it will
# be written to a file so we can read it later and pick 
# up from where we left off.
transaction_state = {}
transaction_file = File.new(TRANSACTIONS_FILE_PATH,  "w+")

def print_output(output)
    output.split(/\n/).each { |line|
      puts "\t   #{line}"
    }
end

def run(command, print_output=true)
  ret = ""

  POpen4::popen4(command) do |stdout, stderr, stdin, pid|

    stderr_output = stderr.read.strip
    stdout_output = stdout.read.strip
      
    if stderr_output.size > 0
      ret = stderr_output
      if print_output
        stderr_output.split(/\n/).each { |line|
          print "\t   ", red, line, reset, "\n"
        }
      end
    elsif stdout_output.size > 0
      ret = stdout_output
      if print_output
        stdout_output.split(/\n/).each { |line|
          print "\t   ", green, line, reset, "\n"
        }
      end
    end

  end

  return ret
end

def conflict_did_happen?
  ret = false

  print "------", red, "I think there was a conflict, am I correct? (y/n) ", reset

  STDIN.gets
  answer = $_
  answer.chomp!

  if answer.size == 0 or answer.eql? "y" or answer.eql? "yes"
    ret = true
  else
    ret = false
  end

  return ret
end

# Given the output of the rebase, try to determine
# whether it was successful or whether it failed.
#
# We do this by inspecting the output line-by-line
# and looking for tell-tale signs
def rebase_succeeded?(output)
  result = true
  
  if output =~ /you have unstaged changes/
    result = true
  elsif output =~ /Fail|Failed|Conflict|cannot|stopping|warning|git rebase --continue/i
    if conflict_did_happen?
      result = false
    end
  end

  return result
end

def perform_rebase(repo,branch,command,transaction_state)
  rebase_output = run command

  if rebase_succeeded? rebase_output
    transaction_state[repo][branch] = true
  else
    transaction_state[repo][branch] = false
    throw "There was a problem with the rebase"
  end

end

def get_current_branch(repo)
  current_branch = ""

  output = `git branch`
  branches = output.split(/\n/)

  branches.each do |branch|
    if branch.chomp =~ /^\*\s(.*)/
      current_branch = $1
    end
  end

  return current_branch
end

repositories.each do |repo, branches|
  print "\n-------------------\nUpdating branches in ", bold, blue, "#{repo}", reset, "\n"

  # Change current working directory to the one specified for 
  # the repository
  Dir.chdir "#{workspace}/#{repo}"
  
  if not File.exists? ".git/config"
    throw "FATAL: #{workspace}/#{repo} is not a git repository."
  end

  transaction_state[repo] = {}

  run("git fetch",true)

  current_branch = get_current_branch(repo)

  branches.each do |branch|
    if previous_transaction_state.has_key? repo and previous_transaction_state[repo][branch]
      puts "\tSkipping since this branch has already been updated"
      transaction_state[repo][branch] = true
      next
    end

    puts "\n   Switching branches to #{branch}\n"
    run "git checkout #{branch}"

    begin
      print "   Rebasing ", blue, branch, reset, " against ", blue, "origin/master", reset, "\n"
      command = "git rebase origin/master"
      perform_rebase(repo, branch, command, transaction_state)

      print "   Rebasing ", blue, branch, reset, " against ", blue, "origin/#{branch}", reset, "\n"
      command = "git rebase origin/#{branch}"
      perform_rebase(repo, branch, command, transaction_state)

      if not branch.eql? "master" and PUSH_AFTER_REBASE
        print "   Pushing current state of ", blue, branch, reset, " to origin\n"
        command = "git push origin #{branch}"
        run command
      end

    rescue
      puts "\n\n   -----------------------------------------------"
      puts "   There was a problem rebasing. Please fix the problme, and when you're done,"
      puts "   run the script again, and I'll continue from where I left off."
      puts "\n                ./git_updater.rb YAML_FILE"

      transaction_file.write YAML::dump(transaction_state)
      exit
    end
  end

  puts "   Switching branches back to #{current_branch}\n"
  run "git checkout #{current_branch}"
end

if File.exists? TRANSACTIONS_FILE_PATH
  File.delete TRANSACTIONS_FILE_PATH
end

print "\n-------------------\n", green, "Successfully updated all repositories and branches", reset, "\n"
