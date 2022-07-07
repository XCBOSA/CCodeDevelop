/*
 filesummary.CH: 作用类似于unistd.h或windows.h，提供一些与C Code Develop和运行环境相关的API
 filesummary.EN: Like unistd.h or windows.h, provide some C Code Develop and runtime related APIs
 CH: 表示一个计时器（StopWatch）
 EN: Representation a StopWatch
 */
typedef builtin ccdsw;

/*
 CH: 表示一个函数引用
 EN: Representation a function
 */
typedef builtin sect;

/*
 CH: 表示最大Heap空间
 EN: Get the maxium heap space
 */
unsigned int ccd_heap_maxmem();

/*
 CH: 表示当前已使用的Heap空间
 EN: Get the current used heap space
 */
unsigned int ccd_heap_usedmem();

/*
 CH: 开启一个计时器
 EN: Start a stopwatch
 */
ccdsw ccd_stopwatch_begin();

/*
 CH: 停止指定的计时器，并返回经过的时间
 EN: End specified stopwatch and return the time between start and end
 sw.CH: 计时器实例
 sw.EN: Stopwatch Instance
 */
double ccd_stopwatch_end(ccdsw sw);

/*
 CH: 输出计时器时间
 EN: Display specified stopwatch time between start and end
 sw.CH: 计时器实例
 sw.EN: Stopwatch Instance
 msg.CH: 附加消息
 msg.EN: Extra message
 */
double ccd_stopwatch_disp(ccdsw sw, char *msg);

/*
 Deprecated from V3.0
 */
int ccd_io_fexts(char *file, unsigned int path);

/*
 Deprecated from V3.0
 */
int ccd_io_write(char *file, unsigned int path, void *data, int len);

/*
 CH: 获取函数的sect引用
 EN: Get the sect reference of specified function
 funcName.CH: 函数名
 funcName.EN: Function Name
 */
sect selector(char *funcName);

/*
 CH: 调用函数引用
 EN: Call function reference
 sel.CH: sect引用
 sel.EN: sect reference
 arg.CH: 参数
 arg.EN: argument for calling function
 */
void performSelector(sect sel, void *arg);

/*
 CH: 执行字符串中的C语言代码
 EN: Running C code in given string
 c_code.CH: 包含C代码的字符串
 c_code.EN: String contains C code
 */
void exec(char *c_code);

/*
 CH: 阻塞当前线程
 EN: Block current thread for seconds
 second.CH: 时间（秒）
 second.EN: Time in seconds
 */
void sleep(unsigned int second);

/*
 CH: 阻塞当前线程
 EN: Block current thread for u-seconds
 second.CH: 时间（微秒）
 second.EN: Time in u-second
 */
int usleep(unsigned int usecond);
