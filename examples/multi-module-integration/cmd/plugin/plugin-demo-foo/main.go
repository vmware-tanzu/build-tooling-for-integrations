// Copyright 2023 VMware, Inc. All Rights Reserved.
// SPDX-License-Identifier: Apache-2.0

package main

import (
	"os"

	"github.com/vmware-tanzu/tanzu-plugin-runtime/config/types"
	"github.com/vmware-tanzu/tanzu-plugin-runtime/log"
	"github.com/vmware-tanzu/tanzu-plugin-runtime/plugin"
	"github.com/vmware-tanzu/tanzu-plugin-runtime/plugin/buildinfo"
)

var descriptor = plugin.PluginDescriptor{
	Name:        "plugin-demo-foo",
	Target:      types.TargetGlobal,
	Description: "a simple plugin example.",
	Group:       plugin.AdminCmdGroup,
	Version:     buildinfo.Version,
	BuildSHA:    buildinfo.SHA,
}

func main() {
	p, err := plugin.NewPlugin(&descriptor)
	if err != nil {
		log.Fatal(err, "")
	}
	p.AddCommands(
	// Add commands
	)
	if err := p.Execute(); err != nil {
		os.Exit(1)
	}
}
