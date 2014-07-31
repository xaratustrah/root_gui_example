#include <TApplication.h>
#include "Frame.h"

void showFrame() {
    // Popup the GUI...
    new Frame(gClient->GetRoot(),200,200);
}

int main(int argc, char **argv) {
    TApplication theApp("App",&argc,argv);
    showFrame();
    theApp.Run();
    return 0;
}
