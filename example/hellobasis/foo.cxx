/**
 * @file  foo.cxx
 * @brief Implementation of private utility functions.
 *
 * Copyright (c) 2011-2012 University of Pennsylvania. <br />
 * Copyright (c) 2013-2014 Andreas Schuh.              <br />
 * All rights reserved.                                <br />
 *
 * See http://opensource.andreasschuh.com/cmake-basis/download.html#software-license
 * or COPYING file for license information.
 *
 * Contact: Andreas Schuh <andreas.schuh.84@gmail.com>,
 *          report issues at https://github.com/schuhschuh/cmake-basis/issues
 */

#include <iostream>

#include "foo.h"


// acceptable in .cxx file
using namespace std;


// ---------------------------------------------------------------------------
void foo()
{
    cout << "Called the private foo() function." << endl;
}