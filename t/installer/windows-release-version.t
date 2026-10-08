use strict;
use warnings;
use Test::More;

open my $source, '<', 'contrib/windows/glpi-agent-packaging.pl' or die $!;
my $script = do { local $/; <$source> };
my ($logic) = $script =~ /(my \$version = .*?)\nsub build_app/s;
die 'Windows version logic not found' unless $logic;

for my $case (
    ['1.21', '1.21'],
    ['1.21', '1.21-beta1'],
    ['1.21', '1.21_EM-2'],
    ['1.21.1', '1.21.1_EM-2'],
) {
    local $GLPI::Agent::Version::VERSION = $case->[0];
    local $ENV{GITHUB_SHA} = '340d7d7be0000000';
    local $ENV{GITHUB_REF} = 'refs/tags/' . $case->[1];
    my $actual = eval $logic . "\n" . '$version;';
    die $@ if $@;
    is($actual, $case->[1], 'Preserve release tag ' . $case->[1]);
}

done_testing;
