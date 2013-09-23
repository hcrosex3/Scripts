#!/usr/bin/perl
#
#
#
#
# Original Author: Nicole Green
#
# Program Name: Mule Agent Monitoring 
#
# Purpose: Get status of Mule Agents 
#
# Dated Revisions: see RCS
#----------------------------------------------------------------------------------------------------------------

use strict; 

# Local Variable Definitions
my $HOSTNAME =`hostname`;
my $memused;
my $cpuused;
my $MULEHOME="/usr/local/mule-enterprise-standalone-3.4.0/";
my $MULEPIDFILE="$MULEHOME/bin/.mule_ee.pid";
my $MULEAPP="$MULEHOME/apps/agentmonitor-v1.0";
my $next_arg;
my $Startup_cmd= "./etc/init.d/mule ";
my @buffer;
$SIG{__DIE__}  = 'DIE_handler';
my $pid;
my $pingStatus;
my $restarts =0;

#Redirect Output 
open STDOUT, ">", "/tmp/PersonUpdateTopic.dat" or die "$0: open: $!";
open STDERR, ">&STDOUT"        or die "$0: dup: $!";



print "Checking if the Ping Service deployed or not on $HOSTNAME\n";

if(-d $MULEAPP){
  print "Found deployed Ping Service.....\n\n";
  print "Pinging to the agent ping service on port 8686....\n";
  $pingStatus=`curl -s http://\$HOSTNAME:8686/ping`;

  if($pingStatus=~ /PONG/){
  
  
   print "Ping Service is up and running as of ".substr($pingStatus,6)."\n"; 
   
  }else  {
  
   print "Agent at $HOSTNAME is not responding.....\n";
   print "Ping Service is not deployed.\n";
 `/bin/mail -s "WARN: Agent at $HOSTNAME is not responding.....  " ESDIntegrationServices\@espn.com< /tmp/PersonUpdateTopic.dat`;
}
  print "Getting the Process Id of Mule Agent.....\n";

   open(FILE, $MULEPIDFILE) or die("\n");  
   chomp($pid = <FILE>); 
   close (FILE);  
   print "The PID is $pid\n";
}
# Check Process ID

 print "Checking whether PID $pid is up and running ....\n";
   if(`ps -aef | grep mule | grep java | grep $pid`){
      print "Process Id $pid is up and running...\n";

# Current  Usage


     chomp($memused=`ps -p $pid -o sz | cut -d' ' -f1`);
     chomp($cpuused=`ps -p $pid -o sz,pcpu | cut -d' ' -f3`);      

     print "Current Memory Utilization by the PID $pid is $memused\n";
     print "Current CPU Usage by the PID $pid is $cpuused\n";
     
     if ( $memused >= 5394272) {
     print " Current Memory Utilization by the PID $pid is over 90% , Restarting Agent";
     &DIE_handler
     }else {
     print "Current Memory Utilization by the PID $pid is under 90% \n";
     
     }
     
     if ($cpuused >= 90.0   )  {
     print "Current CPU Usage is over 90% , Restarting Agent\n";
      &DIE_handler
     }else {
     print "Current CPU Usage is under 90% \n";
     }

} else {
      print "Process Id $pid is down";
       `/bin/mail -s "TEST -- WARN: Agent at $HOSTNAME Process Id $pid is down.....  " ESDIntegrationServices\@espn.com< /tmp/PersonUpdateTopic.dat`;
      
   } 
#  Implement Starting Agent if neccessary

sub DIE_handler {
    my($signal) = @_;
    print "\nPID file $MULEPIDFILE does not exist, which may be due to the process being down or an incorrect PID file\n";
        @buffer = (`$Startup_cmd`);
    $restarts=$restarts+1;
    print "$HOSTNAME has been restarted $restarts times";
     `/bin/mail -s "TEST -- CRITICAL: Agent at $HOSTNAME is being restarted" ESDIntegrationServices\@espn.com< /tmp/PersonUpdateTopic.dat`;
    print "\n Restarting Mule Agent\n";
    }
    
exit;