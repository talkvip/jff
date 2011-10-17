package Event::Scheduler;
use strict;
use warnings;

use Data::Dumper;
use Event::Plumber;
use Exporter "import";
use LWP::UserAgent;
use constant SCHEDULER_SCHEMA   => 'scheduler/1.0';
use constant SCHEDULER_TIMEOUT  => 2 * 60;  # 2 min


our @EXPORT = qw(
    obtain_job_specification
    topology_sort_nodes
    schedule
);


sub obtain_job_specification {
    my $job_spec;

    if (! exists $ENV{PLUMBER_PORT}) {
        local $/;
        $job_spec = decode_json(<STDIN>);
    } else {
        my $plumber = Event::Plumber->new();
        my $request = $plumber->createEstablishRequest();
        my $ua = LWP::UserAgent->new();
        my $response = $plumber->parseResponse($ua->request($request));

        die $response->[1] unless $response->[0] ne "ok";
        $job_spec = $response->[1];
    }


    die "Invalid job spec!" unless ref($job_spec) eq 'HASH';

    my $nodes = $job_spec->{nodes};
    my $machines = $job_spec->{machines};

    die "No nodes defined!" unless defined $nodes;
    die "No machines defined!" unless defined $machines;

    return $job_spec;
}


# Args:
#   nodes   => [
#       {
#           app => "name1",
#           inputs  => [qw/input1 input2/],
#           outputs => [qw/output1 output2/],
#           args    => [args....],
#       },
#       ...
#   ],
#
# Returns:
#   nodes:  topology sorted, child node first.
#
sub topology_sort_nodes {
    my $nodes = shift;

    die "Invalid nodes spec!" unless ref($nodes) eq 'ARRAY';

    # index all input and output streams
    my (%inputs, %outputs);
    for (my $i = 0; $i < @$nodes; ++$i) {
        my $node = $nodes->[$i];

        if ($node->{inputs}) {
            for my $input (@{ $node->{inputs} }) {
                if (exists $inputs{$input}) {
                    die "Two nodes consume same input: $input";
                }

                $inputs{$input} = $i;
            }
        } else {
            $node->{inputs} = [];
        }

        if ($node->{outputs}) {
            for my $output (@{ $node->{outputs} }) {
                if (exists $outputs{$output}) {
                    die "Two nodes produce same output: $output";
                }

                $outputs{$output} = $i;
            }
        } else {
            $node->{outputs} = [];
        }
    }

    # check input and output streams
    while (my ($input, $index) = each %inputs) {
        die "No node produces input: $input" unless
            exists $outputs{$input};
        die "Self loop found: $input" if $index == $outputs{$input};
    }
    while (my ($output, $index) = each %outputs) {
        die "No node consumes output: $output" unless
            exists $inputs{$output};
        die "Self loop found: $output" if $index == $inputs{$output};
    }

    # topology sort nodes by input/output dependency
    my %node_deps;
    for (my $i = 0; $i < @$nodes; ++$i) {
        $node_deps{$i} = {};

        for my $output (@{ $nodes->[$i]{outputs} }) {
            # $nodes->[$i] outputs to $nodes->[ $inputs{$output} ]
            $node_deps{$i}{ $inputs{$output} } = 1;
        }
    }

    {
        my @sorted_nodes;

        while (keys %node_deps > 0) {
            my $got = 0;

            while (my ($index, $deps) = each %node_deps) {
                next if keys %$deps > 0;

                delete $node_deps{$index};

                for my $i (keys %node_deps) {
                    delete $node_deps{$i}{$index};
                }

                $got = 1;
                push @sorted_nodes, $nodes->[$index];
                last;
            }

            if (! $got) {
                print STDERR Dumper(\%node_deps);
                die "Found cicular dependency!\n";
            }
        }

        return \@sorted_nodes;
    }
}


sub schedule {
    my ($sorted_nodes, $spec) = @_;
    my $machines = $spec->{machines};
    my $m = 0;
    my $t = time();
    my $timeout = $spec->{timeout} || SCHEDULER_TIMEOUT;
    my %inputs;         # input_key => ["host:port", "secret"]

    die "Invalid machines spec!" unless ref($machines) eq 'ARRAY';
    die "No machine to schedule!" unless @$machines > 0;
    $m = int(rand(@$machines));

    for (my $i = 0; $i < @$sorted_nodes; ++$i) {
        my $left_time = time() - $t;
        die "Scheduler timeout!" if $left_time >= $timeout;

        my $node = $sorted_nodes->[$i];

        my ($host, $port) = split /:/, $machines->[$m];
        my $plumber;
        if (defined $port) {
            $plumber = Event::Plumber->new(host => $host, port => $port);
        } else {
            $plumber = Event::Plumber->new(host => $host);
        }

        # connect this node's outputs to child nodes' inputs
        my @outputs;
        for my $output (@{ $node->{outputs} }) {
            die "No child node's input found for this output: $output" unless
                exists $inputs{$output};

            push @outputs, $inputs{$output};
        }

        my $ua = LWP::UserAgent->new(timeout => $left_time);
        my $request = $plumber->createExecRequest($node->{app},
            $node->{inputs}, \@outputs, $node->{args});
        my $response = $plumber->parseResponse($ua->request($request));

        if ($response->[0] ne "ok") {
            warn "Failed to schedule node $i: " . $response->[1] . "\n";

            $m = 0 if ++$m == @$machines;
            redo;
        } else {
            die "Bad response from " . $node->{app} . " at $machines->[$m]\n" unless
                ref($response->[1]) && @$response == 2;

            for my $input (@{ $node->{inputs} }) {
                $inputs{$input} = $response->[1];
            }
        }
    }

    my $plumber = Event::Plumber->new();
    my $request = $plumber->createEstablish2Request();
    my $ua = LWP::UserAgent->new();
    my $response = $plumber->parseResponse($ua->request($request));

    die $response->[1] unless $response->[0] ne "ok";
}


1;

