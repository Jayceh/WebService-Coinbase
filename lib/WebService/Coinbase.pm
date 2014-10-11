package WebService::Coinbase;

use strict;
use warnings;

use v5.10;
use Moo;
use JSON;
use HTTP::Tiny;
use Crypt::Mac::HMAC qw( hmac hmac_hex );
use Throw;

has API_BASE =>  (
  is      => 'ro',
  default =>  sub {
    return 'https://api.coinbase.com/v1/';
  },
);

has api_key =>  (
  is =>  'rw',
);

has api_secret =>  (
  is =>  'rw',
);

our $HEADER = {
  timeout      => 120,
  'content-type' => 'application/json',

};

has http => (
  is      => 'ro',
  lazy    => 1,
  default => sub {
    my $http = HTTP::Tiny->new( %{ $HEADER } );
  },
);

has nonce =>  (
  is      => 'ro',
  lazy    => 1,
  default => sub {
    return int( time * "1.43e+001");
  },
);

###----- helper
sub unauthenticated_get {
  my $self   = shift;
  my $method = shift;
  my $args   = shift;
  my $url    = $self->API_BASE . $method;
  my $ret    = $self->http->get( $url );
  if( $ret->{'success'} == 1 ) {
    # good return
    return decode_json( $ret->{'content'} );
  }
  throw decode_json( $ret );
}

sub authenticated_get {
  my $self   = shift;
  my $method = shift;
  my $args   = shift;
  my $url    = $self->API_BASE . $method;
  my $nonce = $self->nonce;
  my $hmac = hmac_hex( 'SHA256', $self->api_secret, $nonce . $url);
  my $ret = $self->http->get($url, { headers => { ACCESS_KEY => $self->api_key, ACCESS_SIGNATURE => $hmac, ACCESS_NONCE => $nonce } });
  if( $ret->{'success'} == 1 ) {
    # good return
    return decode_json( $ret->{'content'} );
  }
  throw decode_json( $ret );
}

###----- unauthenticated
sub get_price_buy {
  my $self = shift;
  my $url = 'prices/buy';
  $self->unauthenticated_get( $url );
}

sub get_price_sell {
  my $self = shift;
  my $url = 'prices/sell';
  $self->unauthenticated_get( $url );
}

sub get_price_spot_rate {
  my $self = shift;
  my $url = 'prices/spot_rate';
  $self->unauthenticated_get( $url );
}

sub get_price_historical {
  my $self = shift;
  ## needs an optional argument
  my $url = $self->API_BASE . 'prices/historical';
  my $ret = $self->http->get( $url );
  if( $ret->{'success'} == 1 ) {
    # good return
    # because why have a nice JSON API that always returns JSON?
    return $ret->{'content'};
  }
  throw decode_json( $ret );
}

####------ AUTHENTICATED
sub get_accounts {
  my $self = shift;
  my $method = 'accounts';

  ##TODO: Params page | limit | all_accounts

  my $ret = $self->authenticated_get( $method );
  
  return $ret;
}

sub get_accounts_balance {
  my $self = shift;
  my $account_id //= shift;
  throw 'Missing account_id parameter' unless $account_id;
  my $method = "accounts/$account_id/balance";

  my $ret = $self->authenticated_get( $method );
  
  return $ret;
}


sub get_account_receive_address {
  my $self = shift;
  my $method = 'account/receive_address';
  my $account_id //= shift;
  if( $account_id ) {
    $method .= "?account_id=$account_id"
  }

  my $ret = $self->authenticated_get( $method );
  
  return $ret;
}

## TODO: POST /api/v1/account/generate_receive_address 
##TODO: POST /api/v1/accounts 
##TODO: PUT /api/v1/accounts/:account_id/keypairs 
##TODO: PUT /api/v1/accounts/:account_id 
##TODO: POST /api/v1/accounts/:account_id/primary 
##DELETE /api/v1/accounts/:account_id 

sub get_addresses {
  my $self = shift;
  my $method = 'addresses';

  my $ret = $self->authenticated_get( $method );

  return $ret;
}

sub get_authorization {
  my $self = shift;
  my $method = 'authorization';

  my $ret = $self->authenticated_get( $method );

  return $ret;
}

