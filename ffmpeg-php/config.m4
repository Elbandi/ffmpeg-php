PHP_ARG_WITH(ffmpeg,for ffmpeg support, 
[  --with-ffmpeg[=DIR]       Include ffmpeg support (requires ffmpeg >= 0.49.0).])

PHP_ARG_ENABLE(skip-gd-check, whether to force gd support in ffmpeg-php, [  --enable-skip-gd-check     skip checks for gd libs and assume they are present.], no, no)

AC_DEFUN([SKIP_GD_CK],[
    AC_DEFINE(HAVE_LIBGD20, 1, [ ])
])

if test "$PHP_SKIP_GD_CHECK" != "no"; then
    SKIP_GD_CK
fi

dnl Determine path to ffmpeg libs
if test "$PHP_FFMPEG" != "no"; then

  AC_MSG_CHECKING(for ffmpeg headers)
  for i in $PHP_FFMPEG /usr/local /usr ; do
    if test -f $i/include/ffmpeg/avcodec.h; then
      AC_MSG_RESULT(...found in $i/include/ffmpeg)
      PHP_ADD_INCLUDE($i/include/ffmpeg)
    elif test -f $i/include/avcodec.h; then
      AC_MSG_RESULT(...found in $i/include)
      PHP_ADD_INCLUDE($i/include)
    elif test -f $i/include/libavcodec/avcodec.h; then
      dnl ffmpeg svn revision 12194 and newer put each header in its own dir
      dnl so we have to include them all.
      AC_MSG_RESULT(...found in $i/include/libav*)
      PHP_ADD_INCLUDE($i/include/libavcodec/)
      PHP_ADD_INCLUDE($i/include/libavformat/)
      PHP_ADD_INCLUDE($i/include/libavutil/)
      PHP_ADD_INCLUDE($i/include/libswscale/)
      PHP_ADD_INCLUDE($i/include/libavfilter/)
      PHP_ADD_INCLUDE($i/include/libavdevice/)
    else
      AC_MSG_RESULT()
      AC_MSG_ERROR([ffmpeg headers not found. Make sure ffmpeg is compiled as shared libraries using the --enable-shared option])
    fi
  done

  AC_MSG_CHECKING(for ffmpeg libavcodec.so)
  for i in $PHP_FFMPEG /usr/local /usr ; do
    if test -f $i/lib/libavcodec.so; then
      FFMPEG_LIBDIR=$i/lib
    fi
    dnl PATCH: 1785450 x86_64 support (Bent Nagstrup Terp)
    if test -f $i/lib64/libavcodec.so; then
      FFMPEG_LIBDIR=$i/lib64
    fi
    dnl MacOS-X support (Alexey Zakhlestin)
    if test -f $i/lib/libavcodec.dylib; then
      FFMPEG_LIBDIR=$i/lib
    fi
    done

  if test -z "$FFMPEG_LIBDIR"; then
    AC_MSG_RESULT()
    AC_MSG_ERROR(ffmpeg shared libraries not found. Make sure ffmpeg is compiled as shared libraries using the --enable-shared option)
  else
    dnl For debugging
    AC_MSG_RESULT(...found in $FFMPEG_LIBDIR)
  fi

  CFLAGS="$CFLAGS -Wall -fno-strict-aliasing"

  PHP_ADD_LIBRARY_WITH_PATH(avcodec, $FFMPEG_LIBDIR, FFMPEG_SHARED_LIBADD)
  PHP_ADD_LIBRARY_WITH_PATH(avformat, $FFMPEG_LIBDIR, FFMPEG_SHARED_LIBADD)

  PHP_NEW_EXTENSION(ffmpeg, ffmpeg-php.c ffmpeg_movie.c ffmpeg_frame.c ffmpeg_animated_gif.c ffmpeg_errorhandler.c, $ext_shared,, \\$(GDLIB_CFLAGS))
  PHP_SUBST(FFMPEG_SHARED_LIBADD)
  AC_DEFINE(HAVE_FFMPEG_PHP,1,[ ])
    

dnl PHP_DEBUG_MACRO(test.dbg)
fi
