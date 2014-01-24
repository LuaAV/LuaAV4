set -e
LUAJIT=luajit-2.0
FLAGS='-mmacosx-version-min=10.5 -DLUAJIT_ENABLE_LUA52COMPAT'
(rm *.tmp 1>/dev/null 2>/dev/null) && true

make -C $LUAJIT clean
make -C $LUAJIT -j BUILDMODE=dynamic CC="clang $FLAGS -arch i386"   LUAJIT_SO=luajit.dylib TARGET_DYLIBPATH=luajit.dylib amalg
mv $LUAJIT/src/luajit.dylib luajit32.dylib.tmp
make -C $LUAJIT -j CC="clang $FLAGS -arch i386" amalg
mv $LUAJIT/src/luajit luajit32.exe.tmp
mv $LUAJIT/src/libluajit.a libluajit32.a.tmp

make -C $LUAJIT clean
make -C $LUAJIT -j BUILDMODE=dynamic CC="clang $FLAGS -arch x86_64"   LUAJIT_SO=luajit.dylib TARGET_DYLIBPATH=luajit.dylib amalg
mv $LUAJIT/src/luajit.dylib luajit64.dylib.tmp
make -C $LUAJIT -j CC="clang $FLAGS -arch x86_64" amalg
mv $LUAJIT/src/luajit luajit64.exe.tmp
mv $LUAJIT/src/libluajit.a libluajit64.a.tmp

lipo -create ./luajit*.exe.tmp -output luajit
lipo -create ./luajit*.dylib.tmp -output libluajit.dylib
lipo -create ./libluajit*.a.tmp -output libluajit.a
rm *.tmp 1>/dev/null 2>/dev/null

install_name_tool -id                      @loader_path/luajit.dylib libluajit.dylib
install_name_tool -change luajit.dylib @executable_path/luajit.dylib luajit

mkdir -p osx/bin
mkdir -p osx/lib
mkdir -p osx/include

mv -f luajit osx/bin
mv -f libluajit.dylib osx/lib
mv -f libluajit.a osx/lib
cp $LUAJIT/src/lauxlib.h osx/include
cp $LUAJIT/src/lua*.h osx/include