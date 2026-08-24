# FMM v3.0 - Native In-Memory Web Runtime

FMM is a blazing-fast, lightweight programming language designed to run components, logic, and layout directly in memory. Built with **Flex & Bison (C)**, it combines the simplicity of Python/Lua with JSX-like reactive capabilities.

## Key Features
- **Zero Bloat:** Built with just two C-driven compiler files.
- **Native Execution:** Runs entirely in memory without heavy JS/React builders.
- **Human-Centric Syntax:** Easy words like `create`, `task`, `check`, `loop`, and `show:`.

## ⚡ Try It Right Now on the Cloud (No Installation)

Click the button below to launch a fully configured Linux Cloud environment in your browser via GitHub Codespaces. You can write, compile, and benchmark FMM instantly!

[![Open in GitHub Codespaces](https://github.com)](https://github.com)

## How to Compile & Run (Inside the Cloud Terminal)
```bash
bison -d fmm.y
flex fmm.l
gcc lex.yy.c fmm.tab.c -o fmm_runtime
```

Create an `example.fmm` file and run it:
```bash
./fmm_runtime example.fmm
```
