#!/usr/bin/perl -w
#use lib '/home/rsharma/lib//5.8.8/';
use MIME::Lite;
use Net::SMTP;
my $mail_host = 'mail.radisys.com';
my $DATE=`date '+%m-%d-%y'`;
my $TIME=`date +"%T"`;
my $LogDir ;
my $data="
</table><br><br><br><br><br><br><H2 ALIGN=LEFT STYLE=\"COLOR: RED;\"><u>A4 Level 2 CI CONSOLIDATED TESTS REPORT: Component Test Summary  </H2></u>
<table border=2 align=left>
<tr height = 60 bgcolor=#6699CC><th>COMPONENT</th><th>TOTAL TESTS</th><th>PASSED</th><th>FAILED</th><th>PASS PERCENTAGE</th><th>TEST REPORT</th><th>REPORT STATUS</th></tr>";
my $statusFile = $ARGV[0];
$failCompilation = $data;
($compilationNameRef,$buildStatusRef,$buildtimeRef,$buildurlRef,$builddurationRef,$commitidRef,$p1Ref,$p2Ref,$p3Ref,$fail)= parseStatusFile($statusFile);	
@compilationName = @$compilationNameRef;
@buildStatus = @$buildStatusRef;
@buildtime = @$buildtimeRef;
@buildurl = @$buildurlRef;
@Build_duration = @$builddurationRef;
@commitid = @$commitidRef;
@p1_Bul = @$p1Ref;
@p2_Bul = @$p2Ref;
@p3_Bul = @$p3Ref;
@p4_Bul = @$p4Ref;
@fail_Bul = @$fail;
$data=$data."</table></div></body></html>";	
my $newfailCompilation= htmlForFail();
$failProduct = $failCompilation.$newfailCompilation;
#my $statusFile = $ARGV[0];
$ToEmail = "DTA4_DevOps_RMQA\@radisys.com,vuppara\@radisys.com";

$ccEmail = "sunil.narasapuram\@radisys.com";

# create a new MIME Lite based email
my $msg = MIME::Lite->new
(
	Subject => "A4 Level 2 CI Consolidated Reports  on $DATE at $TIME",
	From    => "releasedept\@radisys.com",
	To      => $ToEmail,
	Cc	=> $ccEmail,
	Type    => 'text/html',
	Data    => "$failProduct"
) or die "Error creating multipart container: $!\n";
$msg->attach(Type => 'html',
   
   Path => '/JenkinsBackup/DT_L2_new/L2_CI_Consolidate/L2_CI_REPORTS.zip',
   Filename => 'L2_CI_REPORTS.zip' ,
   Disposition => 'attachment'
);

$msg->send('smtp',$mail_host, Timeout=>60); 

sub parseStatusFile
{
	open(FH, "<$statusFile") or die "Cannot Open $statusFile File $! \n";
	my (@compilationArray,@statusArray,@timeArray,@urlArray,@durationArray,@commitidArray,@p1Array,@p2Array,@p3Array,@p4Array,@failarray);
	my @fullFile = <FH>;
	close (FH);
	foreach(@fullFile)
	{
		($name,$status,$time,$url,$duration,$commitid,$p1,$p2,$p3,$p4,$failed)= split(',' ,$_);
		push(@compilationArray,$name); 
		push(@statusArray,$status);
		push(@timeArray,$time);
		push(@urlArray,$url);
		push(@durationArray,$duration);
		push(@commitidArray,$commitid);
		push(@p1Array,$p1);
		push(@p2Array,$p2);	
		push(@p3Array,$p3);
		push(@p4Array,$p4);
		push(@failarray,$failed);
	}
	return(\@compilationArray,\@statusArray,\@timeArray,\@urlArray,\@durationArray,\@commitidArray,\@p1Array,\@p2Array,\@p3Array,\@p4Array,\@failarray);
}

sub htmlForFail
{
	my $failData;	
	for(my $i =0;$i<=$#compilationName;$i++)
	{
		if (defined $buildStatus[$i])
		{
			if( $Build_duration[$i] >= 95)
			{
				$failData=$failData."<tr><td><a href=\"$commitid[$i]\">$compilationName[$i]</a></td><td>$buildStatus[$i]</td><td>$buildtime[$i]</td><td>$buildurl[$i]</td><td bgcolor=#33EE11>$Build_duration[$i]</td><td><a href=\"$p2_Bul[$i]\">$p1_Bul[$i]</a></td><td>$p3_Bul[$i]</td></tr>";
			}
			elsif( $Build_duration[$i] >= 80)
			{
				$failData=$failData."<tr><td><a href=\"$commitid[$i]\">$compilationName[$i]</a></td><td>$buildStatus[$i]</td><td>$buildtime[$i]</td><td>$buildurl[$i]</td><td bgcolor=#FFFF00>$Build_duration[$i]</td><td><a href=\"$p2_Bul[$i]\">$p1_Bul[$i]</a></td><td>$p3_Bul[$i]</td></tr>";	
			}
			else
			{
				$failData=$failData."<tr><td><a href=\"$commitid[$i]\">$compilationName[$i]</a></td><td>$buildStatus[$i]</td><td>$buildtime[$i]</td><td>$buildurl[$i]</td><td bgcolor=#ff0000>$Build_duration[$i]</td><td><a href=\"$p2_Bul[$i]\">$p1_Bul[$i]</a></td><td>$p3_Bul[$i]</td></tr>";	
			}			
		}
	}
	return $failData;
}
