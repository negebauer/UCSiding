## Check podspec

- Just run  
```bash
pod lib lint UCSiding.podspec
```
[//]: #(`)

## Upload new pod version

- Make sure to set version in `UCSiding.podspec`
- Run  
```bash
glcm "M"
gtg v "M"
pod trunk push UCSiding.podspec
```
[//]: #(`)