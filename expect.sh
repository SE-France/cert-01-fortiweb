#!/usr/bin/expect -f

# Source : https://paulgporter.net/2012/12/08/30/

# Set variables
set hostname [lindex $argv 0]
set username [lindex $argv 1]
set password [lindex $argv 2]
set certname [lindex $argv 3]
set certkey  [lindex $argv 4]
set certcert [lindex $argv 5]
set adom [lindex $argv 6]

# Announce which device we are working on and at what time
send_user "\n"
send_user ">>>>>  Working on $hostname @ [exec date] <<<<<\n"
send_user "\n"

# Don't check keys
spawn ssh -o StrictHostKeyChecking=no $username\@$hostname

# Allow this script to handle ssh connection issues
expect {
timeout { send_user "\nTimeout Exceeded - Check Host\n"; exit 1 }
eof { send_user "\nSSH Connection To $hostname Failed\n"; exit 1 }
"*#" {}
"*assword:" {
send "$password\n"
}
}

# If there are adom configured let's go inside
if ($adom) {
    expect {
        default { send_user "\nCan't access to the adom\n"; exit 1 }
        "*#" {
            send "config vdom\n"
            expect "*(vdom) #"
            send "edit $adom\n"
            
            expect {
                default { send_user "\nCan't access to the adom\n"; exit 1 }
                "*Add new entry '$adom'*" {send_user "\nUps! I've created a new vdom :s\n"; exit 1 }
                "*($adom) #" {}
            }
        }
    }
}

send "config system certificate local\n"
expect {
    default { send_user "\nCan't access to the vdom\n"; exit 1 }
    "*(local) #" {
        send "edit '$certname'\n"
        expect {
            default {send_user "\nSomething wrong append (duplicate ?)\n"; exit 1}
            "*($certname) #" { 
                send "set certificate '$certcert'\n" 
                send "set private-key '$certkey'\n"
                send "next\n"
                expect {
                    "*Command fail.*"{send_user "\nSomething wrong append (wrong priv or cert files)\n"; exit 1}
                    default {}
                }
            }
        }
        send "end\n"
    }
}

send "exit\n"
exit