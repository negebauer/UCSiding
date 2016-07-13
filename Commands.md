## Check podspec

```bash
pod lib lint UCSiding.podspec
```
`
## Upload new pod version

```bash
glcm "M"
gtg v "M"
pod trunk push UCSiding.podspec
```