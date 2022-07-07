/*
 filesummary.CH: 提供时间操作函数
 filesummary.EN: Provide time operations
 CH: 理论上指的CPU一秒内时钟数，现用于clock函数计算真实秒数
 EN: Theoretically refers to the number of clocks in one second of the CPU, which is now used in the clock function to calculate the real number of seconds
 */
int CLOCKS_PER_SEC;

/*
 CH: 用来保存时间和日期的结构
 EN: Structure to hold time and date
 */
struct tm {
    builtin binary code
};

/*
 CH: 存储日历时间类型
 EN: Store calendar time type
 */
typedef int time_t;

/*
 CH: 存储处理器时间的类型，需要除CLOCKS_PER_SEC获得实际秒数
 EN: The type to store the processor time, needs to be divided by CLOCKS_PER_SEC to get the actual number of seconds
 */
typedef int clock_t;

/*
 CH: 返回一个指向字符串的指针，它代表了结构 struct timeptr 的日期和时间
 EN: Returns a pointer to a string representing the date and time of the structure struct timeptr
 */
char* asctime(struct tm *timeptr);

/*
 CH: 返回处理器时钟所使用的时间，需要除以 CLOCKS_PER_SEC
 EN: Returns the time used by the processor clock, divided by CLOCKS_PER_SEC
 */
time_t  clock();

/*
 CH: 返回一个表示当地时间的字符串，当地时间是基于参数 timer
 EN: Returns a string representing the local time based on the parameter timer
 */
char* ctime(time_t *timer);

/*
 CH: 计算两个时间的差值
 EN: return the endTime - fromTime in seconds
 */
double  difftime(time_t endTime, time_t fromTime);

/*
 CH: 使用 timer 的值来填充 tm 结构，并用协调世界时（UTC）也被称为格林尼治标准时间（GMT）表示
 EN: Populate the tm structure with the value of timer , expressed in Coordinated Universal Time (UTC) also known as Greenwich Mean Time (GMT)
 */
struct tm* gmtime(time_t *timer);

/*
 CH: 使用 timer 的值来填充 tm 结构。timer 的值被分解为 tm 结构，并用本地时区表示
 EN: Fill the tm structure with the value of timer. The value of timer is decomposed into a tm structure and expressed in the local time zone
 */
struct tm* localtime(time_t *timer);

/*
 CH: 将tm转换为time_t
 EN: Transfer tm to time_t
 */
time_t mktime(struct tm *timePtr);

/*
 CH: 得到当前日历时间或者设置日历时间
 EN: Get current calendar time or set calendar time
 */
time_t time(time_t *timer);

/*
 CH: 根据 format 中定义的格式化规则，格式化结构 timeptr 表示的时间，并把它存储在 str 中
 EN: Formats the time represented by the structure timeptr according to the formatting rules defined in format and stores it in str.
 */
int strftime(char *string, size_t maxSize, char *format, struct tm *timePtr);

/*
 CH: 按照特定时间格式将字符串转换为时间类型
 EN: Convert a string to a time type according to a specific time format
 */
char* strptime(char *string, char *format, struct tm *timePtr);

/*
 CH: 等同于 gmtime (Thread Safe)
 EN: Same to gmtime (Thread Safe)
 */
struct tm* gmtime_r(time_t *timePtr, struct tm *result);

/*
 CH: 从tm转换为time_t
 EN: Transfer tm to time_t
 */
int   timegm(struct tm *timePtr);
