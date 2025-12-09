我要创建一个 libvips 的 ffi 绑定，我有两篇调研报告在 docs 下，你根据内容来帮我完成如下内容

- 库的创建，在当前文件夹下，以它为根目录
- 我希望 flutter 调用方能直接调用，而不用考虑多余的内容
- 因为某些依赖库的头文件会有所不同，我希望能有一些办法能在 ffi 层面上兼容它们，调用方不需要任何平台兼容代码
- 创建项目和库时尽量使用 dart/flutter 提供的命令行工具，生成绑定使用 pub 上的 ffigen 包来做，可以根据 vips.h 来生成 binding 内容，而不是手写
- example 项目也应该是 flutter 命令行来创建
- 暂时只考虑 iOS 和 android，对应的库文件下载从 docs/COMPARISON_REPORT.md
