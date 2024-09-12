#!/bin/bash
set -x

# Input report file
input_file="L2_CI_Consolidate_report.txt"
# Output HTML file
output_file="report.html"
# Email recipient
#recipient="orga4-scrummasters@radisys.com, orga4-managers@radisys.com,orga4-architects@radisys.com,orgA4-NWMEMS@radisys.com,orgA4-Infra@radisys.com, orgA4-SDN@radisys.com, orgA4-Access@radisys.com, orgA4-NWMPoD@radisys.com, orgA4-ECP@radisys.com, holger.metschulat@telekom.de, Michael.Hoerth@telekom.de, a4-cicd-reports@telekom.de, v.santinelli@reply.de,Shashi.Kiran@radisys.com,Mohan.Shivananjegowda@radisys.com, Sharad.Singh@radisys.com,DTA4_DevOps_RMQA@radisys.com"
recipient="vuppara@radisys.com,hemalatha.ragamsetti@radisys.com,gourav@radisys.com,tejpal.rao@radisys.com"
# Email subject
subject="A4 Level 2 CI CONSOLIDATED TESTS REPORT"
# Email sender
sender="releasedept@radisys.com"

# Start the HTML file
# Define the output file
output_file="output.html"

# Generate the HTML content
cat <<EOT > "$output_file"
<!DOCTYPE html>
<html>
<head>
    <style>
        table {
            font-family: Arial, sans-serif;
	    border-collapse: collapse;
            width: 100%;
        }
        th, td {
            border: 1px solid #000000;
            text-align: center;
            padding: 2px;
        }
        th {
            background-color: #ddffcd;
            color: #24415b;
        }
        .green {
            background-color: #4CAF50;
            color: white;
        }
        .yellow {
            background-color: #FFEB3B;
        }
        .red {
            background-color: #F44336;
            color: white;
        }
        .report-link {
            color: blue;
            text-decoration: underline;
        }
        .legend-table {
            width: 50%;
            margin-bottom: 2px;
            border: 1px solid #000000;
            text-align: center;
        }
        .pass-color {
	    background-color: #ffffff;            
	    color: #000000; 
        }
        .pass-green {
            background-color: #4CAF50;
            color: white;
        }
        .pass-amber {
            background-color: #FFEB3B;
            color: black;
        }
        .pass-red {
            background-color: #F44336;
            color: white;
        }
       .title {
            color: #F44336;
        }
    </style>
</head>
<body>
    <h2 class="title">A4 Level 2 CI CONSOLIDATED TESTS REPORT: Component Test Summary</h2>
    <table class="legend-table">
        <tr>
            <th class="pass-color">LEGEND</th>
            <th class="pass-green">Green</th>
            <th class="pass-amber">Amber</th>
            <th class="pass-red">Red</th>
        </tr>
        <tr>
            <td>Pass %</td>
            <td>90%+</td>
            <td>70-89%</td>
            <td>Less than 70%</td>
        </tr>
    </table>
    <br>
    <table>
        <tr>
            <th>COMPONENT</th>
            <th>TOTAL TESTS</th>
            <th>PASSED</th>
            <th>FAILED</th>
            <th>PASS PERCENTAGE</th>
            <th>Last 30 Days AVG PASS %</th>
            <th>TEST REPORT</th>
            <th>REPORT STATUS</th>
        </tr>
EOT

# Read the input file and generate HTML rows
while IFS=',' read -r component total_tests passed failed pass_percentage avg_pass_percentage test_report test_report_name detailed_report report_status; do
    # Trim leading and trailing whitespace
    component=$(echo "$component" | xargs)
    total_tests=$(echo "$total_tests" | xargs)
    passed=$(echo "$passed" | xargs)
    failed=$(echo "$failed" | xargs)
    pass_percentage=$(echo "$pass_percentage" | xargs)
    avg_pass_percentage=$(echo "$avg_pass_percentage" | xargs)
    test_report=$(echo "$test_report" | xargs)
    test_report_name=$(echo "$test_report_name" | xargs)
    detailed_report=$(echo "$detailed_report" | xargs)
    report_status=$(echo "$report_status" | xargs)

    if [[ "$pass_percentage" == "PASS PERCENTAGE" ]]; then
        continue
    fi

    # Determine color class based on pass percentage
    if (( $(echo "$pass_percentage >= 90" | bc -l) )); then
        color_class="green"
    elif (( $(echo "$pass_percentage > 70" | bc -l) )) && (( $(echo "$pass_percentage < 89" | bc -l) )); then
        color_class="yellow"
    else
        color_class="red"
    fi

    # Determine color class based on average pass percentage
    if (( $(echo "$avg_pass_percentage >= 90" | bc -l) )); then
        avg_color_class="green"
    elif (( $(echo "$avg_pass_percentage > 70" | bc -l) )) && (( $(echo "$avg_pass_percentage < 89" | bc -l) )); then
        avg_color_class="yellow"
    else
        avg_color_class="red"
    fi

    # Append HTML row for the current component
cat <<EOT >> "$output_file"
        <tr>
            <td><a class="report-link" href="$test_report">$component</a></td>
            <td>$total_tests</td>
            <td>$passed</td>
            <td>$failed</td>
            <td class="$color_class">$pass_percentage</td>
            <td class="$avg_color_class">$avg_pass_percentage</td>
            <td><a class="report-link" href="$detailed_report">$test_report_name</a></td>
            <td>$report_status</td>
        </tr>
EOT

done < "$input_file"

# End the HTML file
cat <<EOT >> "$output_file"
    </table>
</body>
</html>
EOT

# Send the email
sendmail -t <<EOF
From: $sender
To: $recipient
Subject: $subject
Content-Type: text/html

$(cat "$output_file")
EOF

