
# Closure-boilerplate Compile Script
# --
# @autor Jan Kuča



# The $1 argument is the project root path (defaults to ".")
# Note: The provided Sublime Text build command automatically passes
#   the $project_path variable to this script.
PROJECT_DIR_RELATIVE=$1
[ -z $1 ] && PROJECT_DIR_RELATIVE="."


# The root project directory
# All the following paths are relative to this directory
PROJECT_DIR=`cd $PROJECT_DIR_RELATIVE ; pwd`

# The directory in which is this script placed
BUILD_DIR=$PROJECT_DIR/build

# The public-facing directory (sometimes called the document root)
PUBLIC_DIR=$PROJECT_DIR/public

# The compile script output directory path
TARGET_DIR=$PUBLIC_DIR/build

# The compile script output file name
# Relative to $TARGET_DIR
TARGET_FILE=app.min.js

# The source map file name
# Relative to $TARGET_DIR
SOURCE_MAP_FILE=source-map.json

# The file (created by the script) including JS references from HTML files
HTML_JS_FILE=$PUBLIC_DIR/app/controllers.temp.js

# The closure-library directory path
CLOSURE_LIBRARY_DIR=$PUBLIC_DIR/lib/closure-library

# The Google Closure Compiler jar file path
CLOSURE_COMPILER_PATH=$BUILD_DIR/closure-compiler/compiler.jar



# Make sure the target directory exists
echo "-- Make sure the target directory exists"
mkdir -p $TARGET_DIR
echo

# Extract JavaScript global references from HTML files into a temporary JS file
echo "-- Extract JavaScript references from HTML files"
$BUILD_DIR/compile-html.js                                                    \
  --root=$PUBLIC_DIR                                                          \
  --exclude=$PUBLIC_DIR/lib                                                   \
  --attribute="ng:controller"                                                 \
> $HTML_JS_FILE                                                               \
|| exit 1
echo

# Note: The output file has to be inside one of the roots below.


# Compile the JavaScript and generate a source map
echo "-- Compile the JavaScript and generate a source map"
$CLOSURE_LIBRARY_DIR/closure/bin/build/closurebuilder.py                      \
  --root="$PUBLIC_DIR/lib"                                                    \
  --root="$PUBLIC_DIR/app"                                                    \
  --namespace="app.main"                                                      \
  --namespace="app.controllers"                                               \
  --output_mode="compiled"                                                    \
  --compiler_jar="$CLOSURE_COMPILER_PATH"                                     \
  --compiler_flags="--compilation_level=ADVANCED_OPTIMIZATIONS"               \
  --compiler_flags="--warning_level=VERBOSE"                                  \
  --compiler_flags="--language_in=ECMASCRIPT5_STRICT"                         \
  --compiler_flags="--create_source_map=$TARGET_DIR/$SOURCE_MAP_FILE"         \
  --compiler_flags="--output_wrapper=(function(){%output%}.call(this));       \
    //@ sourceMappingURL=$SOURCE_MAP_FILE"                                    \
> $TARGET_DIR/$TARGET_FILE                                                    \
|| exit 1
echo

# Note: The sourceMappingURL is relative to the compilation output directory


# Fix file paths in the generated source map
echo "-- Fix file paths in the generated source map"
$BUILD_DIR/fix-source-map.js                                                  \
  --root=$PUBLIC_DIR                                                          \
  --map=$TARGET_DIR/$SOURCE_MAP_FILE                                          \
|| exit 1
echo

# Remove temporary files
# Do not remove the files if you want the source-mapping to be complete.
#echo "Remove temporary files"
#rm $PUBLIC_DIR/app/js/controllers.temp.js
#echo


echo "== Successfully compiled =="
