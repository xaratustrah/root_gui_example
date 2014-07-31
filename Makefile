#Makefile
CXX = g++
LD = g++
CINT = rootcint

OS_NAME:=$(shell uname -s | tr A-Z a-z)
ifeq ($(OS_NAME),darwin)
STDINCDIR := -I/opt/local/include
STDLIBDIR := -L/opt/local/lib
EXTRAFLAG := -Qunused-arguments -mmacosx-version-min=10.7
else
STDINCDIR := 
STDLIBDIR := 
EXTRAFLAG :=
endif

LDFLAGS := $(shell root-config --glibs) -lSpectrum -headerpad_max_install_names
CPPFLAGS := $(shell root-config --cflags)
CPPFLAGS +=  -g -O0 -fbuiltin -Wall $(EXTRAFLAG) -save-temps
INC=-I.

TARGET = application
SRC = Frame.cxx Frame_Dict.cxx Application.cxx
OBJ = $(SRC:.cpp=.o) 
all : $(TARGET) relink
dist : clean dict all osxapp

$(TARGET) : dict $(OBJ)
	$(LD) $(CPPFLAGS) $(LDFLAGS) $(INC) -o $(TARGET) $(OBJ)

%.o : %.cxx
	$(CXX) $(CPPFLAGS) -c $< -o $@

relink:
	$(LD) $(CPPFLAGS) $(LDFLAGS) $(INC) -o $(TARGET) $(OBJ)

dict:
	$(CINT) -f Frame_Dict.cxx -c Frame.h Frame_LinkDef.h
	$(CXX) $(CPPFLAGS) -c Frame_Dict.cxx

osxapp:
	mkdir $(TARGET).app
	mkdir $(TARGET).app/Contents
	mkdir $(TARGET).app/Contents/MacOS
	mkdir $(TARGET).app/Contents/Frameworks
	mkdir $(TARGET).app/Contents/Resources
	mkdir $(TARGET).app/Contents/libs
	cp $(TARGET) $(TARGET).app/Contents/MacOS/
	cp Info.plist $(TARGET).app/Contents/
	ruby fix_libs.rb $(TARGET)
arch:
	tar czvf application.tar.gz *.cxx *.h *.rb Info.plist Makefile README
dmg:
	hdiutil create $(TARGET).dmg -volname "$(TARGET)" -fs HFS+ -srcfolder $(TARGET).app

.PHONY : clean
clean :
	rm -rf *.s *.o *.ii *.swp *_Dict.* $(TARGET).dSYM $(TARGET).dmg
