/*
 filesummary.CH: 提供基础的功能函数，包括创建销毁自由内存区的函数
 filesummary.EN: Provide standard function, included malloc and free
 CH: 退出程序
 EN: Exit program
 exitCode.CH: main函数返回值，通常0代表成功
 exitCode.EN: main return value, 0 indicates success
 */
void  exit(int exitCode);

/*
 CH: 从堆中申请内存
 EN: allocate memory from heap space
 size.CH: 长度
 size.EN: length
 */
void*  malloc(size_t size);

/*
 CH: 从堆中申请内存，并清零，适用于数组创建
 EN: allocate memory from heap space, and set all to 0, use in array creation
 numOfArray.CH: 数组长度
 numOfArray.EN: array length
 arrayElemSize.CH: 数组成员大小
 arrayElemSize.EN: array element size
 */
void*  calloc(int numOfArray, size_t arrayElemSize);

/*
 CH: 将malloc或calloc申请的内容扩充长度，返回新的地址
 EN: realloc malloc or calloc memory, return new address
 oldBuffer.CH: malloc或calloc申请的内容
 oldBuffer.EN: malloc or calloc returned pointer
 newBufferSize.CH: 新大小
 newBufferSize.EN: new size
 */
void*  realloc(void *oldBuffer, int newBufferSize);

/*
 CH: 释放malloc或calloc申请的内存
 EN: Release malloc or calloc returned pointer
 memory.CH: malloc或calloc申请的内容
 memory.EN: malloc or calloc returned pointer
 */
void*  free(void *memory);

/*
 CH: 将指定的数字转换为指定进制的字符串表示
 EN: Transfer given number to given base
 number.CH: 给定的数字
 number.EN: Given number
 toString.CH: 要写入的字符串
 toString.EN: String to write
 base.CH: 进制
 base.EN: base
 */
char* itoa(int number, char *toString, int base);

/*
 CH: 从指定的字符串中读取一个int
 EN: Read an integer from given string
 fromString.CH: 表示数字的字符串
 fromString.EN: String description a number
 */
int atoi(char *fromString);

/*
 CH: 从指定的字符串中读取一个double
 EN: Read an double from given string
 fromString.CH: 表示数字的字符串
 fromString.EN: String description a number
 */
double atof(char *fromString);

/*
 CH: 从指定的字符串中读取一个long
 EN: Read an long from given string
 fromString.CH: 表示数字的字符串
 fromString.EN: String description a number
 */
long atol(char *fromString);

/*
 CH: 从指定的字符串中读取一个long long (64位下等同于atol)
 EN: Read an long long from given string (Same with atol on 64-bit platform)
 fromString.CH: 表示数字的字符串
 fromString.EN: String description a number
 */
long atoll(char *fromString);

/*
 CH: 表示rand函数可以返回的最大数字
 EN: Description the max number of rand() can return
 */
int RAND_MAX;

/*
 CH: 生成一个[0, RAND_MAX)的随机数
 EN: Generate a random number ranged [0, RAND_MAX)
 */
int rand();

/*
 CH: 使用随机种子生成一个[0, RAND_MAX)的随机数
 EN: Use the random seed to generate a random number ranged [0, RAND_MAX)
 seed.CH: 随机种子
 seed.EN: Random seed
 */
void srand(unsigned int seed);

/*
 CH: 执行系统终端命令
 EN: Execute system terminal command
 command.CH: 命令的字符串形式
 command.EN: The command string
 */
int system(char *command);

/*
 CH: 返回参数中最大的那个数
 EN: Return the max value of given number
 a.CH: 参数1
 a.EN: Argument 1
 b.CH: 参数2
 b.EN: Argument 2
 */
long MAX(long a, long b);

/*
 CH: 返回参数中最小的那个数
 EN: Return the min value of given number
 a.CH: 参数1
 a.EN: Argument 1
 b.CH: 参数2
 b.EN: Argument 2
 */
long MIN(long a, long b);

/*
 CH: 返回参数中最大的那个数
 EN: Return the max value of given number
 a.CH: 参数1
 a.EN: Argument 1
 b.CH: 参数2
 b.EN: Argument 2
 */
long max(long a, long b);

/*
 CH: 返回参数中最小的那个数
 EN: Return the min value of given number
 a.CH: 参数1
 a.EN: Argument 1
 b.CH: 参数2
 b.EN: Argument 2
 */
long min(long a, long b);

/*
 CH: 返回参数中最大的那个数
 EN: Return the max value of given number
 a.CH: 参数1
 a.EN: Argument 1
 b.CH: 参数2
 b.EN: Argument 2
 */
double maxf(double a, double b);

/*
 CH: 返回参数中最小的那个数
 EN: Return the min value of given number
 a.CH: 参数1
 a.EN: Argument 1
 b.CH: 参数2
 b.EN: Argument 2
 */
double minf(double a, double b);
