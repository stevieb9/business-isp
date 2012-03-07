#!/usr/bin/perl

use strict;
use Test;

# This test file ensures that all of our modules under the ISP:: umbrella
# are available for use().

use ISP::Object;
use ISP::Error;
use ISP::Ledger;
use ISP::Sanity;
use ISP::Transac;
use ISP::User;
use ISP::Vars;
use ISP::GUI::Accounting;
use ISP::Conversion;

BEGIN { plan tests => 1 };

ok(1);
