$line = <STDIN>;			
$length = $#ARGV+1;				
while($line)
{
	$i = 0;
	while ($i < $length)
	{
		@word = split('\s+',$line);
		print "@word[@ARGV[$i]]\t";
		$i = $i + 1;
	}
	$line = <STDIN>;
	print "\n";
}