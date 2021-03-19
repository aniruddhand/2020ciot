$line = <STDIN>;
$length = $#ARGV+1;

while($line)
{
  @word = split('\s+',$line);
	
	$i = 0;
	while ($i < $length)
	{
		print "@word[@ARGV[$i]]\t";
		$i = $i + 1;
	}
	$line = <STDIN>;
	print "\n";
}
