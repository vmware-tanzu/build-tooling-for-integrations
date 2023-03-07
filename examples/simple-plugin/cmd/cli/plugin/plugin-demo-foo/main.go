package main

import (
	"os"

	"github.com/aunum/log"

	cliv1alpha1 "github.com/vmware-tanzu/tanzu-framework/cli/runtime/apis/cli/v1alpha1"
	"github.com/vmware-tanzu/tanzu-framework/cli/runtime/plugin"
)

var descriptor = cliv1alpha1.PluginDescriptor{
	Name:        "plugin-demo-foo",
	Description: "a simple plugin example.",
	Version:     "v0.0.1",
	Group:       cliv1alpha1.ManageCmdGroup, // set group
}

func main() {
	p, err := plugin.NewPlugin(&descriptor)
	if err != nil {
		log.Fatal(err)
	}
	p.AddCommands(
	// Add commands
	)
	if err := p.Execute(); err != nil {
		os.Exit(1)
	}
}
