PLUGIN_VERSION?=$(shell ./script/bump.sh -p "v-" -l)
TARGET?=aarch64-apple-darwin
OUT_FILE?=dist/PLATFORMx/aarch64/pactPluginServer
PLUGIN_NAME=deno-template

update_manifest:
	@echo ${PLUGIN_VERSION} && variable=${PLUGIN_VERSION}; jq --arg variable "$$variable" '.version = $$variable' pact-plugin.json > pact-plugin.json

ci_local:
	act --container-architecture linux/amd64

gen_typings_inline:
	deno run --allow-read https://deno.land/x/grpc_basic@0.4.6/gen/dts.ts ./proto/plugin_inlined.proto > ./deno/gRPC/pact_plugin/plugin_inlined.d.ts

gen_typings:
	deno run --allow-read https://deno.land/x/grpc_basic@0.4.6/gen/dts.ts ./proto/plugin.proto > ./deno/gRPC/pact_plugin/plugin.d.ts

compile_x_plat:
	mkdir -p dist
	mkdir -p dist/release
	mkdir -p dist/linux/x86_64
	mkdir -p dist/windows/x86_64
	mkdir -p dist/osx/x86_64
	mkdir -p dist/osx/aarch64

# This is used to build in GitHub Actions. Note compiling with the target flag, increases binary size by 19mb!!!
# ❯ du -h dist/osx/aarch64
# 96M    dist/osx/aarch64
# 77M    dist/osx/aarch64
prepare_mac_aarch64:
	deno compile --allow-all --unstable --target aarch64-apple-darwin -o dist/${PLATFORM}/aarch64/pactPluginServer src/pactPluginServer.ts;
	gzip -c dist/${PLATFORM}/aarch64/pactPluginServer > dist/release/pact-${PLUGIN_NAME}-plugin-${PLATFORM}-aarch64.gz;

compile: compile_x_plat
	deno compile --allow-all --unstable -o dist/${PLATFORM}/${ARCH}/pactPluginServer src/pactPluginServer.ts

compress:
	gzip -c dist/${PLATFORM}/${ARCH}/pactPluginServer > dist/release/pact-${PLUGIN_NAME}-plugin-${PLATFORM}-${ARCH}.gz

prepare: compress generate_manifest

run:
	deno run --allow-all --unstable src/pactPluginServer.ts

test:
	{ make run & }; \
	pid=$$!; \
	sleep 3; \
	deno run --allow-all --unstable test/sendPactPluginClientReqs.ts; \
	r=$$?; \
	kill $$pid; \
	exit $$r

test_binary:
	{ dist/${PLATFORM}/${ARCH}/pactPluginServer & }; \
	pid=$$!; \
	sleep 3; \
	deno run --allow-all --unstable test/sendPactPluginClientReqs.ts; \
	r=$$?; \
	kill $$pid; \
	exit $$r

move_to_plugin_folder:
	mkdir -p ${HOME}/.pact/plugins/pact-${PLUGIN_NAME}-plugin-${PLUGIN_VERSION}
	mv pactPluginServer ${HOME}/.pact/plugins/pact-${PLUGIN_NAME}-plugin-${PLUGIN_VERSION}
	cp pact-plugin.json ${HOME}/.pact/plugins/pact-${PLUGIN_NAME}-plugin-${PLUGIN_VERSION}

generate_manifest:
	variable=${PLUGIN_VERSION}; jq --arg variable "$$variable" '.version = $$variable' pact-plugin.json > dist/release/pact-plugin.json
	cat dist/release/pact-plugin.json

compile_move: compile move_to_plugin_folder

.PHONY: test


PLATFORM 				:=
ARCH 				:=
ifeq '$(findstring ;,$(PATH))' ';'
	PLATFORM=windows
	ifeq ($(PROCESSOR_ARCHITECTURE),AMD64)
		ARCH=aarch64
	endif
	ifeq ($(PROCESSOR_ARCHITECTURE),x86)
		ARCH=x86_64
	endif
	UNAME_P := $(shell uname -m)
	ifeq ($(UNAME_P),x86_64)
		ARCH=x86_64
	endif
	ifneq ($(filter arm%,$(UNAME_P)),)
		ARCH=aarch64
	endif
	ifneq ($(filter aarch64%,$(UNAME_P)),)
		ARCH=aarch64
	endif
else
	PLATFORM:=$(shell uname 2>/dev/null || echo Unknown)
	PLATFORM:=$(patsubst CYGWIN%,Cygwin,windows)
	PLATFORM:=$(patsubst MSYS%,MSYS,windows)
	PLATFORM:=$(patsubst MINGW%,MSYS,windows)
	UNAME_S := $(shell uname -s)
	ifeq ($(UNAME_S),Linux)
		PLATFORM=linux
	endif
	ifeq ($(UNAME_S),Darwin)
		PLATFORM=osx
	endif
	UNAME_P := $(shell uname -m)
	ifeq ($(UNAME_P),x86_64)
		ARCH=x86_64
	endif
	ifneq ($(filter arm%,$(UNAME_P)),)
		ARCH=aarch64
	endif
	ifneq ($(filter aarch64%,$(UNAME_P)),)
		ARCH=aarch64
	endif
endif

detect_os:
	@echo $(shell uname -s)
	@echo $(shell uname -m)
	@echo $(shell uname -p)
	@echo $(shell uname -p)
	@echo $(PLATFORM) $(ARCH)
