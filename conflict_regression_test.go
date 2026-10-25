package main

import "testing"

// TestWeeksOverlapPatterns covers every valid pair, including both argument orders.
// It keeps the first gate exercise's fix covered without changing the service.
func TestWeeksOverlapPatterns(t *testing.T) {
	cases := []struct {
		a, b Weeks
		want bool
	}{
		{AllWeeks, AllWeeks, true},
		{AllWeeks, OddWeeks, true},
		{AllWeeks, EvenWeeks, true},
		{OddWeeks, AllWeeks, true},
		{OddWeeks, OddWeeks, true},
		{OddWeeks, EvenWeeks, false},
		{EvenWeeks, AllWeeks, true},
		{EvenWeeks, OddWeeks, false},
		{EvenWeeks, EvenWeeks, true},
	}
	for _, c := range cases {
		t.Run(string(c.a)+"/"+string(c.b), func(t *testing.T) {
			if got := weeksOverlap(c.a, c.b); got != c.want {
				t.Errorf("weeksOverlap(%q, %q) = %v, want %v", c.a, c.b, got, c.want)
			}
		})
	}
}
