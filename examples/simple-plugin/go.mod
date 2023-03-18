module simple-plugin

go 1.17

replace (
	github.com/k14s/kbld => github.com/anujc25/carvel-kbld v0.31.0-update-vendir
	sigs.k8s.io/cluster-api => sigs.k8s.io/cluster-api v1.1.1
)

require (
	github.com/spf13/cobra v1.6.1
	github.com/vmware-tanzu/tanzu-plugin-runtime v0.0.0-20230306195922-7870c5d3ac6f
)

require (
	github.com/AlecAivazis/survey/v2 v2.3.6 // indirect
	github.com/briandowns/spinner v1.19.0 // indirect
	github.com/cpuguy83/go-md2man/v2 v2.0.2 // indirect
	github.com/fatih/color v1.13.0 // indirect
	github.com/google/uuid v1.3.0 // indirect
	github.com/inconshreveable/mousetrap v1.0.1 // indirect
	github.com/kballard/go-shellquote v0.0.0-20180428030007-95032a82bc51 // indirect
	github.com/logrusorgru/aurora v2.0.3+incompatible // indirect
	github.com/mattn/go-colorable v0.1.12 // indirect
	github.com/mattn/go-isatty v0.0.16 // indirect
	github.com/mattn/go-runewidth v0.0.13 // indirect
	github.com/mgutz/ansi v0.0.0-20170206155736-9520e82c474b // indirect
	github.com/olekukonko/tablewriter v0.0.5 // indirect
	github.com/pkg/errors v0.9.1 // indirect
	github.com/rivo/uniseg v0.2.0 // indirect
	github.com/russross/blackfriday/v2 v2.1.0 // indirect
	github.com/spf13/pflag v1.0.5 // indirect
	go.uber.org/atomic v1.7.0 // indirect
	go.uber.org/multierr v1.8.0 // indirect
	golang.org/x/mod v0.7.0 // indirect
	golang.org/x/sys v0.5.0 // indirect
	golang.org/x/term v0.5.0 // indirect
	golang.org/x/text v0.7.0 // indirect
	gopkg.in/yaml.v3 v3.0.1 // indirect
)
