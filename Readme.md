# Cairo 1.0 Examples

install:

    git submodule init && git submodule update

update:

    git submodule update

build:

    cargo build

install Language Server

    cargo build --bin cairo-language-server --release

test:

    cargo run --bin cairo-test -- --starknet --path $(SOURCE_FOLDER)

format:

    cargo run --bin cairo-format -- --recursive $(SOURCE_FOLDER) --print-parsing-errors

check-format:

    cargo run --bin cairo-format -- --check --recursive $(SOURCE_FOLDER)

## Troubleshooting 
- Error: Libfunc alloc_local is not allowed in the libfuncs list 'audited_v0.1.0'.
    - Fix: append this one to your command line -> ``` --allowed-libfuncs-list-name experimental_v0.1.0 ```
