#!/usr/bin/env perl

use Data::Dumper;

$workdir = $ARGV[0];
$file = $workdir . "/list.all-files";


$onek = 1024;
$onem = 1024 ** 2;
$oneg = 1024 ** 3;

$bidx = 0;
$bucket[$bidx] = 4 * $onek;   $header[$bidx] = '<4K'; $bidx++; 
$bucket[$bidx] = 64 * $onek;  $header[$bidx] = '4K - 64K'; $bidx++;
$bucket[$bidx] = 1 * $onem;   $header[$bidx] = '64k - 1M'; $bidx++; 
$bucket[$bidx] = 25 * $onem;  $header[$bidx] = '1M - 25M'; $bidx++; 
$bucket[$bidx] = 100 * $onem; $header[$bidx] = '25M - 100M'; $bidx++; 
$bucket[$bidx] = 256 * $onem; $header[$bidx] = '100M - 256M'; $bidx++; 
$bucket[$bidx] = 512 * $onem; $header[$bidx] = '256M - 512M'; $bidx++; 
$bucket[$bidx] = 1 * $oneg;   $header[$bidx] = '512M - 1G'; $bidx++; 
$bucket[$bidx] = 5 * $oneg;   $header[$bidx] = '1G - 5G'; $bidx++; 
$header[$bidx] = '>5G';
$max_buckets = $bidx - 1;

# Field     Usage
# 1         Inode
# 2         Generation Number
# 3         Snapshot Id
# 4         KB Allocated
# 5         File Size
# 6         UID
# 7         Fileset Name
# 8         Separator
# 9         Fully qualified File Name
# 71681 1352738104 0  8  1001  0  root -- /chad/adscifs/etc/xinetd.conf

sub addcomma {
    $_ = $_[0];
    if( $_ == 0 ) { return '0'; }
    1 while s/(.*\d)(\d\d\d)/$1,$2/;
    return $_;
}

open(INFIL,"$file") || die("Unable to open file: $file $!\n");
RECORD: while(<INFIL>) {
   chomp;
   @ara=split(/\s+/,$_);

   for( $idx=0; $idx <= $max_buckets; $idx++ ) { 
      if( $ara[4] <= $bucket[$idx] ) { 
          $bytes[$idx] = $bytes[$idx] + $ara[4]; 
          $files[$idx] = $files[$idx] + 1; 
          $idx = $max_buckets + 1;
      }
   }
   if( $ara[4] > $bucket[$max_buckets] ) {
       $bytes[$max_buckets+1] = $bytes[$max_buckets+1] + $ara[4]; 
       $files[$max_buckets+1] = $files[$max_buckets+1] + 1; 
   } 
}
close(INFIL);

printf("%13s \t","Bucket Size");
printf("%10s \t","# of Files");
printf("%20s \n","# of Bytes");
for( $idx=0; $idx <= $max_buckets+1; $idx++ ) {
    printf("%13s \t",$header[$idx]);
    printf("%10s \t",addcomma($files[$idx]));
    printf("%20s \n",addcomma($bytes[$idx]));
}
