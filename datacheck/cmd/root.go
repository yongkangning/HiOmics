/*
Copyright © 2022 zhangzhining  <zhangzn340@163.com>
*/
package cmd

import (
	"log"
	"os"

	"github.com/henbio/apps/datacheck/datacheck"

	"github.com/spf13/cobra"
)

// rootCmd represents the base command when called without any subcommands
var inputFile string
var checkHeader string
var checkHeaderDuplicate string
var outputFile string
var resultSeparator string
var checkRowDuplicate string

var rootCmd = &cobra.Command{
	Use:   "datacheck",
	Short: "A tools for check txt or excel data.",
	Long:  `A tools for check txt or excel data..version 1.0`,
	Run: func(cmd *cobra.Command, args []string) {
		datacheck.DataCheck(inputFile, checkHeader, checkHeaderDuplicate, outputFile, resultSeparator, checkRowDuplicate)
	},
}

func Execute() {
	err := rootCmd.Execute()
	if err != nil {
		log.Fatalln(err)
		os.Exit(1)
	}
}

func init() {
	rootCmd.Flags().StringVarP(&inputFile, "input", "i", "test.txt", "The input file.")
	rootCmd.MarkFlagRequired("input")
	rootCmd.Flags().StringVarP(&checkHeader, "checkHeader", "c", "true", "is need to check the header of data.")
	rootCmd.Flags().StringVarP(&checkHeaderDuplicate, "checkHeaderDuplicate", "d", "true", "is need to check the header is duplicated or not.")
	rootCmd.Flags().StringVarP(&outputFile, "output", "o", "res.txt", "the result file name.")
	rootCmd.Flags().StringVarP(&checkRowDuplicate, "checkRowDuplicate", "r", "false", "is need to check the row is duplicated or not.")
	rootCmd.MarkFlagRequired("output")
	rootCmd.Flags().StringVarP(&resultSeparator, "sep", "s", "0", "the separator of result file,0 represent tab,1 represent common.")
}