####------ BUTTONS
##TODO:POST /api/v1/buttons 
##TODO: POST /api/v1/buttons/:code/create_order 

sub get_buttons_orders {
  my $self = shift;
  my $button_id //= shift;
  throw 'Missing button_id  parameter' unless $button_id;
  my $method = "buttons/$button_id/orders";

  my $ret = $self->authenticated_get( $method );
  
  return $ret;
}

##TODO: POST /api/v1/buys

sub get_contacts {
  my $self = shift;
  my $method = "contacts";

  my $ret = $self->authenticated_get( $method );
  
  return $ret;
}

#####----- CURRENCIES

sub get_currencies {
  my $self = shift;
  my $method = "currencies";

  my $ret = $self->authenticated_get( $method );
  
  return $ret;
}

sub get_currencies_exchange_rates {
  my $self = shift;
  my $method = "currencies/exchange_rates";

  my $ret = $self->authenticated_get( $method );
  
  return $ret;
}

####---- ORDERS

sub get_orders {
  my $self = shift;
  my $method = "orders";

  ## optional order id OR custom element
  my $id //= shift;
  if( $id ){
    $method .= "/$id";
  }

  my $ret = $self->authenticated_get( $method );
  ## TODO: order object? do we really care?
  
  return $ret;
}

##TODO: POST /api/v1/orders 
##TODO: POST /api/v1/orders/:id_or_custom_field/refund 

####---- PAYMENT METHODS
sub get_payment_methods {
  my $self = shift;
  my $method = "payment_methods";

  my $ret = $self->authenticated_get( $method );
  
  return $ret;
}

####---- RECURRING PAYMENTS

sub get_recurring_payments {
  my $self = shift;
  my $method = "recurring_payments";

  ## optional order id OR custom element
  my $id //= shift;
  if( $id ){
    $method .= "/$id";
  }

  my $ret = $self->authenticated_get( $method );
  return $ret;
}

####---- REPORTS

##TODO: POST /api/v1/reports   -- email out a report
sub get_reports {
  my $self = shift;
  my $method = "reports";

  ## optional order id OR custom element
  my $id //= shift;
  if( $id ){
    $method .= "/$id";
  }

  my $ret = $self->authenticated_get( $method );
  return $ret;
}

####---- SELLS
##TODO: POST /api/v1/sells

####---- SUBSCRIBERS

sub get_subscribers {
  my $self = shift;
  my $method = "subscribers";

  ## optional order id OR custom element
  my $id //= shift;
  if( $id ){
    $method .= "/$id";
  }

  my $ret = $self->authenticated_get( $method );
  return $ret;
}

####---- TOKENS
##TODO: POST /api/v1/tokens
##TODO: POST /api/v1/tokens/redeem

####---- TRANSACTIONS

sub get_transactions {
  my $self = shift;
  my $method = "transactions";

  ## optional order id OR custom element
  my $id //= shift;
  if( $id ){
    $method .= "/$id";
  }

  my $ret = $self->authenticated_get( $method );
  return $ret;
}

##TODO: POST /api/v1/transactions/send_money

sub get_transactions_sighashes {
  my $self = shift;
  my $method = "transactions";

  my $id //= shift;
  throw 'Missing transaction id field' unless $id;
  if( $id ){
    $method .= "/$id/sighashes";
  }

  my $ret = $self->authenticated_get( $method );
  return $ret;
}

##TODO: PUT /api/v1/transactions/:id/signatures 
##TODO: POST /api/v1/transactions/request_money 
##TODO: PUT /api/v1/transactions/:id/resend_request 
##TODO: DELETE /api/v1/transactions/:id/cancel_request 
###TODO: PUT /api/v1/transactions/:id/complete_request 

####---- TRANSFERS
#
sub get_transfers {
  my $self = shift;
  my $method = 'transfers';

  ##TODO: Params page | limit | all_accounts

  my $ret = $self->authenticated_get( $method );
  
  return $ret;
}

####---- USERS

##TODO: POST /api/v1/users

sub get_users {
  my $self = shift;
  my $method = 'users';

  my $ret = $self->authenticated_get( $method );
  
  return $ret;
}

##TODO: PUT /api/v1/users/:id

1;

__END__
