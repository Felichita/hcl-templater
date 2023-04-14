## hcl-templater
hcl-templater is a command-line tool for parsing HCL (Hashicorp Configuration Language) files and replacing `%include` statements with the contents of the referenced files. The resulting HCL file is then written to a specified output file.

### Installation
To install hcl-templater, you need to have Go (version 1.20 or later) installed on your system. Then, run the following command:

```
go get github.com/felichita/hcl-templater
```

This will download the source code and install the hcl-templater executable in your `$GOPATH/bin` directory.

### Usage
Here's the usage information for the hcl-templater command:
```
hcl-templater -f <HCL file path> -o <HCL file output>
```

Here are the available options:

1. -f, --file: The path to the input HCL file.
1. -o, --output: The path to the output HCL file.
For example, to parse an HCL file named input.hcl and write the output to a file named `output.hcl`, run the following command:
```
hcl-templater -f examples/example.hcl -o examples/output.hcl
```
