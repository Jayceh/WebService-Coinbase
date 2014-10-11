#!/usr/bin/env perl

use v5.20;
use lib 'lib';
use WebService::Coinbase;
use Data::Debug;

my $cb = WebService::Coinbase->new( { api_key => 'nvrzIX9jW1cOwsb8', api_secret => '77kuf82gyvp5idjy0UA4Pi7OfY4vyimV' }) ;

debug $cb->get_price_buy;
#debug $cb->get_price_sell;
#debug $cb->get_price_spot_rate;
#debug $cb->get_price_historical;
#debug $cb->get_account_receive_address('53d2c907969235f664005f08');
#debug $cb->get_accounts_balance('53d2c907969235f664005f08');
#debug $cb->get_addresses;
#debug $cb->get_authorization;
#debug $cb->get_contacts;
#debug $cb->get_currencies;
#debug $cb->get_currencies_exchange_rates;
#debug $cb->get_orders;
debug $cb->get_payment_methods;
