use strict;
use warnings;

my @rows;
my @y = ();
my ($i, $j, $k, $row, $col);
my $bin;

for $row (0..63) {
	$_ = <>;
	for $col (0..63) {
		$rows[63 - $row][$col] = substr $_, $col, 1;
	}
}

for $k (0..3) {
	for $i (0..127) {
		$row  = ($k & 1) << 5;	# 01 0000000 -> 100000
		$row |= ($i & 31);	# 00 0011111 -> 011111
		$col  = ($k & 2) << 1;	# 10 0000000 -> xxx100
		$col |= ($i & 96) >> 5;	# 00 1100000 -> xxx011

		my $a = 0;
		for $j (0..7) {
			$a += $rows[$row][8*$j + $col] << $j;
		}

		$bin .= chr($a);
#		$y[$k][$i] = $a;
	}
}

#for $k (0..3) {
#	for $i (0..7) {
#		printf "%x%x0:", $k, $i;
#		for $j (0..15) {
#			printf " %02x", $y[$k][16*$i + $j];
#		}
#		print "\n";
#	}
#}

print $bin;
