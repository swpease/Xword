TEMPLATE = app

TARGET = Xword

QT += qml quick widgets

SOURCES += main.cpp \
    fileio.cpp \
    export.cpp

RESOURCES += qml.qrc

ICON = xword.icns

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH =

# Default rules for deployment.
include(deployment.pri)

DISTFILES +=

HEADERS += \
    fileio.h \
    export.h

