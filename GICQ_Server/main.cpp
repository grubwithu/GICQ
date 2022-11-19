#include <iostream>
#include "Base/Server.h"
#include <list>

using namespace std;


int main() {
    Server s = Server(9898);
    s.start();

    return 0;
}
