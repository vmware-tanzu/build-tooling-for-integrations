#!/bin/bash

COMPONENT="$1"
BASE_DOCKERFILE=Dockerfile
go_mod_file=${COMPONENT}/go.mod

# Copy base Dockerfile to create component-specific Dockerfile
## eg: featuregates/controller -> featuregates.controller.Dockerfile
COMPONENT_DOCKERFILE=${COMPONENT////.}.Dockerfile
cp ${BASE_DOCKERFILE} ${COMPONENT_DOCKERFILE}

# Get relative references from replace directive statements
## Only those replace statements that start with '.'
replace_refs=($(awk -F ' => ' '{ if($2~/^\./) print $2 }' ${go_mod_file}))

if [ ${#replace_refs[@]} -eq 0 ]; then
	printf "No replace directive statements found in %s\n" "$go_mod_file" >&2
	printf "Generated Dockerfile %s for component %s" "$COMPONENT_DOCKERFILE" "$COMPONENT"
	exit 0
fi

# Determine module paths to copy by resolving relative path
mods_to_copy=()

for path in ${replace_refs[@]}
do
	mods_to_copy+=($(readlink -f ${COMPONENT}/${path})) &>/dev/null || {
	printf "! warn: unresolved relative path %s\n" "$path" >&2
	continue
}
done

# Formulate copy statements
copy_statements=()

for path in ${mods_to_copy[@]}
do
	# Replace project root path with '.'
	copy_path=${path/$(pwd)/.}
	copy_statements+=("COPY ${copy_path} ${copy_path}")
done

# Add COPY commands into component-specific Dockerfile
## Join using comma as delimiter
printf -v copy_str "%s," "${copy_statements[@]}"
## Remove trailing delimiter
copy_str=${copy_str%?}

## Find the first occurrence of "COPY" instruction, and 
## add the component-specific COPY commands "above" it.
awk -v text="${copy_str}" '!found && /COPY/ { 
	split(text,lines,",");
	for (i in lines) print lines[i]; 
	found = 1 } 1' ${COMPONENT_DOCKERFILE} > tmp_file && mv tmp_file ${COMPONENT_DOCKERFILE}

printf "Generated Dockerfile %s for component %s" "$COMPONENT_DOCKERFILE" "$COMPONENT"
