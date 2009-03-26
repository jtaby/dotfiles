PS1="\[\033[34m\][\h:\[\033[0;31m\]\w\[\033[0;34m\]]$ \[\033[0m\]"

alias austerlitz="ssh mabdelah@austerlitz.staff.itd.umich.edu"
alias gromit="ssh mabdelah@gromit.umnet.umich.edu"
alias wallace="ssh mabdelah@wallace.umnet.umich.edu"
alias porky="ssh mabdelah@porky.umnet.umich.edu"

alias slice="ssh jtaby.dyndns.org"
alias slice="ssh jtaby@jtaby.com -p 30000"
alias caen="ssh mabdelah@loginlinux.engin.umich.edu"
alias la="ls -A"

alias mysql=/usr/local/mysql/bin/mysql
alias mysqlstart="cd /usr/local/mysql/ && sudo ./bin/mysqld_safe -u root -p"
alias mysqladmin=/usr/local/mysql/bin/mysqladmin

cds(){
    cd $1
    ls -ApG
}
export PATH=/opt/local/bin:/opt/local/sbin:$PATH:/usr/local/bin:/opt/local/bin:/opt/bin:~/bin:/Users/majdtaby/.gem/ruby/1.8/bin
export MANPATH=/opt/local/share/man:$MANPATH
export EDITOR=/usr/bin/vim

export GEM_PATH="/Users/majdtaby/.gem/ruby/1.8:$GETM_PATH"

export CVSROOT=:ext:${USER}@cvs.itd.umich.edu:/usr/src/cvsroot
export CVS_RSH=ssh
export CVSEDITOR=vim
