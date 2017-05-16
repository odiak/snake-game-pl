use strict;
use warnings;
use utf8;

use Curses;
use Time::HiRes qw/sleep/;
use Switch;
use SnakeGame::State;

initscr;

start_color;

timeout(0);
noecho();
curs_set(0);
keypad(stdscr, 1);

init_pair(1, COLOR_BLACK, COLOR_WHITE);
init_pair(2, COLOR_WHITE, COLOR_RED);
init_pair(3, COLOR_WHITE, COLOR_GREEN);
init_pair(3, COLOR_WHITE, COLOR_BLACK);
bkgd(COLOR_PAIR(1));

my $width = 25;
my $height = 20;

my $screen_width = $width * 2 + 2;
my $screen_height = $height + 2;

sub initial_state {
    SnakeGame::State->new(
        width => $width,
        height => $height,
        snake_points => [[8, 8]],
    );
}

my $state = initial_state();

my $interval = 0.1;
my $slowness = 2;
my $count = $slowness;

sub frame {
    clear();

    if (!$state->{paused} && defined($state->{current_direction})) {
        $state->move_forward();
    }

    attrset(COLOR_PAIR(2));
    for my $p (@{$state->{snake_points}}) {
        my ($x, $y) = @$p;
        move($y + 1, $x * 2 + 1);
        addstr("  ");
    }

    attrset(COLOR_PAIR(3));
    for my $p (@{$state->{food_points}}) {
        my ($x, $y) = @$p;
        move($y + 1, $x * 2 + 1);
        addstr("  ");
    }

    attrset(COLOR_PAIR(4));
    for my $x (0..($screen_width - 1)) {
        move(0, $x);
        addstr(" ");
        move($screen_height - 1, $x);
        addstr(" ");
    }
    for my $y (0..($screen_height - 1)) {
        move($y, 0);
        addstr(" ");
        move($y, $screen_width - 1);
        addstr(" ");
    }

    attrset(COLOR_PAIR(1));
    if ($state->{paused}) {
        move($screen_height, 0);
        addstr("paused");
    } elsif ($state->{is_game_over}) {
        move($screen_height, 0);
        my $length = @{$state->{snake_points}};
        addstr("game over (length: $length)");
    } else {
        move($screen_height, 0);
        my $length = @{$state->{snake_points}};
        addstr("length: $length");
    }
}

LOOP:
while () {
    my $key = getch();
    switch ($key) {
        case 'q' { last LOOP; }
        case KEY_UP { $state->turn_up() }
        case KEY_DOWN { $state->turn_down() }
        case KEY_LEFT { $state->turn_left() }
        case KEY_RIGHT { $state->turn_right() }
        case 'p' { $state->{paused} = !$state->{paused} }
        case 'r' { $state = initial_state() }
    }
    $count++;
    if ($count >= $slowness) {
        $count = 0;
        frame();
    }
    sleep $interval;
}

endwin;
