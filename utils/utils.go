package utils

import (
	"fmt"
	"io/ioutil"
	"path/filepath"
	"strings"
)

// processIncludes replaces %include statements with the contents of the referenced files
func ProcessIncludes(content []byte, pathprefix string) []byte {
	lines := strings.Split(string(content), "\n")

	for i, line := range lines {
		if strings.HasPrefix(line, "%include ") {
			path := filepath.Join(pathprefix, strings.TrimPrefix(line, "%include "))
			includedContent, err := ioutil.ReadFile(path)
			if err != nil {
				fmt.Printf("Failed to include file '%s': %v\n", path, err)
				continue
			}
			lines[i] = string(includedContent)
		}
	}

	return []byte(strings.Join(lines, "\n"))
}
