package main

import (
	"fmt"
	"os"
	"path/filepath"

	"github.com/akamensky/argparse"

	hclParser "github.com/felichita/hcl-templater/parser"
)

func main() {
	// Create a new argument parser
	parser := argparse.NewParser("hcl-templater", "Parse HCL file")

	// Add an argument for the HCL file path
	hclFile := parser.String("f", "file", &argparse.Options{Required: true, Help: "HCL file path"})
	hclOutput := parser.String("o", "output", &argparse.Options{Required: true, Help: "HCL file output"})
	// Parse the arguments
	err := parser.Parse(os.Args)
	if err != nil {
		fmt.Println(parser.Usage(err))
		return
	}
	hclDir := filepath.Dir(*hclFile)

	// Parse the HCL file
	parsed, err := hclParser.ParseHCLFile(*hclFile, hclDir)
	if err != nil {
		fmt.Printf("Failed to parse HCL file: %v\n", err)
		return
	}
	hclParser.OutputHCLFile(*hclOutput, parsed)
}
