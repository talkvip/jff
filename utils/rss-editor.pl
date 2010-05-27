#!/usr/bin/perl
use File::Spec;
use POSIX;
use Tk;
use XML::RSS;
use strict;
use warnings;

use constant CHANNEL_ATTRS   => qw(
    category
    copyright
    description
    docs
    generator
    language
    lastBuildDate
    link
    managingEditor
    pubDate
    rating
    title
    ttl
    webMaster
);

use constant IMAGE_ATTRS     => qw(
    description
    height
    link
    title
    url
    width
);

use constant TEXTINPUT_ATTRS => qw(
    description
    link
    name
    title
);

use constant ITEM_ATTRS      => qw(
    author
    category
    comments
    description
    guid
    link
    pubDate
    title
);
    #source
    #enclosure


our $VERSION = '0.1';

my $rss = XML::RSS->new (version => '2.0',
    encode_output => 1, encode_cb => \&encode_rss);

my $mw = new MainWindow();
my $file = '';
my %rss_widgets = ();

my $scrolled = $mw->Scrolled(
    qw/Frame
    -width          800
    -height         600
    -scrollbars     osoe
    /)->pack(qw/-expand 1 -fill both/);

add_widget($scrolled, 'channel', CHANNEL_ATTRS);
add_widget($scrolled, 'image', IMAGE_ATTRS);
add_widget($scrolled, 'textinput', TEXTINPUT_ATTRS);

$mw->Label(-textvariable => \$file)->pack;

my $toolbar = $mw->Frame()->pack;
$toolbar->Button(-text => 'Load', -command => \&load)->pack(-side => 'left');
$toolbar->Button(-text => 'Save', -command => \&save)->pack(-side => 'left');
$toolbar->Button(-text => 'Save as...', -command => \&saveas)->pack(-side => 'left');
$toolbar->Button(-text => 'New item', -command => sub {
        add_widget($scrolled, 'item', ITEM_ATTRS);
    })->pack(-side => 'left');

if (@ARGV > 0 && -f $ARGV[0]) {
    $file = File::Spec->rel2abs($ARGV[0]);
    loadrss();
}

MainLoop;

sub add_widget {
    my ($scrolled, $type, @attrs) = @_;

    $scrolled = $scrolled->LabFrame(
        -label      => $type,
    )->pack();

    for my $attr (@attrs) {
        my $name = "$type $attr";

        my $frame = $scrolled->Frame()->pack();

        $frame->Label(
            -text       => $name,
            -width      => 30,
            -anchor     => 'w',
        )->pack(-side => 'left');

        $rss_widgets{$name} = $frame->Scrolled(
            'TextUndo',
            -width      => 75,
            -height     => 3,
            -scrollbars => 'osoe'
        )->pack();

        if ($attr eq 'pubDate' or $attr eq 'lastBuildDate') {
            $rss_widgets{$name}->Contents(POSIX::strftime("%a, %d %b %Y %T %z", gmtime));
        } elsif ($attr eq 'language') {
            $rss_widgets{$name}->Contents('zh-cn');
        } elsif ($attr eq 'generator') {
            $rss_widgets{$name}->Contents("rss-editor.pl v$VERSION");
        } elsif ($attr eq 'ttl') {
            $rss_widgets{$name}->Contents("5");
        } elsif ($attr eq 'managingEditor') {
            $rss_widgets{$name}->Contents('editor@example.com');
        } elsif ($attr eq 'webMaster') {
            $rss_widgets{$name}->Contents('webmaster@example.com');
        } elsif ($attr eq 'width') {
            $rss_widgets{$name}->Contents('88');    # <=144
        } elsif ($attr eq 'height') {
            $rss_widgets{$name}->Contents('31');    # <=400
        } elsif ($attr eq 'author') {
            $rss_widgets{$name}->Contents('author@example.com');
        }
    }
}

sub load {
    my $f = $mw->getOpenFile(
        #-filetypes => ['RSS Files', ['.xml', '.rss', '.rdf']],
    );

    return if ! defined $f;
    $file = $f;

    loadrss();
}

sub save {
    if (length($file) == 0) {
        saveas($_[0]);
    } else {
        saverss();
    }
}

sub saveas {
    my $f = $mw->getSaveFile(
        #-defaultextension => '.xml',
        #-filetypes => ['RSS Files', ['.xml', '.rss', '.rdf']],
    );

    return if ! defined $f;
    $file = $f;

    saverss();
}

sub loadrss {
    $rss->parsefile($file);

    print "#" . 70;
    print $rss->as_string;
    print "#" . 70;

    load_rss_element('channel', CHANNEL_ATTRS);
    load_rss_element('image', IMAGE_ATTRS);
    load_rss_element('textinput', TEXTINPUT_ATTRS);

    my @items = @{$rss->{items}};
    my $i = 0;
    for my $item (@items) {
        add_widget($scrolled, "item-$i", ITEM_ATTRS);
        load_rss_element("item-$i", ITEM_ATTRS);
        ++$i;
    }
}

sub load_rss_element {
    my ($type, @attrs) = @_;

    for my $attr (@attrs) {
        my $value;
        if ($type =~ /^item-(\d+)/) {
            my $item = $rss->{items}->[$1];
            next if ! defined $item;
            $value = $item->{$attr};
        } else {
            $value = $rss->$type($attr);
        }
        next if ! defined $value;

        $value =~ s/^\s+|\s+$//g;
        $rss_widgets{"$type $attr"}->Contents($value);
    }
}

sub saverss {
    $rss->save($file);
}

sub save_rss_element {
    my ($type, @attrs) = @_;
    my %h = ();

    for my $attr (@attrs) {
        my $value = $rss_widgets{"$type $attr"}->Contents();
        $value =~ s/^\s+|\s+$//g;
        $h{$attr} = $value if length($value) > 0;
    }

    if ($type eq 'channel') {
        $h{lastBuildDate} = POSIX::strftime("%a, %d %b %Y %T %z", gmtime);
    }

    $rss->$type(%h);
}

sub encode_rss {
    my ($obj, $text) = @_;
    $text =~ s/^\s+|\s+$//g;
    chomp $text;
    return '<![CDATA[' . $text . ']]>';
}

