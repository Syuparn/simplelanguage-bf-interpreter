# simplelanguage-bf-interpreter
Brainf*ck interpreter written in SimpleLanguage (https://github.com/graalvm/simplelanguage)

# Usage

```bash
cat hello.bf | sl bf.sl
Hello, world!
```

## NOTE

This interperter some limitations due to SimpleLanguage syntax.

- bf source code must contain only one token per line.
- `` ` `` and `"` cannot be printed.
