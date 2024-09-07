package main

import (
	"bufio"
	"fmt"
	"os"
	"regexp"
)

func main() {
	scanner := bufio.NewScanner(os.Stdin)

	// Regular expression to match common sensitive keys
	keyRe := regexp.MustCompile(`(?i)(password|secret|pw|apikey|token|key|passphrase):\s*["']?(.+)["']?`)

	// Regular expression to match potential password values
	valueRe := regexp.MustCompile(`[a-zA-Z0-9@#$%^&*!]+`)

	for scanner.Scan() {
		line := scanner.Text()

		// Check if the line contains a known sensitive key
		if keyRe.MatchString(line) {
			// Replace the value associated with the sensitive key
			line = keyRe.ReplaceAllString(line, `$1: "secret_removed"`)
		} else {
			// Check if the value itself looks like a password
			line = valueRe.ReplaceAllStringFunc(line, func(value string) string {
				// Apply a heuristic to decide if it's a password-like value
				if len(value) > 6 && regexp.MustCompile(`[0-9]`).MatchString(value) && regexp.MustCompile(`[a-zA-Z]`).MatchString(value) {
					return `"secret_removed"`
				}
				return value
			})
		}

		fmt.Println(line)
	}

	if err := scanner.Err(); err != nil {
		fmt.Fprintln(os.Stderr, "error reading input:", err)
		os.Exit(1)
	}
}
