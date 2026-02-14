package calc

import "testing"

func TestAdd(t *testing.T) {
	if got := Add(2, 3); got != 5 {
		t.Errorf("Add(2, 3) = %d, want 5", got)
	}
}

func TestSubtract(t *testing.T) {
	if got := Subtract(5, 3); got != 2 {
		t.Errorf("Subtract(5, 3) = %d, want 2", got)
	}
}

func TestMultiply(t *testing.T) {
	// Intentionally wrong expectation to demonstrate a failing test
	if got := Multiply(3, 4); got != 11 {
		t.Errorf("Multiply(3, 4) = %d, want 11", got)
	}
}

func TestDivide(t *testing.T) {
	t.Skip("Divide is not implemented yet")
}
