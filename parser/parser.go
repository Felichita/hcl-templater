package parser

import (
	"fmt"
	"io/ioutil"

	"github.com/hashicorp/hcl/v2"
	"github.com/hashicorp/hcl/v2/hclwrite"

        "github.com/felichita/hcl-templater/utils"
)

// ParseHCLFile parses an HCL file and returns the resulting object
func ParseHCLFile(filename string, pathprefix string) (*hclwrite.File, error) {
	content, err := ioutil.ReadFile(filename)
	if err != nil {
		return nil, err
	}

	// Replace %include statements with contents from referenced files
	content = utils.ProcessIncludes(content, pathprefix)

	// Parse the HCL syntax and return the resulting object
	file, diags := hclwrite.ParseConfig(content, filename, hcl.Pos{Line: 1, Column: 1})
	if diags.HasErrors() {
		return nil, diags
	}
	return file, nil
}

func OutputHCLFile(outputfile string, content *hclwrite.File) error {
	err := ioutil.WriteFile(outputfile, content.Bytes(), 0644)
	if err != nil {
		fmt.Printf("Failed to write file '%s': %v\n", outputfile, err)
	}
	return err
}
