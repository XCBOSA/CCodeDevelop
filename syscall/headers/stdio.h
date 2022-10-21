/*
 filesummary.CH: 提供对IO的支持，对文件的流式操作和IO文件常量
 filesummary.EN: Provide IO support, included stream operations and IO constant
 CH: 打印format，其中的占位符(%)用参数列表中的值替换
 EN: Print format, replace % in argument table value
 format.CH: 可能包含格式化说明符的要打印的字符串
 format.EN: Format expression to print
 arg1.CH: 参数列表
 arg1.EN: Argument table
 */
int  printf(char *format, ...);

/*
 CH: 扫描stdin，其中的占位符(%)将填入参数列表中的变量
 EN: Scan stdin, % will fill argument table variable
 format.CH: 包含格式化说明符的字符串
 format.EN: Format expression to scan
 arg1.CH: 参数列表
 arg1.EN: Argument table
 */
int  scanf(char *format, ...);

/*
 CH: 读取一行文本，填入字符串
 EN: Scan a line, fill toString
 toString.CH: 要填入的字符串
 toString.EN: String to fill
 */
char*  gets(char *toString);

/*
 CH: 从stdin读取下一个字符
 EN: Read next character in stdin
 */
int  getchar();

/*
 CH: 表示大小的整数类型
 EN: Integer type representing size
 */
typedef builtin size_t;

/*
 CH: 表示指针空或整数0
 EN: Representing null pointer or integer 0
 */
builtin NULL;

/*
 CH: 表示文件结尾的字符
 EN: Character representing end of file
 */
builtin EOF;

/*
 CH: 向stdout打印char
 EN: Print char to stdout
 char.CH: 要打印的字符
 char.EN: char to print
 */
int putchar(int char);

/*
 CH: 向stdout打印字符串
 EN: Print string to stdout
 string.CH: 要打印的字符串
 string.EN: String to print
 */
int puts(char *string);

/*
 CH: 表示文件的类型
 EN: Type representing file
 */
typedef builtin FILE;

/*
 CH: 表示文件的类型
 EN: Type representing file
 */
typedef FILE File;

/*
 CH: 表示文件流位置的类型
 EN: Type representing file stream position
 */
typedef builtin fpos_t;

/*
 CH: 表示标准输入流（控制台输入文件）
 EN: Representing standard input stream (Terminal input file)
 */
FILE* stdin;

/*
 CH: 表示标准输出流（控制台输出文件）
 EN: Representing standard output stream (Terminal output file)
 */
FILE* stdout;

/*
 CH: 表示标准错误流（控制台输出文件），在此App运行时等同于stdout
 EN: Representing standard error stream (Terminal output file), alias to stdout in this App
 */
FILE* stderr;

/*
 CH: 用指定的方式打开硬盘文件，在此App中可以打开的文件仅限于项目中的.txt
 EN: Open disk file using specified mode, in this app you only can open .txt file in project
 file.CH: 文件名
 file.EN: file name
 mode.CH: 模式说明符
 mode.EN: Description mode
 */
FILE* fopen(char *file, char *mode);

/*
 CH: 关闭文件流
 EN: Close file stream
 file.CH: 文件
 file.EN: File
 */
void fclose(FILE *file);

/*
 CH: 刷新文件流
 EN: Flush file stream
 file.CH: 文件
 file.EN: File
 */
void fflush(FILE *file);

/*
 CH: 向文件中打印字符
 EN: Print ch to file
 ch.CH: 要打印的字符
 ch.EN: Char to print
 file.CH: 文件
 file.EN: File
 */
void fputc(char ch, FILE *file);

/*
 CH: 从文件中读取字符
 EN: Scan ch from file
 file.CH: 文件
 file.EN: File
 */
char fgetc(FILE *file);

/*
 CH: 向文件中读取字符
 EN: Scan ch from file
 ch.CH: 要打印的字符
 ch.EN: Char to print
 file.CH: 文件
 file.EN: File
 */
void putc(char ch, FILE *file);

/*
 CH: 从文件中读取字符
 EN: Scan ch from file
 file.CH: 文件
 file.EN: File
 */
char getc(FILE *file);

/*
 CH: 设置文件流位置
 EN: Set the stream position for file stream
 file.CH: 文件
 file.EN: File
 pos.CH: 文件位置
 pos.EN: File position
 */
int fsetpos(FILE *file, fpos_t *pos);

/*
 CH: 获取文件流位置
 EN: Get the stream position for file stream
 file.CH: 文件
 file.EN: File
 pos.CH: 文件位置
 pos.EN: File position
 */
int fgetpos(FILE *file, fpos_t *pos);

/*
 CH: 测试文件是否已经达到末尾
 EN: Get is the stream position is end of file
 file.CH: 文件
 file.EN: File
 */
int feof(FILE *file);

/*
 CH: 向文件打印format，其中的占位符(%)用参数列表中的值替换
 EN: Print format to file, replace % in argument table value
 file.CH: 文件
 file.EN: File
 format.CH: 可能包含格式化说明符的要打印的字符串
 format.EN: Format expression to print
 arg1.CH: 参数列表
 arg1.EN: Argument table
 */
int fprintf(FILE *file, char *format, ...);

/*
 CH: 扫描文件，其中的占位符(%)将填入参数列表中的变量
 EN: Scan file, % will fill argument table variable
 file.CH: 文件
 file.EN: File
 format.CH: 包含格式化说明符的字符串
 format.EN: Format expression to scan
 arg1.CH: 参数列表
 arg1.EN: Argument table
 */
int fscanf(FILE *file, char *format, ...);
size_t fread(void *ptr, size_t size, size_t nmemb, FILE *stream);
size_t fwrite(void *ptr, size_t size, size_t nmemb, FILE *stream);

/*
 CH: 将流位置设置流的开头
 EN: Set the stream position to first position
 stream.CH: 指定流
 stream.EN: Specified stream
 */
void rewind(FILE *stream);

/*
 CH: 返回指定流的流位置
 EN: Returns the position of given stream
 stream.CH: 指定流
 stream.EN: Specified stream
 */
long ftell(FILE *stream);

/*
 CH: 从文件读取一行文本，填入字符串
 EN: Scan a line from file, fill toString
 str.CH: 要填入的字符串
 str.EN: String to fill
 n.CH: 字符串缓冲区长度
 n.EN: String length
 stream.CH: 文件
 stream.EN: File
 */
char fgets(char *str, int n, FILE *stream);

/*
 CH: 打印到字符串
 EN: Print to string
 */
int sprintf(char *ToPrint, char *Format, ...);

/*
 CH: 打印到字符串，并提前告知字符串缓冲区大小防止越界写入
 EN: Print to string, tell the program string buffer size to avoid write out of bounds
 */
int snprintf(char *ToPrint, int Sizeof_ToPrint, char *Format, ...);

/*
 CH: 从字符串中扫描变量，行为类似于scanf，但不从流中扫描而是从给定的字符串中扫描
 EN: Scan variables in string, behavior like scanf, but doesn't scan stream, instead of scan given string.
 */
int sscanf(char *, char *, ...);
