package SnakeGame::Screen;
use strict;
use warnings;
use utf8;

use Curses;
use parent qw/Curses::UI::Widget Curses::UI::Common/;

sub new {
    my $class = shift;
    my %args = (
        @_,
        -nocursor => 1,
    );
    my $this = $class->SUPER::new(%args);
    return $this;
}

sub layout () {
    my $this = shift;
    $this->SUPER::layout;
    return $this if $Curses::UI::screen_too_small;

    return $this;
}

sub draw(;$) {
    my $this = shift;
    my $no_doupdate = shift || 0;
    return $this if $this->hidden;
    $this->SUPER::draw(1);

    my $scr = $this->{-canvasscr};

    my $co = $Curses::UI::color_object;
    my $pair = $co->get_color_pair("black", "red");
    $scr->attron(COLOR_PAIR($pair));

    my $base_x = $this->{-x};
    my $base_y = $this->{-y};
    my $state = $this->{-state};
    for my $p (@{$state->{snake_points}}) {
        my ($x, $y) = @$p;
        $scr->addstr($y, $x * 2, "  ");
    }

    $pair = $co->get_color_pair("black", "yellow");
    $scr->attron(COLOR_PAIR($pair));
    for my $p (@{$state->{food_points}}) {
        my ($x, $y) = @$p;
        $scr->addstr($y, $x * 2, "  ");
    }

    $scr->noutrefresh();
    doupdate() unless $no_doupdate;
    return $this;
}

1;
