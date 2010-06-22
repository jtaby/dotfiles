#!/usr/bin/env ruby

########################################################################################################
# Usage:                                                                                               #
#  gitchdiff [-r<left rev>:<right-rev>] [repository]                                                   #
#                                                                                                      #
# Example:                                                                                             #
#  gitchdiff                                       # == gitchdiff -rHEAD^:HEAD .                       #
#  gitchdiff -rHEAD^^:HEAD                         # == gitchdiff -rHEAD^^:HEAD .                      #
#  gitchdiff -master:origin/master                 # == gitchdiff -rmaster:origin/master .             #
#  gitchdiff /path/to/git/repository               # == gitchdiff -rHEAD^:HEAD /path/to/git/repository #
#  gitchdiff -rHEAD^:HEAD /path/to/git/repository  # == gitchdiff -rHEAD^:HEAD /path/to/git/repository #
#                                                                                                      #
# Authored by Simon Menke, with minor optimizations by Jonathan del Strother                           #
########################################################################################################

def checkout(origin, rev)
  tmp = "/tmp/git_chdiff_#{rand}.tmp/"
  Dir.mkdir(tmp)
  Dir.chdir(origin) do
    # The clean, porcelainy way would be "git archive --format=tar '#{rev}' | (cd #{tmp} && tar xf -)"
    # I've found the plumbing to be marginally faster :
    system "git read-tree '#{rev}'; git checkout-index --prefix=#{tmp} -a; git read-tree HEAD"
  end
  return tmp
end

def diff(origin, revs={})
  revs = {:left=>"HEAD^",:right=>"HEAD"}.merge(revs)
  left  = checkout origin, revs[:left]
  right = checkout origin, revs[:right]
  system "chdiff '#{left}' '#{right}'"
end

revs     = {}
git_dir = Dir.pwd
ARGV.each do |arg|
  if arg[0,2] == "-r"
    rev_strings = arg[2..-1].split(':')
    case rev_strings.size
    when 1
      revs[:left]  = rev_strings[0] unless rev_strings[0].empty?
    when 2
      revs[:left]  = rev_strings[0] unless rev_strings[0].empty?
      revs[:right] = rev_strings[1] unless rev_strings[1].empty?
    else
      revs = nil
    end
  else
    git_dir = arg unless arg.empty?
  end
end

diff(git_dir, revs)