// Copyright 2022 VMware, Inc. All Rights Reserved.
// SPDX-License-Identifier: Apache-2.0

package cmd

import (
	"fmt"
	"os"
	"path/filepath"

	kbld "github.com/k14s/kbld/pkg/kbld/config"
	"github.com/spf13/cobra"
	"sigs.k8s.io/yaml"
)

var kbldConfigFile string

// kbldReplaceCmd is for replacing newImage path in kbld config file.
var kbldReplaceCmd = &cobra.Command{
	Use:   "kbld-replace",
	Short: "Replace new image in kbld config file",
	RunE:  runKbldReplace,
}

func init() {
	rootCmd.AddCommand(kbldReplaceCmd)
	kbldReplaceCmd.Flags().StringVar(&kbldConfigFile, "kbld-config-file", "packages/kbld-config.yaml", "Path to kbld-config.yaml file")
}

func runKbldReplace(cmd *cobra.Command, args []string) error {
	if len(args) != 2 {
		return fmt.Errorf("need image and newImage arguments")
	}

	image := args[0]
	newImage := args[1]

	file := &[]string{filepath.Clean(kbldConfigFile)}[0]

	data, err := os.ReadFile(*file)
	if err != nil {
		return err
	}

	config := &kbld.Config{}
	if err := yaml.Unmarshal(data, config); err != nil {
		return err
	}

	found := false
	for i := range config.Overrides {
		if config.Overrides[i].Image == image {
			config.Overrides[i].NewImage = newImage
			found = true
			break
		}
	}

	if !found {
		return fmt.Errorf("image %q not found in kbld config", image)
	}

	data, err = yaml.Marshal(config)
	if err != nil {
		return err
	}

	if err = os.WriteFile(*file, data, 0644); err != nil {
		return err
	}
	return nil
}