require ["fileinto", "imap4flags", "regex"];

if header :contains "X-RCP-Spam-Status" "Certain" {
    discard;
    stop;
}

if header :comparator "i;ascii-casemap" :regex "Received-SPF" "^(Failed|Softfailed)" {
    setflag "\\Seen";
    fileinto "Junk";
    stop;
}

if anyof (header :contains "X-RCP-Spam-Status" "Probable",
          header :contains "X-RCP-Spam-Status" "Potential",
          header :contains "X-RCP-Virus-Status" "Failed") {
    setflag "\\Seen";
    fileinto "Junk";
    stop;
}
