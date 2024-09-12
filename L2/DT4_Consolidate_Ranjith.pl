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
<tr height = 100 bgcolor=#6699CC><th>COMPONENT NAME</th><th>TOTAL TEST</th><th>TEST PASSED</th><th>TEST FAILED</th><th>PERCENTAGE</th><th>Test Report</th><th>Report Status</th></tr>";
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
$ToEmail = "orga4-scrummasters1\@radisys.com, orga4-managers1\@radisys.com, orga4-architects1\@radisys.com,orgA4-NWMEMS1\@radisys.com,Shashi.Kiran1\@radisys.com,Mohan.Shivananjegowda1\@radisys.com, Sharad.Singh1\@radisys.com, Guruprasanna.ST1\@radisys.com, Ramakrishna.Bodapati1\@radisys.com, Vipin.Tiwari1\@radisys.com, orgA4-NWMPoD1\@radisys.com";


$ccEmail = "orgA4-Devops1\@radisys.com, holger.metschulat1\@telekom.de, Michael.Hoerth1\@telekom.de, a4-cicd-reports1\@telekom.de, v.santinelli1\@reply.de, vuppara\@radisys.com";


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
sub createHtml
{
        for(my $i =0;$i<=$#compilationName;$i++)
        {
           	 $data=$data."<tr><td>$compilationName[$i]</td><td bgcolor=#33EE11>$buildStatus[$i]</td><td>$buildurl[$i]</td><td>$p1_Bul[$i]</td><td>$p2_Bul[$i]</td><td>$p3_Bul[$i]</td><td>$buildtime[$i]</td><td>$Build_duration[$i]</td><td>$commitid[$i]</td><td>$p4_Bul[$i]</td><td>$fail_Bul[$i]</td></tr>";
        }

}

sub htmlForFail
{
	my $failData;
	
	for(my $i =0;$i<=$#compilationName;$i++)
	{
		if (defined $buildStatus[$i])
		{
                           if( $buildtime[$i] > 0 &&  $buildurl[$i] ==0 )

{

                          $failData=$failData."<tr><td><a href=\"$commitid[$i]\">$compilationName[$i]</a></td><td>$buildStatus[$i]</td><td bgcolor=#33EE11>$buildtime[$i]</td><td>$buildurl[$i]</td><td><td>$Build_duration[$i]</td><a href=\"$p1_Bul[$i]\">$p2_Bul[$i]</a></td><td>$p3_Bul[$i]</td><td>$p4_Bul[$i]</td><td>$fail_Bul[$i]</td></tr>";

}

 #                     elsif( $buildurl[$i] > 0 )
#{

#$failData=$failData."<tr><td><a href=\"$commitid[$i]\">$compilationName[$i]</a></td><td>$buildStatus[$i]</td><td bgcolor=#33EE11>$buildtime[$i]</td><td bgcolor=#FF4411>$buildurl[$i]</td><td>$Build_duration[$i]</td><a href=\"$p1_Bul[$i]\">$p2_Bul[$i]</a></td><td>$p3_Bul[$i]</td><td>$p4_Bul[$i]</td><td>$fail_Bul[$i]</td></tr>";

#}

                  else

{

$failData=$failData."<tr><td><a href=\"$commitid[$i]\">$compilationName[$i]</a></td><td>$buildStatus[$i]</td><td>$buildtime[$i]</td><td>$buildurl[$i]</td><td>$Build_duration[$i]</td><a href=\"$p1_Bul[$i]\">$p2_Bul[$i]</a></td><td>$p3_Bul[$i]</td><td>$p4_Bul[$i]</td><td>$fail_Bul[$i]</td></tr>";

}			

                      #  if ($buildStatus[$i]  =~/manual/3
                       # {
                        #       $failData=$failData."<tr><td><a href=\"$buildurl[$i]\">$compilationName[$i]</a></td><td bgcolor=#FFFF00>$buildStatus[$i]</td><td>$buildtime[$i]</td><td>$Build_duration[$i]</td><td>$commitid[$i]</td><td>$p1_Bul[$i]</td><td>$p2_Bul[$i]</td><td>$p3_Bul[$i]</td><td>$fail_Bul[$i]</td></tr>";
                       # }
		#	if ($buildStatus[$i]  =~/Results/)
         #               {


#                           $failData=$failData."<tr><td bgcolor=#FFFF00>$compilationName[$i]</td><td bgcolor=#0000FF>$buildStatus[$i]</td><td></td><td></td><td>$buildurl[$i]</td><td>$Build_duration[$i]</td><td>$commitid[$i]</td><td>$p1_Bul[$i]</td><td>$p2_Bul[$i]</td></tr>";

		
 #                       }


		}
	}
	return $failData;
}
