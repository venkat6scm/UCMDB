#!/usr/bin/perl -w
use strict;
use warnings;
use MIME::Lite;
use Net::SMTP;


my $mail_host = 'mail.radisys.com';
my $DATE = `date '+%m-%d-%y'`;
my $TIME = `date +"%T"`;
my $LogDir;  


my $legend_html = <<HTML;
<table border="0" cellspacing="2" cellpadding="2">
    <tbody>
        <tr>
            <th colspan="2">Legend</th>
        </tr>
        <tr>
            <td style="background-color: green;">Green</td>
            <td>90+%</td>
        </tr>
        <tr>
            <td style="background-color: orange;">Amber</td>
            <td>70-89%</td>
        </tr>
        <tr>
            <td style="background-color: red;">Red</td>
            <td>Less than 70%</td>
        </tr>
    </tbody>
</table>
<br><br><br><br><br><br>
HTML


my $data = <<HTML;
<div align="left">
<H2 ALIGN=LEFT STYLE="COLOR: RED;"><u>A4 Level 2 CI CONSOLIDATED TESTS REPORT: Component Test Summary  </H2></u>
<table border="2" align="left">
    <tr height = 60 bgcolor=#6699CC>
        <th>COMPONENT</th>
        <th>TOTAL TESTS</th>
        <th>PASSED</th>
        <th>FAILED</th>
        <th>PASS PERCENTAGE</th>
        <th>Last 30 Days AVG PASS%</th>
        <th>TEST REPORT</th>
        <th>REPORT STATUS</th>
    </tr>
    <!-- Placeholder for actual data rows -->
</table>
</div>
HTML


my $attachment_path = '/JenkinsBackup/DT_L2_new/L2_CI_Consolidate/L2_CI_REPORTS.zip';
my $attachment_filename = 'L2_CI_REPORTS.zip';
my $ToEmail = 'DTA4_DevOps_RMQA1i@radisys.com, vuppara@radisys.com';
my $ccEmail = 'sunil.narasapuram1@radisys.com';


my $statusFile = $ARGV[0];
my ($compilationNameRef, $buildStatusRef, $buildtimeRef, $buildurlRef, $builddurationRef, $avgassrrayRef, $commitidRef, $p1Ref, $p2Ref, $p3Ref, $failRef) = parseStatusFile($statusFile);
my @compilationName = @$compilationNameRef;
my @buildStatus = @$buildStatusRef;
my @buildtime = @$buildtimeRef;
my @buildurl = @$buildurlRef;
my @Build_duration = @$builddurationRef;
my @Avg_Pass = @$avgassrrayRef;
my @commitid = @$commitidRef;
my @p1_Bul = @$p1Ref;
my @p2_Bul = @$p2Ref;
my @p3_Bul = @$p3Ref;
my @fail_Bul = @$failRef;


my $failCompilation = '';
my $newfailCompilation = htmlForFail();
my $failProduct = $legend_html . $data . $newfailCompilation;


my $msg = MIME::Lite->new(
    Subject => "A4 Level 2 CI Consolidated Reports on $DATE at $TIME",
    From    => "releasedept@radisys.com",
    To      => $ToEmail,
    Cc      => $ccEmail,
    Type    => 'multipart/mixed'
) or die "Error creating multipart container: $!\n";

$msg->attach(
    Type        => 'text/html',
    Data        => $failProduct
);

$msg->attach(
    Type        => 'application/zip',
    Path        => $attachment_path,
    Filename    => $attachment_filename,
    Disposition => 'attachment'
);


$msg->send('smtp', $mail_host, Timeout => 60);


sub parseStatusFile {
    my ($statusFile) = @_;

    open(my $FH, "<", $statusFile) or die "Cannot Open $statusFile File $! \n";
    my (@compilationArray, @statusArray, @timeArray, @urlArray, @durationArray, @avgpassArray, @commitidArray, @p1Array, @p2Array, @p3Array, @p4Array, @failarray);
    my @fullFile = <$FH>;
    close ($FH);

    foreach my $line (@fullFile) {
        my ($name, $status, $time, $url, $duration, $avgpass, $commitid, $p1, $p2, $p3, $p4, $failed) = split(',', $line);
        push(@compilationArray, $name);
        push(@statusArray, $status);
        push(@timeArray, $time);
        push(@urlArray, $url);
        push(@durationArray, $duration);
        push(@avgpassArray, $avgpass);
        push(@commitidArray, $commitid);
        push(@p1Array, $p1);
        push(@p2Array, $p2);
        push(@p3Array, $p3);
        push(@p4Array, $p4);
        push(@failarray, $failed);
    }

    return (\@compilationArray, \@statusArray, \@timeArray, \@urlArray, \@durationArray, \@avgpassArray, \@commitidArray, \@p1Array, \@p2Array, \@p3Array, \@p4Array, \@failarray);
}


sub htmlForFail {
    my $failData = '';
    for (my $i = 0; $i <= $#compilationName; $i++) {
        if (defined $buildStatus[$i]) {
            if ($Build_duration[$i] > 90 && $Avg_Pass[$i] > 90) {
                $failData .= "<tr><td><a href=\"$commitid[$i]\">$compilationName[$i]</a></td><td>$buildStatus[$i]</td><td>$buildtime[$i]</td><td>$buildurl[$i]</td><td bgcolor=#33EE11>$Build_duration[$i]</td><td bgcolor=#33EE11>$Avg_Pass[$i]</td><td><a href=\"$p2_Bul[$i]\">$p1_Bul[$i]</a></td><td>$p3_Bul[$i]</td></tr>";
            }
            elsif ($Build_duration[$i] >= 70 && $Avg_Pass[$i] > 70) {
                $failData .= "<tr><td><a href=\"$commitid[$i]\">$compilationName[$i]</a></td><td>$buildStatus[$i]</td><td>$buildtime[$i]</td><td>$buildurl[$i]</td><td bgcolor=#FFFF00>$Build_duration[$i]</td><td bgcolor=#FFFF00>$Avg_Pass[$i]</td><td><a href=\"$p2_Bul[$i]\">$p1_Bul[$i]</a></td><td>$p3_Bul[$i]</td></tr>";
            }
            else {
                $failData .= "<tr><td><a href=\"$commitid[$i]\">$compilationName[$i]</a></td><td>$buildStatus[$i]</td><td>$buildtime[$i]</td><td>$buildurl[$i]</td><td bgcolor=#ff0000>$Build_duration[$i]</td><td bgcolor=#ff0000>$Avg_Pass[$i]</td><td><a href=\"$p2_Bul[$i]\">$p1_Bul[$i]</a></td><td>$p3_Bul[$i]</td></tr>";
            }
        }
    }
    return $failData;
}

