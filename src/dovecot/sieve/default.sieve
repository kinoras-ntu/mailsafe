require ["fileinto", "imap4flags", "regex"];

if header :contains "X-RCP-Spam-Status" "Certain" {
    discard;
    stop;
}

if anyof (header :contains "X-RCP-DKIM-Status" "Failed",
          header :contains "X-RCP-Spam-Status" "Probable",
          header :contains "X-RCP-Spam-Status" "Potential",
          header :contains "X-RCP-Virus-Status" "Failed") {
    setflag "\\Seen";
    fileinto "Junk";
    stop;
}
