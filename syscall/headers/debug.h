/*
 filesummary.CH: 用于和App联动的特殊或复杂的调试功能
 filesummary.EN: Provide some special or complex debug features
 CH: 打印堆栈信息
 EN: Print stacktrace info
 */
void __xdb_stacktrace();

/*
 CH: 运行时添加断点
 EN: Add a breakpoint in runtime
 fileName.CH: 要添加断点的文件名
 fileName.EN: The file name which you want to add breakpoint
 line.CH: 行号
 line.EN: Line number
 */
void __xdb_breakpoint_add(char *fileName, int line);

/*
 CH: 运行时删除断点
 EN: Remove a breakpoint in runtime
 fileName.CH: 要删除断点的文件名
 fileName.EN: The file name which you want to remove breakpoint
 line.CH: 行号
 line.EN: Line number
 */
void __xdb_breakpoint_rem(char *fileName, int line);

/*
 CH: 返回调用此函数的文件名称
 EN: Return the file name which invoke this function
 */
char* __xdb_current_filename();

/*
 CH: 返回调用此函数的行号
 EN: Return the line number which invoke this function
 */
int __xdb_current_line();

/*
 CH: 打印当前堆栈信息的宏，等同于调用__xdb_stacktrace()，是调试模式下命令的缩写
 EN: Print stacktrace info, can use in debugger command mode, alias to __xdb_stacktrace()
 */
__Macro fstrace;
