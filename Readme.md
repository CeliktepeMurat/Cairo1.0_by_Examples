# Cairo 1.0 Boilerplate

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
