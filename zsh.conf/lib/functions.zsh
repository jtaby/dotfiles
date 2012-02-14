# I could never remember the arguments for tar
function compress() {
  tar cvzf $1.tar.gz $1
}

function uncompress() {
  if [ -d "$2" ]; then
    tar xvzf $1 -C $2
  else
    mkdir $2
    tar xvzf $1 -C $2
  fi
}

# Make vim ask for sudo password if I try to open a 
# privileged file
function vim {
       LIMIT=$#
       for ((i = 1; i <= $LIMIT; i++ )) do
               eval file="\$$i"
               if [[ -e $file && ! -O $file ]]
               then
                       otherfile=1
               else

               fi
       done
       if [[ $otherfile = 1 ]]
       then
               sudo vim "$@"
       else
               command vim "$@"
       fi
}
