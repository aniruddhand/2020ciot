$line = <STDIN>;	
$count = 0;
$count1 = 0;		
			
while($line)
{
	
	@word = split('\s+',$line);

	if(@word[1] eq "AGT")
	{
		if(@word[0] eq "r")
		{
			$count = $count + 1;
		}
		if(@word[0] eq "s")
		{
			$count1 = $count1 + 1;
		}

	}
		
	$line = <STDIN>;	
}

$opt = $count / $count1;
$optp = $opt * 100;
print "$optp\n";