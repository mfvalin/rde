#!/bin/ksh
#
# s.cc

# set EC_LD_LIBRARY_PATH and EC_INCLUDE_PATH using LD_LIBRARY_PATH
#export EC_LD_LIBRARY_PATH=`s.generate_ec_path --lib`
#export EC_INCLUDE_PATH=`s.generate_ec_path --include`

export COMPILING_C=yes
. rde.get_compiler_rules.dot

if [ -n "$WILL_LINK" ]; then
   if [[ -n $Verbose ]] ; then
      cat <<EOF
$CC ${SourceFile} $CC_options ${CFLAGS} \\
		$(s.prefix "" ${DEFINES} ) \\
		$(s.prefix "-I" ${INCLUDES} ${EC_INCLUDE_PATH}) \\
		$(s.prefix "-L" ${LIBRARIES_PATH} ${EC_LD_LIBRARY_PATH}) \\
		$(s.prefix "-l" ${LIBRARIES} ) \\
		"$@"
EOF
   fi
	$CC ${SourceFile} $CC_options ${CFLAGS} \
		$(s.prefix "" ${DEFINES} ) \
		$(s.prefix "-I" ${INCLUDES} ${EC_INCLUDE_PATH}) \
		$(s.prefix "-L" ${LIBRARIES_PATH} ${EC_LD_LIBRARY_PATH}) \
		$(s.prefix "-l" ${LIBRARIES} ) \
		"$@"
else
   if [[ -n $Verbose ]] ; then
      cat <<EOF
$CC ${SourceFile} ${CC_options_NOLD:-${CC_options}} ${CFLAGS} \\
		$(s.prefix "" ${DEFINES} ) \\
		$(s.prefix "-I" ${INCLUDES} ${EC_INCLUDE_PATH}) \\
		"$@"
EOF
   fi
	$CC ${SourceFile} ${CC_options_NOLD:-${CC_options}} ${CFLAGS} \
		$(s.prefix "" ${DEFINES} ) \
		$(s.prefix "-I" ${INCLUDES} ${EC_INCLUDE_PATH}) \
		"$@"
fi