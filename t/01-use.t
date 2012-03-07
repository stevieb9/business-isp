#!/usr/bin/perl

use strict;
use Test;

# This test file ensures that all of our modules under the Business::ISP:: umbrella
# are available for use().

use Business::ISP::Object;
use Business::ISP::Error;
use Business::ISP::Ledger;
use Business::ISP::Sanity;
use Business::ISP::Transac;
use Business::ISP::User;
use Business::ISP::Vars;
use Business::ISP::GUI::Accounting;
use Business::ISP::Conversion;

BEGIN { plan tests => 1 };

ok(1);
