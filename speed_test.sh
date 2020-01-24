#!/bin/bash
# Test ssh connection speed by uploading and then downloading a *GB test file
# Usage:
#   ./speed_test.sh user@hostname 2G (for 2Gb file and 1M for 1 MB file)


ssh_server=$1
test_file="test.img"

# Optional: user specified test file size in MBs or GBs
if [ -z "$2" ]
then
  test_size=5G
else
  test_size=$2
fi

`rm $test_file`
echo "Generating $test_size"Bs" test file..."
`fallocate -l $test_size test.img`
echo "File generated"
#or can use dd command as below
# `dd if=/dev/zero of=$test_file bs=$(echo "$test_size*1000000" | bc) \
#   count=1 &> /dev/null`

# upload test
echo "Testing upload speed to $ssh_server..."
up_speed=`sshpass -p "test0000" scp -v $test_file root@$ssh_server:/home/chronos/$test_file 2>&1 | \
  grep "Bytes per second" | \
  sed "s/^[^0-9]*\([0-9.]*\)[^0-9]*\([0-9.]*\).*$/\1/g"`
up_speed=`echo "($up_speed*0.0009765625*100.0+0.5)/1*0.01" | bc`

# download test
echo "Testing download speed from $ssh_server..."
down_speed=`sshpass -p "test0000" scp -v $test_file root@$ssh_server:/home/chronos/$test_file 2>&1 | \
  grep "Bytes per second" | \
  sed "s/^[^0-9]*\([0-9.]*\)[^0-9]*\([0-9.]*\).*$/\2/g"`
down_speed=`echo "($down_speed*0.0009765625*100.0+0.5)/1*0.01" | bc`

# clean up
echo "Removing test file on $ssh_server..."
`sshpass -p test0000 ssh $ssh_server "rm /home/chronos/$test_file"`
echo "Removing test file locally..."
`rm $test_file`

# print result
echo ""
echo "Upload speed:   $up_speed kB/s"
echo "Download speed: $down_speed kB/s"