#!/usr/bin/env ruby

USAGE_STRING = <<-eos

Usage: ./commit_differ.rb [--help] [OPTIONS] path/to/repository"

By default, shows the diff in the console

Options:

-d, --diff    Show diff in the console using the diff command
-m, --mate    Show diff in textmate (requires the mate command)

eos

begin
  require 'popen4'
  require 'term/ansicolor'

  include Term::ANSIColor

rescue LoadError
  puts <<-eos

  commit_differ.rb requires the popen4 and term-ansicolor gems.

  To install them, run this command:

  gem install popen4 term-ansicolor --no-rdoc --no-ri 
eos

  exit
end

HELP_FLAGS = ["--help","--h","-help","-h"]

if HELP_FLAGS.include? ARGV[0]
  help = <<-eos
  


  Overview
  -----------------------

  The main purpose of commit_differ.rb is to facilitate choosing the two commits. 
  Normally, this process involves running a diff command like `git diff 10b32t 103sd3` 
  but finding those hashes was a cumbersome process. 


  Usage
  -----------------------

  To use commit_differ.rb, simple invoke it from a git repository, and it will show
  you a list of the previous 10 commits and allows you to access them using simple numbers
eos

  print help
  exit
  
end

# Open input file and parse it
begin

  if ARGV[0] and File.directory?(ARGV[0])
    directory = File.expand_path(ARGV[0])

    Dir.chdir directory

  else
    throw "First argument is not a directory. \n\nUsage: ./commit_differ.rb [--help] path/to/repository"
  end

rescue => e
  puts e.message
  puts "\nBacktrace:"
  puts e.backtrace
  exit
end

# Make sure we're in a git repo
begin

  if not File.exist? ".git/config"
    throw "commit_differ.rb must be run from a git repository."
  end

rescue => e
  puts e.message
  puts "\nBacktrace:"
  puts e.backtrace
  exit
end

class CommitModel
  attr_accessor :hash, :author, :branch, :message, :date

  def initialize(log_message)
    match_data = /^\s*\*\s+([a-z0-9]+)\s+(.*)\s\-\s(\(.*?\))?(.*)(\(.*?\))/.match(log_message)
    if match_data
      @hash, @author, @branch, @message, @date = match_data.captures
      @message.strip!
    else
      throw "Couldn't tokenize"
    end
  end 

  def inspect
    puts "\nHash: #{@hash}\nAuthor: #{@author}\nBranch: #{@branch}\nMessage: #{@message}\nDate: #{@date}\n"
  end

end

def print_log(output)

  puts "\nPlease select two commits to compare:\n"

  i = 0

  commits = []

  output.split(/\n/).each do |line|

    begin
      commit = CommitModel.new(line)
      print "    #{i}: ", green, "#{commit.hash}", reset, " - ", blue, "#{commit.message} ", yellow, "#{commit.date}", reset, "\n"

      commits << commit

      i += 1
    rescue
      next
    end
  end

  print "\nFirst commit: (default 0) "

  STDIN.gets
  answer = $_
  answer.chomp!

  if answer.length > 0
    a = answer.to_i
  else
    a = 0
  end

  print "\nSecond commit: (ex. 2) "

  STDIN.gets
  answer = $_
  answer.chomp!

  b = answer.to_i

  hashA = commits[a].hash
  hashB = commits[b].hash

  puts "\nShowing a diff between commits #{hashA} and #{hashB}"
  `git diff #{hashB} #{hashA} | mate`
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

command = "git log -n 10 --graph --pretty=format:'%h %an -%d %s (%cr)' --abbrev-commit --date=relative"
print_log run command, false
