package SnakeGame::State;

use strict;
use warnings;
use utf8;
use 5.10.0;

use List::Util qw/first/;

sub new {
    my ($class, %attrs) = @_;
    my $this = bless({
        is_game_over => 0,
        width => 100,
        height => 100,
        snake_points => [[0, 0]],
        food_points => [],
        current_direction => undef,
        growth => 0,
        paused => 0,
        %attrs,
    }, $class);

    $this->add_food();

    return $this;
}

sub move_forward {
    my $this = shift;

    return if $this->{is_game_over};

    my $snake_points = $this->{snake_points};
    my ($x0, $y0) = @{$snake_points->[0]};
    my ($dx, $dy) = @{$this->{current_direction}};
    if ($this->{growth} > 0) {
        $this->{growth}--;
    } else {
        pop @$snake_points;
    }
    my $x = $x0 + $dx;
    my $y = $y0 + $dy;

    if ($x < 0 || $y < 0 || $x >= $this->{width} || $y >= $this->{height}) {
        $this->{is_game_over} = 1;
        return;
    }
    for my $i (1..(@$snake_points - 1)) {
        my ($x1, $y1) = @{$snake_points->[$i]};
        if ($x == $x1 && $y == $y1) {
            $this->{is_game_over} = 1;
            return;
        }
    }

    unshift @$snake_points, [$x, $y];
    my $food_points = $this->{food_points};
    my $i = 0;
    for my $p (@$food_points) {
        my ($fx, $fy) = @$p;
        if ($x == $fx && $y == $fy) {
            splice @$food_points, $i, 1;
            $this->add_food;
            $this->grow(3);
            last;
        }
        $i++;
    }
}

sub add_food {
    my $this = shift;
    my @not_available_points = (
        @{$this->{snake_points}},
        @{$this->{food_points}},
    );
    while () {
        my $x = int(rand($this->{width}));
        my $y = int(rand($this->{height}));
        unless (defined(first(sub {$_->[0] == $x && $_->[1] == $y}, @not_available_points))) {
            push @{$this->{food_points}}, [$x, $y];
            last;
        }
    }
}

sub grow {
    my ($this, $growth) = @_;
    $this->{growth} += $growth;
}

sub turn_left {
    shift->{current_direction} = [-1, 0];
}

sub turn_right {
    shift->{current_direction} = [1, 0];
}

sub turn_up {
    shift->{current_direction} = [0, -1];
}

sub turn_down {
    shift->{current_direction} = [0, 1];
}

sub snake_length {
    return @{shift->{snake_points}} + 0;
}

1;
